#!/usr/bin/env R

# Author: Sean Maden
#
# Get RMSE, bias, and other evaluations from true and predicted proportions.
#
#

libv <- c("argparse")
sapply(libv, library, character.only = T)

#-------------
# parse params
#-------------
# loaded results params
colname.type.labels <- "type.labels"
filt.str.prop.pred <- "^prop.pred."

# new results params
bias.cname.str <- "bias.type"
rmse.types.cname.str <- "rmse.types"
cname.prop.true.str <- "prop.true.type"

# return file params
fname.stem <- "deconvolution_analysis_"
fname.ext <- ".csv"

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

#----------
# load data
#----------
# load results
results.old.fpath <- args$results_data
results.old <- read.csv(results.old.fpath)
results.old <- results.old[,3:ncol(results.old)]

# get true proportions
true.prop.fname <- args$true_proportions
true.prop <- get(load(true.prop.fname))

#-----------------------
# parse true proportions
#-----------------------
# check for type.labels column
if(colname.type.labels %in% colnames(results.old)){
  type.labels <- unlist(strsplit(results.old[,colname.type.labels], ";"))
} else{
  stop("Error, no column called '",colname.type.labels,"' in loaded results.")
}

# check label overlap
true.prop.labels <- names(true.prop)
true.prop.labels <- true.prop.labels[true.prop.labels %in% type.labels]
if(length(true.prop.labels)==0){
  stop("Error, no overlap of type labels in true proportions data.")}

# check for duplicated labels
if(length(which(duplicated(true.prop.labels))) > 0){
  stop("Error, duplicated type labels in true proportions.")
}

# match order
label.order <- order(match(true.prop.labels, type.labels))
true.prop <- true.prop[label.order]

# get predicted proportions
filt.pred <- grepl(filt.str.prop.pred, colnames(results.old))
pred.prop.matrix <- results.old[,filt.pred]
pred.prop <- as.numeric(pred.prop.matrix[1,])
names(pred.prop) <- gsub(filt.str.prop.pred, "", 
                         colnames(pred.prop.matrix))

#-----------------
# perform analyses
#-----------------
# get biases
bias.vector <- bias(true.prop, pred.prop)
bias.names <- paste0(bias.cname.str, seq(length(bias.vector)))
# get rmse across cell types
rmse.types <- rmse_types(true.prop, pred.prop)

#---------------
# return results
#---------------
# get results matrix
mres <- matrix(c(true.prop, rmse.types, bias.vector), nrow = 1)
cnames.true.prop <- paste0(cname.prop.true.str, seq(length(true.prop)))
colnames(mres) <- c(cnames.true.prop, rmse.types.cname.str, bias.names)
# bind tables
rownames(results.old) <- rownames(mres) <- "NA"
results.new <- cbind(results.old, mres)

# save new results
ts <- as.character(as.numeric(Sys.time()))
fname <- paste0(fname.stem, ts, fname.ext)
write.csv(results.new, file = fname)