#!/bin/bash
#Run populations on full dataset, excluding putative paralogs

#BSUB -q long
#BSUB -W 30:00
#BSUB -R rusage[mem=16000]
#BSUB -n 20
#BSUB -R span[hosts=1]
#BSUB -e logs/07_run_populations.err
#BSUB -oo logs/07_run_populations.log

#Specify popmap
popmap=./pop_map.txt

module load stacks/2.3d

populations -t 20 -P ./06_denovo_map_out . -O ./07_FINAL_populations_out --popmap $popmap --vcf -B ./paralogs.blacklist -W ./singletons.whitelist --hwe --fstats