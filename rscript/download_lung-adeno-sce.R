#!/usr/bin/env R

# Author: Sean Maden
#
# Download lung adenocarcinoma example data from sc_mixology (Tian et al 2019).
#

# manage params
dest.dir <- "data"
sce.rdata <- "sincell_with_class.RData"
destpath <- paste0("./",dest.dir,"/", sce.rdata)
http <- "https://github.com/metamaden/sc_mixology/tree/master/data/"
download.fpath <- paste0(http, sce.rdata)

# check existing data
if(file.exists(destpath)){
  message("Found existing data .RData file -- skipping download.")
} else{
  download.file(url = download.fpath, destfile = destpath)
}
