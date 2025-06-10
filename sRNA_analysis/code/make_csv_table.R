#!/usr/bin/env Rscript
library("pacman")
p_load(data.table, dplyr)
args = commandArgs(trailingOnly=TRUE)
file <- args[1]
data <- fread(file, header=FALSE)

d <- data.frame(matrix(ncol=length(unique(data$V3)), nrow=length(unique(data$V3))))
colnames(d) <- unique(data$V3)
rownames(d) <- unique(data$V3)

for (i in 1:nrow(data)) {
    info <- data[i]
    santykis <- info$V1
    eilute <- info$V2
    stulpelis <- info$V3
    procentai <- round(as.numeric(sapply(strsplit(santykis, "/"), '[', 1)) / as.numeric(sapply(strsplit(santykis, "/"), '[', 2)) * 100, 2)
    d[eilute, stulpelis] <- procentai
}

write.csv(d, args[2], row.names=TRUE)
#write.csv(d, "N_lentele.csv", row.names=FALSE)