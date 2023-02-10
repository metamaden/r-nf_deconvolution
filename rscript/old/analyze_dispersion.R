#!/usr/bin/env Rscript

# Author: Sean Maden
#
# Adjust on batch effects using either sva::ComBat, sva::ComBat_seq(), or limma::removeBatchEffects(). Also 
# perform down-sampling across batches by each specified cell type.
#

# libv <- c("DeconvoBuddies", "dplyr", "SingleCellExperiment", "SummarizedExperiment")
libv <- c("scran", "scuttle", "sva", "limma", "SingleCellExperiment", "SummarizedExperiment")
sapply(libv, library, character.only = T)

# manage parser
suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser() # create parser object
parser$add_argument("-r", "--sce_read_filepath", type="character", 
                    default="./data/sce-example.rda",
                    help = paste0("Path to SingleCellExperiment object to read."))
parser$add_argument("-a", "--assay_name", type="character", default="counts",
                    help="Name of assay to use for adjustments, downsampling.")
parser$add_argument("-k", "--k_celltype_variable", type="character", default="celltype",
                    help="Name of cell type variable, which should be in sce colData colnames.")
parser$add_argument("-h", "--highlight_markers", type="logical", default=FALSE,
                    help="Whether to highlight markers in plots.")
parser$add_argument("-k", "--marker_count", type="numeric", default=2,
                    help="Marker count of interest for plot highlights. Ignored unless -h is TRUE.")

args <- parser$parse_args()

#------------
# main script
#------------
# parse provided arguments
sce.filepath <- args$sce_read_filepath
type.variable <- arg$k_celltype_variable
highlight.markers <- arg$highlight_markers
assay.name <- arg$assay_name

# load sce
sce <- get(load(args$readfpath))

# parse marker highlight options
hl.markers <- FALSE
if(highlight.markers){
	mr.name <- paste0("")
	mr.top <- sce[[]]
}
# get dispersion scatter plots

# compute dispersions from fitted neg binom

# get dispersion distribution plots

# save new sce
new.fname <- paste0(gsub("\\..*", "", read.fpath), "_batch-adj-",batch.method)
new.fname <- paste0(new.fname, ".rda")
message("Saving new file: ", new.fname)
save(scef, file = new.fname)