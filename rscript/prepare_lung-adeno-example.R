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
download.script.fpath <- "./rscript/download_lung-adeno-sce.R"

# variables
true.label.variable <- "cell_line_demuxlet"

# new filenames
sce.names <- c("sce_sc_10x_qc", "sce_sc_CELseq2_qc", "sce_sc_Dropseq_qc")
true.prop.fname.stem <- "true_proportions_"
workflow.table.fname <- "workflow_table.csv"

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
# save sce objects
for(scei in sce.names){
  sce <- eval(parse(text = scei))
  new.fname <- paste0(scei, ".rda")
  new.fpath <- file.path(dest.dir, new.fname)
  save(sce, file = new.fpath)
}

# save true proportions
for(scei in sce.names){
  sce <- eval(parse(text = scei))
  true.labels <- sce[[true.label.variable]]
  freq.labels <- table(true.labels)
  prop.labels <- freq.labels/sum(freq.labels)
  true.proportions <- as.numeric(prop.labels)
  names(true.proportions) <- names(freq.labels)
  # save
  new.fname <- paste0(true.prop.fname.stem, scei, ".rda")
  new.fpath <- file.path(dest.dir, new.fname)
  save(true.proportions, file = new.fpath)
}

#-----------------------------
# begin new workflow_table.csv
#-----------------------------
# start new table
dfnew <- matrix(nrow = 0, ncol = 6)

# get template row
newline <- c(file.path("$lunchDir", dest.dir),  # sce path
             file.path("$launchDir", dest.dir), # true proportions path
             "nnls",                            # deconvolution method
             "NA",                              # additional arguments
             "lung_adeno_first_benchmark",      # run label
             "counts")                          # assay name

# update object paths
for(scei in sce.names){
  linei <- newline
  linei[1] <- file.path(linei[1], scei)
  linei[2] <- file.path(linei[2], 
                        paste0(true.prop.fname.stem, 
                               scei, ".rda"))
}

# save
write.csv(dfnew, file = workflow.table.fname)










