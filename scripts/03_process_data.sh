#!/bin/bash
#run process_radtags and clone_filter

#BSUB -q long
#BSUB -W 100:00
#BSUB -R rusage[mem=16000]
#BSUB -n 8
#BSUB -R span[hosts=1]
#BSUB -e ./logs/03_process_data.err
#BSUB -oo ./logs/03_process_data.log

##Need to specify barcode file
barcode_file="./RADtest_barcodes2.txt"

#Run atropos to trim first two bases
for file in ./00_RAW_data/*.fq.gz
do
sample=${file##./00_RAW_data/}
atropos trim --cut 2 -se $file -o 01_trimmed_RAW_data/${sample}
done

wait

#Run process_radtags
module load stacks/2.3d

for file in ./01_trimmed_RAW_data/*1.fq.gz
do
read_name=${file%%1.fq.gz}
process_radtags -1 $file  -2 ${read_name}2.fq.gz -b $barcode_file -o 02_process_out -c -q -r --inline_null -e sbfI --bestrad
done

wait

#Move "remainder reads" into separate folder
mkdir ./02_process_out/remainder_reads
mv ./02_process_out/*.rem.* ./02_process_out/remainder_reads

#Run clone_filter
for file in ./02_process_out/*.1.fq.gz
do
sample=${file%%.1.fq.gz}
clone_filter -1 ${sample}.1.fq.gz -2 ${sample}.2.fq.gz -i gzfastq -o ./03_clone_filter_out
done

wait

#Rename clone_filter output to remove second number from end - Read 1
for file in ./03_clone_filter_out/*.1.1.fq.gz
do
sample=${file%%.1.1.fq.gz}
mv $file ${sample}.1.fq.gz
done

#Read 2
for file in ./03_clone_filter_out/*.2.2.fq.gz
do
sample=${file%%.2.2.fq.gz}
mv $file ${sample}.2.fq.gz
done

wait

##Extract filter metrics to export to R
touch filt_metrix.txt
###Run on the .err file from process_radtags
grep -A 4 "total sequences" logs/03_process_data.err > filt_metrix.txt

###Run on the .err file from clone_filter
grep -A 1 -e "Reading data from" -e "clone reads" logs/03_process_data.err >> filt_metrix.txt

#total sequences - per lane
tot_seq=$(awk -F" " '/total sequences/ {print $1}' filt_metrix.txt)

#barcode not found drops - per lane
bc_nf=$(awk -F" " '/barcode not found/ {print $1}' filt_metrix.txt)

#low quality read drops - per lane
lq_rd=$(awk -F" " '/low quality/ {print $1}' filt_metrix.txt)

#RAD cutsite not found drops - per lane
no_RAD=$(awk -F" " '/RAD cutsite/ {print $1}' filt_metrix.txt)

#Retained reads - per lane
Retained=$(awk -F" " '/retained reads/ {print $1}' filt_metrix.txt)

#Store sample names as variable
clone_names=$(awk -F "/" '/fq.gz/ { found++ } found > 1 {print $3}' filt_metrix.txt | cut -d'.' -f1)

#extract input reads to clone_filter - per sample
in_filter=$(awk -F" " '/pairs/ {print $1}' filt_metrix.txt)

#extract output reads from clone_filter - per sample
out_filter=$(awk -F" " '/pairs/ {print $6}' filt_metrix.txt)

#extract percent clones - per sample
per_clones=$(awk -F" " '/clone reads/ {print $16}' filt_metrix.txt | cut -d'%' -f1)

touch ./metrics/lane_metrics.csv
echo "Total sequences","barcode not found drops","low quality read drops","RAD cutsite not fo\und drops","Reads Retained" > ./metrics/lane_metrics.csv
echo $tot_seq,$bc_nf,$lq_rd,$no_RAD,$Retained >> ./metrics/lane_metrics.csv

touch ./metrics/filter_metrics.csv
echo "clone_names "$clone_names > ./metrics/filter_metrics.csv
echo "input_reads_to_clone_filter "$in_filter >> ./metrics/filter_metrics.csv
echo "output_reads_from_clone_filter "$out_filter >> ./metrics/filter_metrics.csv
echo "percent_clones "$per_clones >> ./metrics/filter_metrics.csv

sed -i "s/ /,/g" ./metrics/filter_metrics.csv

rm filt_metrix.txt