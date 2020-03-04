#!/bin/bash

#run ustacks

#BSUB -q long
#BSUB -W 100:00
#BSUB -R rusage[mem=16000]
#BSUB -n 8
#BSUB -R span[hosts=1]
#BSUB -e ./logs/04_run_ustacks.err
#BSUB -oo ./logs/04_run_ustacks.log

#Specify the number of samples to order by coverage in output file and potentially link to.
num_samps=12

#Run ustacks on the whole dataset to determine which samples will be used for parameter optimization
module load stacks/2.3d

counter=1

for file in ./03_clone_filter_out/*1.fq.gz
do
ustacks -f $file -i $counter -o ./04_ustacks_out -p 8
counter=$((counter + 1))
done

wait

#get metrics of interest from the .err file
touch cov.txt

#Build simple text file for extracting metrics information later with awk
#Get sample number, input reads, coverage, and percent of reads used for stacks 
grep -e "Input file" -e "Final coverage" logs/04_run_ustacks.err > cov.txt

##Extract metrics with awk
#Store sample names as variable
sample_names=$(awk -F'/' '/Input file/ {print $3}' cov.txt | cut -d'.' -f1)

#extract number of reads used by ustacks - per sample
reads_used=$(awk -F "=" '/Final coverage/ {print $5}' cov.txt | cut -d'(' -f1)

#extract mean coverage - per sample
mean_cov=$(awk -F "=" '/Final coverage/ {print $2}' cov.txt | cut -d';' -f1)

touch ./metrics/cov_metrics.csv
echo "sample_names "$sample_names > ./metrics/cov_metrics.csv
echo "reads_retained_by_ustacks "$reads_used >> ./metrics/cov_metrics.csv
echo "mean_coverage "$mean_cov >> ./metrics/cov_metrics.csv

sed -i "s/ /,/g" ./metrics/cov_metrics.csv

#transpose to put metrics in columns
awk 'BEGIN { FS=OFS="," }
{
    for (rowNr=1;rowNr<=NF;rowNr++) {
        cell[rowNr,NR] = $rowNr
    }
    maxRows = (NF > maxRows ? NF : maxRows)
    maxCols = NR
}
END {
    for (rowNr=1;rowNr<=maxRows;rowNr++) {
        for (colNr=1;colNr<=maxCols;colNr++) {
            printf "%s%s", cell[rowNr,colNr], (colNr < maxCols ? OFS : ORS)
        }
    }
}' ./metrics/cov_metrics.csv > ./metrics/coverage_metrics.csv

rm ./metrics/cov_metrics.csv
rm ./cov.txt

#Print samples with most coverage (# specified by num_samps variable at top)
echo "The $nums_samps samples with the highest coverage are:"
sort -nrk3 -t"," ./metrics/coverage_metrics.csv | head -$num_samps | cut -d"," -f1,4