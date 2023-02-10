#!/usr/bin/env Rscript

# Author: Sean Maden
#
# Get the top markers using DeconvoBuddies::get_mean_ratio2()
#

# libv <- c("DeconvoBuddies", "dplyr", "SingleCellExperiment", "SummarizedExperiment")
libv <- c("scran", "scuttle", "SingleCellExperiment", "SummarizedExperiment")
sapply(libv, library, character.only = T)

# manage parser
suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser() # create parser object
parser$add_argument("-r", "--readfpath", type="character", 
                    default="./data/sce-example.rda",
                    help = paste0("Path to SingleCellExperiment object to read."))
parser$add_argument("-t", "--numtopmarkers", type="double", default=20,
                    help="Number of markers to get per type.")
parser$add_argument("-a", "--assayname", type="character", default="logcounts",
                    help="Name of assay in sce to use to identify top markers.")

args <- parser$parse_args()

#------------
# main script
#------------
# params
read.fpath <- args$readfpath
aname <- args$assayname
celltype.varname <- "celltype"
nmarker <- args$numtopmarkers

# load sce
sce <- get(load(args$readfpath))

# parse assay name
if(!aname %in% names(assays(sce))){
  if(aname == "logcounts"){
    sce <- scuttle::logNormCounts(sce)
  } else{
    stop("Error, invalid assayname.")
  }
}

# get markers
#mr <- get_mean_ratio2(sce = sce, cellType_col = celltype.varname, 
#                      assay_name = aname, add_symbol = F)
mr <- findMarkers(assays(sce)[[aname]], groups = sce[["celltype"]])

# get top markers
typev <- unique(sce[[celltype.varname]])
#mr.top <- do.call(rbind, lapply(typev, function(typei){
#  mr %>% filter(cellType.target == typei) %>% 
#    arrange(rank_ratio) %>%
#    top_n(n = nmarker)
#}))
mr.top <- do.call(rbind, lapply(typev, function(typei){
  mri <- mr[[typei]]; mri$type <- typei
  mri <- mri[rev(order(mri$summary.logFC)),]
  as.data.frame(mri[seq(nmarker), c(seq(4), 6)])
}))

# save new markers
mr.fnstem <- paste0("mr-filt_mr2-t-", nmarker, "-a-",aname)
mr.fname <- paste0(mr.fnstem,".rda")
save(mr.top, file = mr.fname)

# get top genes
# genev <- mr.top$gene
genev <- rownames(mr.top)
# filter sce
scef <- sce[genev,]

# save new sce
new.fname <- paste0(gsub("\\..*", "", read.fpath), 
                    "_mr2-t-", as.character(nmarker), 
                    "-a-", aname)
new.fname <- paste0(new.fname, ".rda")
message("saving new file: ", new.fname)
save(scef, file = new.fname)