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
if("typelabels" %in% colnames(dfres)){
  unique.types <- unique(dfres[,"typelabels"])
  df.rmse <- do.call(cbind, lapply(unique.types, function(typei){
    cname.str <- paste0("pred.", typei)
    pred.prop <- dfres[,grepl(cname.str, res.colnames)]
    cname.str <- paste0("true.", typei)
    true.prop <- dfres[,grepl(cname.str, res.colnames)]
    rmsei <- sqrt(mean((pred.prop-true.prop)^2))
    rep(rmsei, nrow(dfres))
  }))
} else{
  message("Didn't find any columns called 'typelabels.' Skipping within-type RMSEs...")
}

#-------------
# save results
#-------------
# get results filename
ts <- as.character(as.numeric(Sys.time()))
new.filename <- paste0("results_table_",ts,".csv")

# save results table
write.csv(dfres, file = new.filename, row.names = FALSE)
