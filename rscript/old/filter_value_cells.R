#!/usr/bin/env Rscript

# Author: Sean Maden
#
# Command line-callable script to filter cells on values.
#

# require(lute)
libv <- c("SummarizedExperiment", "SingleCellExperiment")
sapply(libv, library, character.only = TRUE)

# manage parser
suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser() # create parser object
parser$add_argument("-r", "--readfpath", type="character", default="./data/sce-example.rda",
                    help = paste0("Path to SingleCellExperiment object to read."))
parser$add_argument("-m", "--maxzerofreq", type="double", default=0.3,
                    help="Maximum allowed frequency of zero-value genes.")
args <- parser$parse_args()

#------------
# main script
#------------
# params
max.zf <- args$maxzerofreq

# load sce
sce <- get(load(args$readfpath))
# filter sce
#scef <- filter_value_cells(sce, filter.term = "zerocount", verbose = T,
#                           max.value.freq = args$maxzerofreq)

# get zero freq
zerov.bygene <- apply(assays(sce)$counts, 1, function(ri){length(which(ri==0))})
zf.genev <- zerov.bygene/length(zerov.bygene)
zf.filt <- zf.genev > max.zf
scef <- sce[!zf.filt,]

# save filtered data
new.fname.param <- gsub("\\.", "", as.character(max.zf))
new.fname <- gsub("\\..*", "", args$readfpath)
new.fname <- paste0(new.fname, "_zfilt-m", new.fname.param)
new.fname <- paste0(new.fname, ".rda")
message("saving new file: ", new.fname)
save(scef, file = new.fname)