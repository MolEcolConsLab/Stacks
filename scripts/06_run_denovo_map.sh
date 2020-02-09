#!/bin/bash
#run stacks

#BSUB -q long
#BSUB -W 200:00
#BSUB -R rusage[mem=16000]
#BSUB -n 20
#BSUB -R span[hosts=1]
#BSUB -e ./logs/06_run_denovo_map.err
#BSUB -oo ./logs/06_run_denovo_map.log

#Specify optimal parameter values and popmap
M=3
n=3
popmap=./pop_map.txt

#Run Stacks
module load stacks/2.3d

denovo_map.pl -T 20 -m 3 -M $M -n $n -o ./06_denovo_map_out --popmap $popmap --samples ./03_clone_filter_out --paired -X "populations: --vcf"