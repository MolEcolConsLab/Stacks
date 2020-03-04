#!/bin/bash

#BSUB -q long
#BSUB -W 20:00
#BSUB -R rusage[mem=16000]
#BSUB -n 4
#BSUB -R span[hosts=1]
#BSUB -e ./logs/02_prelim_QC.err
#BSUB -oo ./logs/02_prelim_QC.log

#READ BEFORE RUNNING
#This script assumes: 
#1) raw sequence files are gzipped.
#2) barcodes are 8 bases long
#3) raw data is in 00_RAW_data folder, paired end reads ending in 1.fq.gz

#Where do we expect the cut site? With an 8-base barcode and best rad protocol we expect sites 11-16
cut_loc="11-16"

#What is the cut sequence we expect to find? For Sbf it's "TGCAG". Make last character a wild card because process_radtags will rescue cut sites where the last character is different
cut_seq="TGCA."

#Lines to subset
lines=100000

for file in ./00_RAW_data/*1.fq.gz
do

prefix=${file%%1.fq.gz}

#To check whole file
#lines=$(wc -l $file)

echo $file

#Check cut site in positions 11-16 in both forward and reverse reads
cut_freq_1=$(zcat ${prefix}1.fq.gz | head -$lines | awk '/^@/{getline; print}' | cut -c 11-16 | sort | uniq -c | grep "$cut_seq" | awk '{sum+=$1} END{print sum}')
cut_freq_2=$(zcat ${prefix}2.fq.gz | head -$lines | awk '/^@/{getline; print}' | cut -c 11-16 | sort | uniq -c | grep "$cut_seq" | awk '{sum+=$1} END{print sum}')

#Get total number of reads. Could also be done by passing to wc -l 
tot_freq=$(zcat ${prefix}1.fq.gz | head -$lines | awk '/^@/{getline; print}' | cut -c 11-16 | sort | uniq -c | awk '{sum+=$1} END{print sum}')

cut_freq_tot=$((cut_freq_1 + cut_freq_2))

#Check percent of reads with cut site in expected position on either read - divide total found cut sites from both directions by total reads in one direction
cut_perc=$(echo "scale=2; $cut_freq_tot/$tot_freq * 100" | bc)

#Compare number of reads that start with [G,N][G,N] to total number of reads. Check for GG on both reads (since bestrad can switch them)
GG1=$(zcat $file | head -$lines | grep "^[G,N][G,N]" | wc -l)
GG2=$(zcat ${prefix}2.fq.gz | head -$lines | grep "^[G,N][G,N]" | wc -l)
tot=$(zcat $file | head -$lines | grep "^@" | wc -l)

GG=$((GG1 + GG2))
GGperc=$(echo "scale=2; $GG / $tot *100" | bc)
echo "Cut site found in $cut_perc% of reads"
echo "Reads that start with GG (or NG, GN, or NN): $GG"
echo "Total reads analyzed: $tot"
echo "Percent reads that start with GG: $GGperc%"

done