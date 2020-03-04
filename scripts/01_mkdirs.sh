#!/bin/bash

mkdir 00_RAW_data
mkdir 01_trimmed_RAW_data
mkdir 02_process_out
mkdir 03_clone_filter_out
mkdir 04_ustacks_out
mkdir 05_parameter_opt
mkdir 05_parameter_opt/logs
mkdir 05_parameter_opt/clone_filter_test
mkdir 05_parameter_opt/vcf_files
mkdir 06_denovo_map_out
mkdir 07_FINAL_populations_out
mkdir logs
mkdir metrics

mv ./clustOpt/resources/missingnessHeatMaps.R ./scripts
mv ./clustOpt/resources/pairwiseMissingnessFrom012.pl ./scripts
mv ./clustOpt/* ./scripts
mv ./clustOpt/ ./scripts

mv ./paralog-finder/HDplot_process_vcf.py ./scripts
mv ./paralog-finder/blacklist_paralogs.py ./scripts
mv ./paralog-finder/HDplot_graphs.R ./scripts
mv ./paralog-finder/ ./scripts

for i in $(seq 1 9)

do

mkdir ./05_parameter_opt/m3_M${i}_n${i}
mkdir ./05_parameter_opt/m3_M${i}_n${i}/r80
mkdir ./05_parameter_opt/m3_M${i}_n${i}/ind_het

done