#!/bin/bash

#BSUB -q short
#BSUB -W 4:00
#BSUB -R rusage[mem=1000]
#BSUB -n 1
#BSUB -e logs/run_HDplot.err
#BSUB -oo logs/run_HDplot.log

module load python/2.7.9
module load R/3.6.0

#Calculate read ratio deviation and heterozygosity
python ./scripts/HDplot_process_vcf.py -i ./06_denovo_map_out/populations.snps.vcf

wait

#Plot above metrics
Rscript ./scripts/HDplot_graphs.R -i ./.depthsBias --minD -80 --maxD 80

# Rename depthsBias so it's not hidden
mv ./.depthsBias ./population.depthsBias