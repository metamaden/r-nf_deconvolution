#!/usr/bin/env R

# Author: Sean Maden
#
# Prepare example using lung adenocarcinoma references from `sc_mixology` 
# (Tian et al 2019).
#

#------------------------
# manage params and paths
#------------------------
# data dir paths
dest.dir <- "data"
sce.rdata <- "sincell_with_class.RData"
destpath <- paste0("./",dest.dir,"/", sce.rdata)

# script paths
scripts.dir <- "rscript"
download.script.fpath <- file.path(scripts.dir, "download_lung-adeno-sce.R")
utilities.script.fpath <- file.path(scripts.dir, "r-nf_utilities.R")

# variables
true.label.variable <- "cell_line_demuxlet"

# new filenames
sce.names <- c("sce_sc_10x_qc", "sce_sc_CELseq2_qc", "sce_sc_Dropseq_qc")
true.prop.fname.stem <- "true_proportions_"
workflow.table.fname <- "workflow_table.csv"

#-----------------
# source utilities
#-----------------
source(utilities.script.fpath)

#--------------------
# parse data download
#--------------------
data.status <- source(download.script.fpath)

#----------
# load data
#----------
if(is(data.status, "try-error")){
  stop("Error, couldn't load data. Check destination folder at ", dest.dir,".")
} else{
  load(destpath)
}

# get object names
ls()

#----------------------
# save new example data
#----------------------
data.save.status <- try(save_sce_data(sce.names, 
                                      celltypevariable = "celltype",
                                      data.dir = "data", overwrite = FALSE))

if(is(data.save.status, "logical") & data.save.status==TRUE){
  message("Data save success.")
} else{
  message("Data save failure. Result: ", data.save.status)
}

#-----------------------------
# begin new workflow_table.csv
#-----------------------------
new_workflow_table(sce.names, data.dir = dest.dir, 
                   true.prop.fname.stem = true.prop.fname.stem,
                   celltype.variable = true.label.variable)
