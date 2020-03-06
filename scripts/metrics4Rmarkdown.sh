#!/bin/bash

#BSUB -q long
#BSUB -W 8:00
#BSUB -R rusage[mem=1000]
#BSUB -n 1
#BSUB -R span[hosts=1]
#BSUB -e ./logs/metrics_prep.err
#BSUB -oo ./logs/metrics_prep.log

module load R/3.6.0 
module load gcc/8.1.0
module load perl/5.18.1 
module load vcftools/0.1.14 

## Make a text file that lists the absolute paths to vcf SNPs file
cd ./05_parameter_opt/vcf_files
ls -d "$PWD"/*snps.vcf > ../../metrics/vcf_all.txt
cd ../../metrics/

# Remove the vcf file paths that we don't need (haps.vcf or r80.snps.vcf)
cat vcf_all.txt | grep -vwE "*haps.vcf" | grep -vwE "*r80.snps.vcf" > vcflist.txt

# Return back to main directory
cd ..

#########################################################
######## Metric 4: Cumulative variance in PCAs ##########
#########################################################

# List the number of PCs with the numerical value after the vcf text file and write to new file
Rscript ./metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 2 > ./metrics/PCAvarExplained_2.txt
Rscript ./metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 3 > ./metrics/PCAvarExplained_3.txt
Rscript ./metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 4 > ./metrics/PCAvarExplained_4.txt
Rscript ./metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 5 > ./metrics/PCAvarExplained_5.txt
Rscript ./metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 7 > ./metrics/PCAvarExplained_7.txt
Rscript ./metrics/clustOpt/vcfToPCAvarExplained.R ./metrics/vcflist.txt 9 > ./metrics/PCAvarExplained_9.txt

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
cd metrics/clustOpt/

# This will run and call on missingnessHeatMaps.R script to produce the pdf heat maps 
perl ./vcfMissingness.pl --vcflist ../vcflist.txt

# we are going to tell the script to pause for 30 minutes to give the 
# perl script enough time to complete (create the PDF missingness heat maps)
# the command 'wait' doesn't work in this pipeline FYI
sleep 30m

# move back out of the clustOpt space and into the main directory
cd ../../

# Copy the output files from the vcfMissingness.pl script. This was outputted to the directory where 
# the vcffiles are located. We want to copy them over to the metrics folder so it's all stored together
# with other metrics for an easier time with the downstream stem. 
# cp -v ./05_parameter_opt/vcf_files/*HM* ./metrics
cp -v ./05_parameter_opt/vcf_files/*pdf ./metrics

# Print out correlations from log file 
grep -i -e '^Correlation' ./logs/metrics_prep.log > ./metrics/missingnessHeatMaps_correlations.txt

done