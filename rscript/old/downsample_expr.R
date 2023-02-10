#!/usr/bin/env Rscript

# Author: Sean Maden
#
# Perform downsampling using scuttle.
#

libv <- c("lute", "scuttle", "SingleCellExperiment", "SummarizedExperiment")
sapply(libv, library, character.only = T)

# manage parser
suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser() # create parser object
parser$add_argument("-r", "--readfpath", type="character", 
                    default="./data/sce-example.rda",
                    help = paste0("Path to SingleCellExperiment object to read."))
parser$add_argument("-d", "--downsample", type="logical", default=TRUE,
                    help="Whether to perform downsampling.")
parser$add_argument("-m", "--method", type="character", default="scuttle",
                    help="Method to use for downsampling.")
parser$add_argument("-a", "--assayname", type="character", default="logcounts",
                    help="Name of assay in sce to downsample.")

args <- parser$parse_args()

#------------
# main script
#------------
# params
read.fpath <- args$readfpath
assay.name <- args$assayname
down.sample.cond <- args$downsample
down.sample.method <- args$method

# load sce
sce <- get(load(args$readfpath))

# parse assay name
if(!assay.name %in% names(assays(sce))){
  if(assay.name == "logcounts"){
    sce <- scuttle::logNormCounts(sce)
  } else{
    stop("Error, invalid assayname.")
  }
}

# parse downsampling options
if(down.sample.cond){
	new.mexpr <- mexpr_downsample(assays(sce)[[assay.name]])
	new.assay.name <- paste0(assay.name, "_ds")
	assays(sce)[[new.assay.name]] <- new.mexpr
}

# save new sce
new.fname <- gsub("\\..*", "", read.fpath)
new.fname <- paste0(new.fname, 
                    "_ds",
                    "-d-", as.character(down.sample.cond), 
                    "-m-", as.character(down.sample.method),
                    "-a-", as.character(assay.name))
new.fname <- paste0(new.fname, ".rda")
message("saving new file: ", new.fname)
save(scef, file = new.fname)