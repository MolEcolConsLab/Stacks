#!/bin/bash

module load perl/5.18.1 
module load vcftools/0.1.14 
module load R/3.6.0 
module load gcc/8.1.0

# This will run and call on missingnessHeatMaps.R script to produce the pdf heat maps 
perl vcfMissingness.pl --vcflist vcflist.txt

wait

# Print out correlations from log file (make sure to flag what you want your log file to be called-- fill in [] and lose the brackets)
grep -i -e 'Correlation' [log file] > missingnessHeatMaps_correlations.txt

done