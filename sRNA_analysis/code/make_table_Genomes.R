#!/usr/bin/env Rscript
library("pacman")
p_load(data.table, dplyr)
args = commandArgs(trailingOnly=TRUE)
file <- args[1]
data <- fread(file, header=FALSE)

d <- data.frame(matrix(ncol=length(unique(data$V2)), nrow=length(unique(data$V1))))
colnames(d) <- unique(data$V2)
rownames(d) <- unique(data$V1) %>% gsub(">", "", .) %>% gsub(":", "_", .) %>% gsub("-", "n", .) %>% gsub("\\+", "p", .) %>% gsub("\\(", "_", .) %>% gsub("\\)", "_", .)

d[] <- 0

for (i in 1:nrow(data)) {
    info <- data[i]
    santykis <- info$V3 %>% gsub("%", "", .) %>% as.numeric
    eilute <- info$V1 %>% gsub(">", "", .) %>% gsub(":", "_", .) %>% gsub("-", "n", .) %>% gsub("\\+", "p", .) %>% gsub("\\(", "_", .) %>% gsub("\\)", "_", .)
    stulpelis <- info$V2
    senas <- d[eilute, stulpelis] 

    d[eilute, stulpelis] <- max(senas, santykis)
    
}

write.csv(d, args[2], row.names=TRUE)
#write.csv(d, "N_lentele.csv", row.names=FALSE)
