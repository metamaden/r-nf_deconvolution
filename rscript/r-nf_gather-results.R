#!/usr/bin/env R

# Author: Sean Maden
#
# Gather deconvolution results from run.
#
#

#--------------
# manage params
#--------------
cname.type.labels <- "type.labels"
filt.str.pred.prop <- "^pred\\.prop\\..*"
filt.str.pred.prop <- "^pred\\.prop\\..*"

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
if(cname.type.labels %in% colnames(dfres)){
  unique.types <- unique(dfres[,cname.type.labels])
  df.rmse <- do.call(cbind, lapply(unique.types, function(typei){
    cname.str <- paste0(filt.str.pred.prop, typei)
    pred.prop <- dfres[,grepl(cname.str, res.colnames)]
    cname.str <- paste0(filt.str.true.prop, typei)
    true.prop <- dfres[,grepl(cname.str, res.colnames)]
    rmsei <- sqrt(mean((pred.prop-true.prop)^2))
    rep(rmsei, nrow(dfres))
  }))
} else{
  message("Didn't find any columns called 'type.labels' Skipping within-type RMSEs...")
}

#-------------
# save results
#-------------
# get results filename
ts <- as.character(as.numeric(Sys.time()))
new.filename <- paste0("results_table_",ts,".csv")

# save results table
write.csv(dfres, file = new.filename, row.names = FALSE)
