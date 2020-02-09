#!/bin/bash
module load R/3.6.0 
module load gcc/8.1.0

# List the number of PCs with the numerical value after the vcf text file and write to new file
Rscript vcfToPCAvarExplained.R vcflist.txt 2 > PCAvarExplained_2.txt
Rscript vcfToPCAvarExplained.R vcflist.txt 3 > PCAvarExplained_3.txt
Rscript vcfToPCAvarExplained.R vcflist.txt 4 > PCAvarExplained_4.txt
Rscript vcfToPCAvarExplained.R vcflist.txt 5 > PCAvarExplained_5.txt
Rscript vcfToPCAvarExplained.R vcflist.txt 8 > PCAvarExplained_8.txt

# for each of the PCAvarExplained files within the directory (PCs 2-8)
for file in $(seq 2 8)
do
# Remove the extra text in the file, and only keep what is needed for plotting then output to a new file
sed 's/^.*vcf_files//g' PCAvarExplained_${file}.txt | sed 's/^.//' |  sed 's/_pops.snps.vcf://g' > PCAplot${file}.txt
done
#########################
########### R ###########
#########################

library(ggplot2)

df <- read.table("PCAplot[N].txt",sep="")

# reverse the order of the rows
df2 <- test[nrow(df):1, ]

# lock in factor level order (otherwise ggplot2 will plot in a different order)
df2$V1 <- factor(df2$V1, levels = df2$V1)

# plot results using ggplot
b <- ggplot(df2, aes(x= df2$V1, y= df2$V2)) + geom_point()
b + theme_bw() + theme(axis.text.x = element_text(face="bold", size=10, angle=45, hjust=1))+ theme(axis.text.y = element_text(face="bold", size=10)) + ggtitle("Cumulative variance of first 4 PCs") + theme(plot.title= element_text(hjust = 0.5))+ ylab("Cumulative variance") + xlab("")
