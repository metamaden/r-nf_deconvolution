#!/usr/bin/env R

# Author: Sean Maden
#
# Get RMSE, bias, and other evaluations from true and predicted proportions.
#
#


libv <- c("argparse")
sapply(libv, library, character.only = T)

#-----------------
# helper functions
#-----------------
bias <- function(true.proportions, pred.proportions){
  true.proportions - pred.proportions
}

rmse_types <- function(true.proportions, pred.proportions){
 error <- bias(true.proportions, pred.proportions)
 rmse <- sqrt(mean(error)^2)
 return(rmse)
}

#--------------
# manage parser
#--------------
parser <- ArgumentParser() # create parser object

# data arguments
parser$add_argument("-r", "--results_data", type="character",
                    help = paste0("Results output data"))
parser$add_argument("-t", "--true_proportions", type="character", 
                    default="./data/true-proportions.rda",
                    help = paste0("The filepath to the true proportions data."))

# get parser object
args <- parser$parse_args()

#-------------
# get analyses
#-------------
# load results
results.old.fpath <- args$results_data
results.old <- read.csv(results.old.fpath)
results.old <- results.old[,3:ncol(results.old)]
# get true proportions
true.prop.fname <- args$true_proportions
true.prop <- get(load(true.prop.fname))
true.prop <- as.numeric(true.prop)
# get predicted proportions
pred.prop.matrix <- results.old[,grepl("^type.*", colnames(results.old))]
pred.prop <- as.numeric(pred.prop.matrix[1,])

# do analyses
# get biases
bias.vector <- bias(true.prop, pred.prop)
bias.names <- paste0("bias_type", seq(length(bias.vector)))
# get rmse across cell types
rmse.types <- rmse_types(true.prop, pred.prop)
rmse.name <- "rmse_types"

#---------------
# return results
#---------------
# get results matrix
# get analyses as matrix
analysis.matrix <- matrix(c(rmse.types, bias.vector), nrow = 1)
colnames(analysis.matrix) <- c(rmse.name, bias.names)
# bind tables
rownames(results.old) <- rownames(analysis.matrix) <- "NA"
results.new <- cbind(results.old, analysis.matrix)

# save new results
ts <- as.character(as.numeric(Sys.time()))
fname <- paste0("deconvolution_analysis_", ts, ".csv")
write.csv(results.new, file = fname)