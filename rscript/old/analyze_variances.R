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
parser$add_argument("-b", "--batch_correction_method", type="character", default="combat",
                    help="Method to adjust for batch effects. Either 'combat', 'combatseq', or 'limma'.")
parser$add_argument("-z", "--convert_negative_values_to_zero", type="logical", default=TRUE,
                    help="Whether to convert negative values to zero's after batch adjustment.")
parser$add_argument("-k", "--k_celltype_variable", type="character", default="celltype",
                    help="Name of cell type variable, which should be in sce colData colnames.")
parser$add_argument("-d", "--batch_effect_variable", type="character", default="donor",
                    help="Name of the batch effects variable, which should be in sce colData colnames.")
parser$add_argument("-a", "--assay_name", type="character", default="counts",
                    help="Name of assay to use for adjustments, downsampling.")

args <- parser$parse_args()

#------------
# main script
#------------
# parse provided arguments
sce.filepath <- args$sce_read_filepath
batch.method <- arg$batch_correction_method
type.variable <- arg$k_celltype_variable
batch.variable <- arg$batch_effect_variable
assay.name <- arg$assay_name
convert.zero <- arg$convert_negative_values_to_zero

# load sce
sce <- get(load(args$readfpath))

# parse assay name
if(!assay.name %in% names(assays(sce))){stop("Error, couldn't find provided assay in sce assays.")}

# get model matrix from variables
typev <- sce[[type.variable]]
batchv <- sce[[batch.variable]]
pheno <- data.frame(batch = typev, type = typev)
mod <- model.matrix(~type, data = pheno)

# parse batch correction method
mexpr <- assays(sce)[[assay.name]]
if(batch.method == "combat"){
	message("Performing batch correction with: sva::ComBat()...")
	mi.adj <- ComBat(dat = mexpr, batch = pheno$batch, mod = mod)
} else if(batch.method == "combat_seq"){
	message("Performing batch correction with: sva::ComBat_seq()...")
	mi.adj <- ComBat_seq(counts = mexpr, batch = pheno$batch, group = pheno$type)
} else if(batch.method == "limma"){
	message("Performing batch correction with: limma::removeBatchEffect()...")
	mi.adj <- removeBatchEffect(mexpr, batch = pheno$batch, covariates = mod)
} else{
	stop("Error, didn't recognize provided batch correction method.")
}

if(convert.zero){message("Converting negative values to zero's..."); mi.adj[mi.adj < 0] <- 0}

# append to sce
assay.name.new <- paste0(assay.name, "_adj")
assays(sce)[[assay.name.new]] <- mi.adj

# downsample batches by types
sce <- do.call(cbind, lapply(utypev, function(ti){
	message("Working on cell type: ",ti, "...")
	# get filtered data
  	scef <- sce[,sce[[typevar]]==ti]; batchv <- scef[[batchvar]] 
  	mexpr <- assays(scef)[[assay.name.new]]
  	# downsample
  	mexpr.ds <- downsampleBatches(mexpr, batch = batchv) 
  	assays(scef)[[assay.name.new]] <- mexpr.ds; scef
}))

# save new sce
new.fname <- paste0(gsub("\\..*", "", read.fpath), "_batch-adj-",batch.method)
new.fname <- paste0(new.fname, ".rda")
message("Saving new file: ", new.fname)
save(scef, file = new.fname)