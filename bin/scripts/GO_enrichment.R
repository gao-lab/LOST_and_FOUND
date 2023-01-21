# Title     : TODO
# Objective : TODO
# Created by: Dan
# Created on: 14/6/2020

# this script is re-written based on go_enrichment.R in Annolnc2 co-expression module

options(stringsAsFactors=F)

suppressMessages(library(data.table))
args <- commandArgs(trailingOnly = T)

# Dir containing prepared data used for GO enrichment, including GOA.BP.mat.gz, GOA.MF.mat.gz, ENSG_has_GO.txt and ENSG_to_symbol.txt
dataDir <- args[1]
# Query gene set for enrichment
target_module_set <- args[2]
# output dir
outDir <- args[3]


#load data
BP_mat <- fread(paste0(dataDir, "/GOA.BP.mat.gz"), nThread=5)
MF_mat <- fread(paste0(dataDir, "/GOA.MF.mat.gz"), nThread=5)
ensg_has_go <- read.table(paste0(dataDir, "/ENSG_has_GO.txt"), header=F)
ensg_has_go <- ensg_has_go$V1
ensg2symbol <- read.table(paste0(dataDir, "/ENSG_to_symbol.txt"), header=T)

# target module data set
target_gene <- read.table(target_module_set, header=T, row.names=1, check.names=F)



# convert ensembl gene ID to gene symbol
convertID <- function(coTable) {
  # convert ensg ID to gene symbol for the co-expression table
  coTable <- as.data.frame(coTable)
  coTable[, 1] <- as.vector(coTable[, 1])
  tmp <- ensg2symbol[ensg2symbol[, 1] %in% coTable[, 1], ]
  convert <- tapply(as.vector(tmp[, 2]), as.factor(tmp[, 1]), function(x) paste(x, collapse=','))
  result <- cbind(coTable[, 1], convert[coTable[, 1]], coTable[, 2])
  result[is.na(result[, 2]), 2] <- 'NA'
  rownames(result) <- NULL
  result <- as.data.frame(result)
  return(result)
}

# fisher test
fisher_test <- function(x, ref.num, target.num){
  #x[refList]: how many genes in reference list were annotated to this term
  #x[geneList]: how many genes in target list were annotated to this term
  return(fisher.test(matrix(c(x["geneList"], x["refList"], target.num-x["geneList"], ref.num-x["refList"]), nrow=2))$p.value)
}

#count in term genes nums
count_gene <- function(x, ref.num, target.num){
    return(x["geneList"])
}

extract_GO_ID <- function(x){
  return(strsplit(x, "|", fixed=T)[[1]][1])
}

extract_GO_name <- function(x){
  return(strsplit(x, "|", fixed=T)[[1]][2])
}

# GO enrichment
GO_enrichment <- function(goa_mat, target_gene_list, cutoff, outFile){
  ref_gene_num <- dim(goa_mat)[2]-1 #first column is GO ID
  target_gene_num <- length(target_gene_list)
  dat_for_enrichment <- data.frame(refList=rowSums(goa_mat[,-1]), geneList=rowSums(goa_mat[, ..target_gene_list]))
  rownames(dat_for_enrichment) <- goa_mat[, go_id]
  dat_for_enrichment$pvalue <- apply(dat_for_enrichment, 1, fisher_test, ref.num=ref_gene_num, target.num=target_gene_num)
  dat_for_enrichment$qvalue <- p.adjust(dat_for_enrichment$pvalue, method = "BH")
  dat_for_enrichment$geneintermnums <- apply(dat_for_enrichment, 1, count_gene, ref.num=ref_gene_num, target.num=target_gene_num)
  #output <- dat_for_enrichment[dat_for_enrichment$qvalue<=cutoff, ]
  output <- dat_for_enrichment[dat_for_enrichment$pvalue<=cutoff, ]
  if(dim(output)[1] > 1){
    output$GO <- unlist(lapply(rownames(output), extract_GO_ID))
    output$description <- unlist(lapply(rownames(output), extract_GO_name))
    output <- output[order(output$qvalue), c("GO", "description", "pvalue", "qvalue", "geneintermnums")]
    #output <- output[order(output$qvalue),]
    output$pvalue <- format(output$pvalue, scientific = T, digits = 3)
    output$qvalue <- format(output$qvalue, scientific = T, digits = 3)
    #output$geneintermnums <- format(output$genecounts)
    write.table(output, outFile, sep = '\t', row.names = F, col.names = T, quote = F)
   }else{
    print(paste0("no GO term passed the filtration: FDR < ", cutoff))
  }
}

Pcutoff <- 0.05


# get target module gene in specific type
enstp_out <- rownames(target_gene)
enstp <- enstp_out[enstp_out %in% ensg_has_go]

GO_enrichment(BP_mat, enstp, Pcutoff, paste0(outDir, '.correlated.gene.BP.txt'))
GO_enrichment(MF_mat, enstp, Pcutoff, paste0(outDir, '.correlated.gene.MF.txt'))


