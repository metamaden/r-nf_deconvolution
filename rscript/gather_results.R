#!/usr/bin/env R

# Author: Sean Maden
#
# Gather deconvolution results from run.
#
#

#----------------
# parse filenames
#----------------
filt.str <- 'deconvolution_analysis.*'
results.dir <- "results"
lfv <- list.files(results.dir)
lfv.filt <- lfv[grepl(filt.str, lfv)]

#-------------------
# load and bind data
#-------------------
dfres <- do.call(rbind, lapply(lfv.filt, function(fni){
  dfi <- read.csv(file.path(results.dir, fni))
  dfi[,2:ncol(dfi)]
}))

#--------------------
# append rmse by type
#--------------------
res.colnames <- colnames(dfres)
unique.types <- unique(res.colnames[])

#-------------
# save results
#-------------
# get results filename
ts <- as.character(as.numeric(Sys.time()))
new.filename <- paste0("results_table_",ts,".csv")

# save results table
write.csv(dfres, file = new.filename, row.names = FALSE)
