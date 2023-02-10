#!/usr/bin/env R

# Author: Sean Maden
#
# Prepare example using lung adenocarcinoma references from `sc_mixology` 
# (Tian et al 2019).
#

#-------------
# manage paths
#-------------
download.script.fpath <- "./rscript/download_lung-adeno-sce.R"
dest.dir <- "data"
sce.rdata <- "sincell_with_class.RData"
destpath <- paste0("./",dest.dir,"/", sce.rdata)

#--------------------
# parse data download
#--------------------
# download example data
data.status <- source(download.script.fpath)

#----------
# load data
#----------
if(is(data.status, "try-error")){
  stop("Error, couldn't load data. Check destination folder at ", dest.dir,".")
} else{
  load(destpath)
}

#----------------------
# save true proportions
#----------------------