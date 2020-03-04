#!/bin/bash

#BSUB -q long
#BSUB -W 8:00
#BSUB -R rusage[mem=1000]
#BSUB -n 1
#BSUB -R span[hosts=1]
#BSUB -e ./logs/parameter_metrics.err
#BSUB -oo ./logs/parameter_metrics.log

module load R/3.6.0 
module load gcc/8.1.0
module load perl/5.18.1 
module load vcftools/0.1.14 

## Make a text file that lists the absolute paths to vcf SNPs file
cd ./05_parameter_opt/vcf_files
ls -d "$PWD"/*.snps.vcf > ../../metrics/vcflist.txt
cd ../..

#########################################################
######## Metric 4: Cumulative variance in PCAs ##########
#########################################################

# List the number of PCs with the numerical value after the vcf text file and write to new file
Rscript metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 2 > ./metrics/PCAvarExplained_2.txt
Rscript metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 3 > ./metrics/PCAvarExplained_3.txt
Rscript metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 4 > ./metrics/PCAvarExplained_4.txt
Rscript metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 5 > ./metrics/PCAvarExplained_5.txt
Rscript metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 7 > ./metrics/PCAvarExplained_7.txt
Rscript metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 9 > ./metrics/PCAvarExplained_9.txt

# for each of the PCAvarExplained files within the directory (PCs 2-9)
for file in $(seq 2 9)

do

# Remove the extra text in the file, and only keep what is needed for plotting then output to a new file
sed 's/^.*vcf_files//g' ./metrics/PCAvarExplained_${file}.txt | sed 's/^.//' |  sed 's/_pops.snps.vcf://g' > ./metrics/PCAplot${file}.txt

done


##################################################################
### Metric 5: Data missingness vs. pairwise genetic similarity ###
##################################################################

# move back into the clustOpt space (necessary for the next step to run within that folder)
cd ./metrics/clustOpt/

# This will run and call on missingnessHeatMaps.R script to produce the pdf heat maps 
perl ./vcfMissingness.pl --vcflist ../vcflist.txt

# we are going to tell the script to pause for 60 minutes to give the 
# perl script enough time to complete (create the PDF missingness heat maps)
# the command 'wait' doesn't work in this pipeline FYI
sleep 20m

# move back out of the clustOpt space
cd ..

# Print out correlations from log file 
grep -i -e '^Correlation' ../../logs/parameter_metrics.log > ./metrics/missingnessHeatMaps_correlations.txt

done

#copy missingness heat maps to metrics folder
cp 05_parameter_opt/vcf_files/*.pdf metrics