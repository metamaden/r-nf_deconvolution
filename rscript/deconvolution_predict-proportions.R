#!/usr/bin/env R

# Author: Sean Maden
#
# Run deconvolution functions on an SCE object, from command line.
#

libv <- c("nnls", "MuSiC", "SingleCellExperiment", "SummarizedExperiment", "argparse")
sapply(libv, library, character.only = T)

#-----------------
# parse parameters
#-----------------
# rscript.dir <- "$launchDir/rscript"
# decon.utils.scriptfname = "deconvolution_utilities.R"
# decon.utils.rscriptpath <- file.path(rscript.dir, decon.utils.scriptfname)

#-----------------
# source utilities
#-----------------
# source(decon.utils.rscriptpath)

#------------------
# helper functions
#------------------
predict_proportions <- function(Z, Y, strict.method = "nnls", 
                                method.args = "", verbose = FALSE, ...){
  # predict_proportions
  #
  # Z : signature matrix
  # Y : bulk matrix
  # strict_method : deconvolution method
  # method.args : additional method arguments
  # verbose : whether to show verbose messages
  #
  if(verbose){message("Getting cell type proportion predictions...")}
  
  # format string arguments
  cond <- method.args %in% c("", "NA")|is.na(method.args)
  if(!cond){
    method.args <- paste0(",",method.args)
  } else{
    method.args <- ""
  }
  method <- tolower(strict.method)
  
  # parse methods
  if(method == "nnls"){
    if(verbose){message("Using method nnls...")}
    command.string <- paste0("nnls::nnls(Z, Y",method.args,")$x")
  } else if(method == "music"){
    if(verbose){message("Using method MuSiC...")}
    if(method.args == ""){
      if(verbose){message("Getting mean library sizes by type...")}
      S <- unlist(lapply(unique.celltypes, function(ci){
        mean(colSums(mexpr[,cd[,celltype.variable]==ci]))
      }))
      if(verbose){message("Setting variances by gene...")}
      Sigma <- matrix(0, ncol = 1, nrow = nrow(Z))
      method.args <- ",S = S, Sigma = Sigma, nu = 1e-10, iter.max = 100, eps = 0"
    }
    command.string <- paste0("music.basic(Y = Y, X = Z",method.args,")$p.weight")
  } else{
    if(verbose){message("Returning unmodified point prediction outputs.")}
  }
  
  # get proportion predictions
  p <- eval(parse(text = command.string))
  if(verbose){message("Completed proportion predictions.")}
  return(p)
}


#--------------
# manage parser
#--------------
parser <- ArgumentParser() # create parser object

# data arguments
parser$add_argument("-r", "--sce_filepath", type="character", 
                    default="./data/sce-example.rda",
                    help = paste0("Expression reference dataset, ",
                                  "either an SCE or SE object."))
parser$add_argument("-b", "--bulkse", type="character", default="NA",
                    help = paste0("Bulk expression dataset, in SE format. ",
                                  "If NA, makes a pseudobulk from ",
                                  "provided SCE/SE reference expression data."))

# deconvolution parameters
parser$add_argument("-d", "--deconvolution_method", type="character", default="nnls",
                    help="Deconvolution method to use. Can be either of 'nnls' or 'music'.")
parser$add_argument("-t", "--time_run", type="logical", default=TRUE,
                    help="Whether to time the operation for benchmarking.")
parser$add_argument("-a", "--assay_name", type="character", default="counts",
                    help="Name of assay in reference expression data to use.")
parser$add_argument("-c", "--celltype_variable", type="character", default="celltype",
                    help="Reference ColData variable containing cell type labels.")
parser$add_argument("-f", "--method_args", type="character", default="NA",
                    help="Additional arguments for deconvolution functions.")

#-----------------------
# get flags as variables
#-----------------------
# get parser object
args <- parser$parse_args()

# parse provided arguments
sce.filepath <- args$sce_filepath
bulk.filepath <- args$bulkse
deconvolution.method <- args$deconvolution_method
# time.run <- args$time_run
assay.name <- args$assay_name
celltype.variable <- args$celltype_variable
method.args <- args$method_args

#-----------------------
# load data, with checks
#-----------------------
# get reference expression data
if(file.exists(sce.filepath)){
  sce <- get(load(sce.filepath))
  message("Reference data successfully loaded.")
} else{
  stop("Error, reference data not found at ",sce.filepath)
}

# get celltype metadata
cd <- colData(sce)
if(celltype.variable %in% colnames(cd)){
  celltype.vector <- sce[[celltype.variable]]
  unique.celltypes <- unique(celltype.vector)
} else{
  stop("Error, didn't find ", celltype.variable," in reference colData.")
}

# get signature matrix
if(assay.name %in% names(assays(sce))){
  mexpr <- assays(sce)[[assay.name]]
  Z <- do.call(cbind, lapply(unique.celltypes, function(ci){
    rowMeans(mexpr[,celltype.vector==ci])
  }))
} else{
  stop("Error, assay not found in reference data.")
}

# get bulk data
if(bulk.filepath == "NA"|is.na(bulk.filepath)){
  message("Making pseudobulk from reference data...")
  Y <- matrix(rowMeans(mexpr), ncol = 1)
} else if(file.exists(bulk.filepath)){
  Y <- get(load(bulk.filepath))
} else{
  stop("Error, couldn't get bulk data.")
}

#------------------
# run deconvolution
#------------------
t1 <- Sys.time()
if(deconvolution.method=='music'){
  unique.celltypes <- unique(sce[[celltype.variable]])
  pred.proportions <- predict_proportions(Z = Z, Y = Y, 
                                          strict.method = deconvolution.method,
                                          method.args = method.args,
                                          unique.celltypes = unique.celltypes)
} else{
  pred.proportions <- predict_proportions(Z = Z, Y = Y, 
                                          strict.method = deconvolution.method,
                                          method.args = method.args)
}

time.run <- Sys.time() - t1
time.run <- as.numeric(time.run)
names(time.run) <- "time.run.sec"

#---------------
# return results
#---------------
results.vector <- c()

# append params
results.vector["sce_filepath"] <- sce.filepath
results.vector["deconvolution_method"] <- tolower(deconvolution.method)
results.vector["method_arguments"] <- method.args
results.vector["assay_name"] <- assay.name
results.vector["type_labels"] <- paste0(unique.celltypes, collapse = ";")
results.vector["celltype_variable"] <- celltype.variable

# append proportions
names(pred.proportions) <- paste0("prop.pred.type", 
                                  seq(length(pred.proportions)))
results.vector <- c(results.vector, pred.proportions)

# append time, timestamp
results.vector <- c(results.vector, time.run, "timestamp" = as.numeric(t1))

# coerce to matrix
results.table <- t(as.data.frame(results.vector, nrow = 1))

# save new results
ts <- as.character(as.numeric(t1))
new.filename <- paste0("deconvolution_results_", as.numeric(t1), ".csv")
write.csv(results.table, file = new.filename, row.names = FALSE)

