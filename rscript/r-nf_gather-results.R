#!/usr/bin/env R

# Author: Sean Maden
#
# Gather deconvolution results from run.
#
#

#--------------
# manage params
#--------------
type.labels.cname <- "type_labels"
filt.str.pred <- "^prop\\.pred\\."
filt.str.true <- "^prop\\.true\\."

# filenames
fname.str <- 'deconvolution_analysis_.*'

# publish directory path
publish.dir <- "results"

method.cname <- "deconvolution_method"

#----------------
# parse filenames
#----------------
lfv <- list.files(publish.dir)
lfv.filt <- lfv[grepl(fname.str, lfv)]

#-------------------
# load and bind data
#-------------------
dfres <- do.call(rbind, lapply(lfv.filt, function(fni){
  dfi <- read.csv(file.path(publish.dir, fni))
  dfi[,2:ncol(dfi)]
}))

#--------------------
# append rmse by type
#--------------------
res.colnames <- colnames(dfres)
if(type.labels.cname %in% colnames(dfres)){
  message("Getting RMSE within types...")
  cnvf <- colnames(dfres)
  cnvf <- cnvf[grepl(filt.str.pred, cnvf)]
  unique.types <- unique(gsub(".*\\.", "", cnvf))
  df.rmse <- do.call(cbind, lapply(unique.types, function(typei){
    cname.pred.str <- paste0(filt.str.pred, typei)
    cname.true.str <- paste0(filt.str.true, typei)
    pred.prop <- dfres[,grepl(cname.pred.str, res.colnames)][1]
    true.prop <- dfres[,grepl(cname.true.str, res.colnames)][1]
    pred.prop <- as.numeric(pred.prop)
    true.prop <- as.numeric(true.prop)
    rmsei <- sqrt(mean((pred.prop-true.prop)^2))
    rep(rmsei, nrow(dfres))
  }))
  colnames(df.rmse) <- paste0("rmse.", unique.types)
  dfres <- cbind(dfres, df.rmse)
} else{
  message("Didn't find any columns called '",type.labels.cname,"'. ",
          "Skipping within-type RMSE calculation...")
}

#----------------------
# append rmse by method
#----------------------
if(method.cname %in% colnames(dfres)){
  message("Getting RMSE by method...")
  cnvf <- colnames(dfres)
  cnvf <- cnvf[grepl(method.cname, cnvf)]
  unique.methods <- unique(dfres[,cnvf])
  df.rmse.method <- do.call(cbind, lapply(unique.methods, function(methodi){
    method.filt <- dfres[,method.cname]==methodi
    dff <- dfres[method.filt,]
    truev <- unlist(dff[,grepl(filt.str.true, colnames(dff))])
    predv <- unlist(dff[,grepl(filt.str.pred, colnames(dff))])
    truev <- as.numeric(truev)
    predv <- as.numeric(predv)
    rmsei <- sqrt(mean((predv-truev)^2))
    rep(rmsei, nrow(dfres))
  }))
  colnames(df.rmse.method) <- paste0("rmse.", unique.methods)
  dfres <- cbind(dfres, df.rmse.method)
} else{
  message("Didn't find any columns called '",method.cname,"'. ",
          "Skipping within-method RMSE calculation...")
}

#-------------
# save results
#-------------
# get results filename
ts <- as.character(as.numeric(Sys.time()))
new.filename <- paste0("results_table_",ts,".csv")

# save results table
write.csv(dfres, file = new.filename, row.names = FALSE)
