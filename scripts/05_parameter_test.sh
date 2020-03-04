#!/bin/bash
#BSUB -q long
#BSUB -W 100:00
#BSUB -R rusage[mem=16000]
#BSUB -n 15
#BSUB -R span[hosts=1]
#BSUB -e logs/05_parameter_test.err
#BSUB -oo logs/05_parameter_test.log

###READ BEFORE RUNNING
#Assumes sample prefixes are stored in hs.txt
#Specify upper limit of M & n parameters to test with params variable
params=9

#Specify number of samples
num_samps=$(awk 'END {print NR}' hs.txt)

#Make popmap file for parameter optimization (all from same population)
sed "s/$/\t1/" ./hs.txt > ./popmap.txt

#Make popmap file for individual heterozygosity (all from different populations)
awk '$2=NR' OFS="\t" hs.txt > ./het_popmap.txt

#Run denovo_map with every parameter setting
module load stacks/2.3d

for var in $(seq 1 $params)
do

#Run denovo_map for each parameter setting
denovo_map.pl -T 15 -m 3 -M $var -n $var -o ./05_parameter_opt/m3_M${var}_n${var} --popmap ./popmap.txt --samples ./05_parameter_opt/clone_filter_test --paired -X "populations: --vcf" -X "populations: --max-obs-het 0.7"

#Get r80 loci
populations -t 15 -P ./05_parameter_opt/m3_M${var}_n${var} -O ./05_parameter_opt/m3_M${var}_n${var}/r80 --popmap ./popmap.txt --vcf -r 0.8 --max-obs-het 0.7

#Get individual heterozygosity
populations -t 15 -P ./05_parameter_opt/m3_M${var}_n${var} -O ./05_parameter_opt/m3_M${var}_n${var}/ind_het --popmap ./het_popmap.txt --max-obs-het 0.7

done

wait

mkdir 05_parameter_opt/vcf_files

#Gather vcf files from different parameter settings runs
#Do we need vcf files from r80 run?
for i in $(seq 1 $params)
do

haps_file=$(ls ./05_parameter_opt/m3_M${i}_n${i}/populations.haps.vcf)
snps_file=$(ls ./05_parameter_opt/m3_M${i}_n${i}/populations.snps.vcf)
cp $haps_file ./05_parameter_opt/vcf_files/m3_M${i}_n${i}.haps.vcf
cp $snps_file ./05_parameter_opt/vcf_files/m3_M${i}_n${i}.snps.vcf

r80_haps=$(ls ./05_parameter_opt/m3_M${i}_n${i}/r80/populations.haps.vcf)
r80_snps=$(ls ./05_parameter_opt/m3_M${i}_n${i}/r80/populations.snps.vcf)
cp $r80_haps ./05_parameter_opt/vcf_files/m3_M${i}_n${i}_r80.haps.vcf
cp $r80_snps ./05_parameter_opt/vcf_files/m3_M${i}_n${i}_r80.snps.vcf

done

wait

for var in $(seq 1 $params)
do
cp ./05_parameter_opt/m3_M${var}_n${var}/denovo_map.log ./05_parameter_opt/logs/m3_M${var}_n${var}.log
cp ./05_parameter_opt/m3_M${var}_n${var}/r80/populations.log ./05_parameter_opt/logs/m3_M${var}_n${var}_r80.log
done

wait

# get metrics of interest from the log files that are output by the program for each parameter setting and r80

for var in $(seq 1 $params)
do

#Build simple text file for extracting metrics information later with awk for full parameter setting run
##Get sample number, input reads, coverage, and percent of reads used for stacks

file=./05_parameter_opt/logs/m3_M${var}_n${var}.log
log=${file%%.log}
output=./metrics/m3_M${var}_n${var}

touch ${log}_pop_metrix.txt

grep -e "Sample . of ." -e "reads; formed" -e "Final coverage" $file  > ${log}_pop_metrix.txt

#Get depth of coverage for all samples
##Change the number after -A to the number of samples
grep -A $num_samps "Depths of Coverage" $file >> ${log}_pop_metrix.txt

#Get number of loci in final catalog
grep "Final catalog" $file >> ${log}_pop_metrix.txt

#Get number of genotyped loci, effective per-sample coverage, sites (bases) per locus, and phasing
grep -A 3 "Genotyped" $file >> ${log}_pop_metrix.txt

#Get number of sites (bases) per locus
grep "Mean genotyped" $file >> ${log}_pop_metrix.txt

#Get population summary stats
grep -A 1 "Population summary" $file >> ${log}_pop_metrix.txt

##Extract metrics with awk
#Store sample names as variable
sample_names=$(awk -F"\'" '/Sample/ {print $2}' ${log}_pop_metrix.txt)

#Get reads input to stacks
in_stacks=$(awk -F" " '/Loaded/ {print $2}' ${log}_pop_metrix.txt)

#extract number of reads used by ustacks - per sample
reads_used=$(awk -F "=" '/Final coverage/ {print $5}' ${log}_pop_metrix.txt | cut -d'(' -f1)

#extract mean coverage - per sample
mean_cov=$(awk -F "=" '/Final coverage/ {print $2}' ${log}_pop_metrix.txt | cut -d';' -f1)

#extract number of loci in catalog - per experiment
cat_loci=$(awk -F " " '/Final catalog/ {print $4}' ${log}_pop_metrix.txt)

#extract number of loci genotyped - per experiment
gen_loci=$(awk -F " " '/Genotyped/ {print $2}' ${log}_pop_metrix.txt)

#Effective per-sample coverage - per experiment
eff_cov=$(awk -F "=" '/effective per-sample/ {print $2}' ${log}_pop_metrix.txt | cut -d'x' -f1)

#Minimum coverage - per experiment
min_cov=$(awk -F "=" '/effective per-sample/ {print $4}' ${log}_pop_metrix.txt | cut -d'x' -f1)

#Maximum coverage - per experiment
max_cov=$(awk -F "=" '/effective per-sample/ {print $5}' ${log}_pop_metrix.txt | cut -d'x' -f1)

#Mean number of sites per locus - per experiment
sites_per=$(awk -F ": " '/mean number/ {print $2}' ${log}_pop_metrix.txt)

#percent reads with phasing - per experiment
phased=$(awk -F "(" '/a consistent phasing/ {print $2}' ${log}_pop_metrix.txt | cut -d'%' -f1)

#Mean genotyped sites per locus - per experiment
mean_gen_loc=$(awk -F " " '/Mean genotyped/ {print $6}' ${log}_pop_metrix.txt | cut -d'b' -f1)

#samples represented per locus - per experiment
samp_loc=$(awk -F " " '/samples per locus/ {print $2}' ${log}_pop_metrix.txt)

#pi - per experiment
pi=$(awk -F " " '/samples per locus/ {print $7}' ${log}_pop_metrix.txt | cut -d';' -f1)

#polymorphic sites - per experiment
SNPs=$(awk -F "/" '/samples per locus/ {print $5}' ${log}_pop_metrix.txt | cut -d';' -f1)

touch ${output}_sample_metrics.csv
echo "sample_names "$sample_names > ${output}_sample_metrics.csv
echo "total_input_reads_to_stacks "$in_stacks >> ${output}_sample_metrics.csv
echo "reads_retained_by_ustacks "$reads_used >> ${output}_sample_metrics.csv
echo "mean_coverage "$mean_cov >> ${output}_sample_metrics.csv

sed -i "s/ /,/g" ${output}_sample_metrics.csv

touch ${output}_population_metrics.csv
echo "catalog loci","loci genotyped","effective per sample coverage","min coverage","max coverage","mean sites per locus","percent reads with phasing","mean genotyped sites per locus","samples genotyped per locus",pi,SNPs > ${output}_population_metrics.csv
echo $cat_loci","$gen_loci","$eff_cov","$min_cov","$max_cov","$sites_per","$phased","$mean_gen_loc","$samp_loc","$pi","$SNPs >> ${output}_population_metrics.csv

rm ${log}_pop_metrix.txt

########## Extract r80 SNPs and loci ##########
#Get number of r80 loci
loci=$(grep -e "Kept" ./05_parameter_opt/logs/m3_M${var}_n${var}_r80.log | awk -F" " '{print $2}')

#r80 SNPs
SNPs=$(grep -e "Kept" ./05_parameter_opt/logs/m3_M${var}_n${var}_r80.log | awk -F" " '{print $14}')

touch ${output}_population_metrics_r80.csv
echo "loci","SNPs" > ${output}_population_metrics_r80.csv
echo $loci","$SNPs >> ${output}_population_metrics_r80.csv

done

######## format individual heterozygosity for import into R #########
for var in $(seq 1 $params)

do

file=./05_parameter_opt/m3_M${var}_n${var}/ind_het/populations.sumstats_summary.tsv

variant_lines=$((num_samps+2))
sed -n "2,${variant_lines}p" $file | sed "s/^#\s//" > ./metrics/m3_M${var}_n${var}_variant_sites.tsv

all_loci_start=$((variant_lines+2))
all_loci_end=$((all_loci_start + num_samps))
sed -n "$all_loci_start,${all_loci_end}p" $file | sed "s/^#\s//" > ./metrics/m3_M${var}_n${var}_all_sites.tsv

done