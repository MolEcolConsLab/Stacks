################### Total SNPs #######################
## Import the data
M1_pop <- read.csv("m3_M1_N1_population_metrics.csv", header=TRUE)
M2_pop <- read.csv("m3_M2_N2_population_metrics.csv", header=TRUE)
M3_pop <- read.csv("m3_M3_N3_population_metrics.csv", header=TRUE)
M4_pop <- read.csv("m3_M4_N4_population_metrics.csv", header=TRUE)
M5_pop <- read.csv("m3_M5_N5_population_metrics.csv", header=TRUE)
M6_pop <- read.csv("m3_M6_N6_population_metrics.csv", header=TRUE)
M7_pop <- read.csv("m3_M7_N7_population_metrics.csv", header=TRUE)
M8_pop <- read.csv("m3_M8_N8_population_metrics.csv", header=TRUE)
M9_pop <- read.csv("m3_M9_N9_population_metrics.csv", header=TRUE)
all_pop <- rbind(M1_pop, M2_pop, M3_pop, M4_pop, M5_pop, M6_pop, M7_pop, M8_pop, M9_pop)

M_values <- c("M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9")
rownames(all_pop) <- c(M_values)

## Graph the number of SNPs by parameter setting
plot(all_pop$SNPs, xaxt="n", xlab='Parameter values', ylab="SNPs", pch=16, col="dark red", ylim=c(min(all_pop$SNPs),max(all_pop$SNPs))) #ylim will vary depending on the data
axis(1, at=1:9, labels=rownames(all_pop))
title("SNPs by Parameter Values", line=.2)