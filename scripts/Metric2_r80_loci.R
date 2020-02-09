############ r80 Loci #################
M1_r80 <- read.csv("m3_M1_N1_population_metrics_r80.csv", header=TRUE)
M2_r80 <- read.csv("m3_M2_N2_population_metrics_r80.csv", header=TRUE)
M3_r80 <- read.csv("m3_M3_N3_population_metrics_r80.csv", header=TRUE)
M4_r80 <- read.csv("m3_M4_N4_population_metrics_r80.csv", header=TRUE)
M5_r80 <- read.csv("m3_M5_N5_population_metrics_r80.csv", header=TRUE)
M6_r80 <- read.csv("m3_M6_N6_population_metrics_r80.csv", header=TRUE)
M7_r80 <- read.csv("m3_M7_N7_population_metrics_r80.csv", header=TRUE)
M8_r80 <- read.csv("m3_M8_N8_population_metrics_r80.csv", header=TRUE)
M9_r80 <- read.csv("m3_M9_N9_population_metrics_r80.csv", header=TRUE)
all_r80 <- rbind(M1_r80, M2_r80, M3_r80, M4_r80, M5_r80, M6_r80, M7_r80, M8_r80, M9_r80)
M_values <- c("M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9")
rownames(all_r80) <- c(M_values)

##Graphs the number of r80 loci by parameter value
plot(all_r80$loci, xaxt="n", xlab='Parameter values', ylab="Number of Loci", pch=16, col="purple", ylim=c(min(all_r80$loci),max(all_r80$loci)))
axis(1, at=1:9, labels=rownames(all_r80))
title("r80 loci by Parameter Values", line=.2)