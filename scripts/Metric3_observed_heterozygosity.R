################ Individual heterozygosity ###################
#Variant sites
M1_het <- read.table("m3_M1_n1_variant_sites.tsv", sep="\t", header=TRUE)
M2_het <- read.table("m3_M2_n2_variant_sites.tsv", sep="\t", header=TRUE)
M3_het <- read.table("m3_M3_n3_variant_sites.tsv", sep="\t", header=TRUE)
M4_het <- read.table("m3_M4_n4_variant_sites.tsv", sep="\t", header=TRUE)
M5_het <- read.table("m3_M5_n5_variant_sites.tsv", sep="\t", header=TRUE)
M6_het <- read.table("m3_M6_n6_variant_sites.tsv", sep="\t", header=TRUE)
M7_het <- read.table("m3_M7_n7_variant_sites.tsv", sep="\t", header=TRUE)
M8_het <- read.table("m3_M8_n8_variant_sites.tsv", sep="\t", header=TRUE)
M9_het <- read.table("m3_M9_n9_variant_sites.tsv", sep="\t", header=TRUE)

num_samps <- nrow(M1_het) #Number of samples (in this case, each sample is from a different population so received a different heterozygosity score)
Hetero <- c(M1_het$Obs_Het, M2_het$Obs_Het, M3_het$Obs_Het, M4_het$Obs_Het, M5_het$Obs_Het, M6_het$Obs_Het, M7_het$Obs_Het, M8_het$Obs_Het, M9_het$Obs_Het)
M_values <- c(rep("M1", num_samps), rep("M2", num_samps), rep("M3", num_samps), rep("M4", num_samps), rep("M5", num_samps), rep("M6", num_samps), rep("M7", num_samps), rep("M8", num_samps), rep("M9", num_samps))
Hetero <- data.frame(cbind(Hetero, M_values))
colnames(Hetero)[1] <- "Obs_het"
#head(Hetero)

boxplot(as.numeric(as.character(Obs_het)) ~ M_values, data=Hetero, xlab="Parameter values", ylab="Observed heterozygosity", main="Observed heterozygosity by parameter values")

#All sites
M1_het <- read.table("m3_M1_n1_all_sites.tsv", sep="\t", header=TRUE)
M2_het <- read.table("m3_M2_n2_all_sites.tsv", sep="\t", header=TRUE)
M3_het <- read.table("m3_M3_n3_all_sites.tsv", sep="\t", header=TRUE)
M4_het <- read.table("m3_M4_n4_all_sites.tsv", sep="\t", header=TRUE)
M5_het <- read.table("m3_M5_n5_all_sites.tsv", sep="\t", header=TRUE)
M6_het <- read.table("m3_M6_n6_all_sites.tsv", sep="\t", header=TRUE)
M7_het <- read.table("m3_M7_n7_all_sites.tsv", sep="\t", header=TRUE)
M8_het <- read.table("m3_M8_n8_all_sites.tsv", sep="\t", header=TRUE)
M9_het <- read.table("m3_M9_n9_all_sites.tsv", sep="\t", header=TRUE)

num_samps <- nrow(M1_het) #Number of samples (in this case, each sample is from a different population so received a different heterozygosity score)
Hetero <- c(M1_het$Obs_Het, M2_het$Obs_Het, M3_het$Obs_Het, M4_het$Obs_Het, M5_het$Obs_Het, M6_het$Obs_Het, M7_het$Obs_Het, M8_het$Obs_Het, M9_het$Obs_Het)
M_values <- c(rep("M1", num_samps), rep("M2", num_samps), rep("M3", num_samps), rep("M4", num_samps), rep("M5", num_samps), rep("M6", num_samps), rep("M7", num_samps), rep("M8", num_samps), rep("M9", num_samps))
Hetero <- data.frame(cbind(Hetero, M_values))
colnames(Hetero)[1] <- "Obs_het"
#head(Hetero)

boxplot(as.numeric(as.character(Obs_het)) ~ M_values, data=Hetero, xlab="Parameter values", ylab="Observed heterozygosity", main="Observed heterozygosity by parameter values")