#!/usr/bin/env R

# Author: Sean Maden
#
# Utilities supporting r-nf workflow meta-objects.
#

save_sce_data <- function(sce.names, celltypevariable = "celltype", 
                          data.dir = "data", overwrite = TRUE){
  # save_sce_data
  # 
  # sce.names : Vector of names of SingleCellExperiment or SummarizedExperiment 
  # objects in memory.
  # celltypevariable : Name of variable in sce colData with cell type labels.
  # data.dir : Name of folder to save new data.
  #
  message("Saving data for ", length(sce.names), " sce objects...")
  for(scei in sce.names){
    message("working on sce object ", scei, "...")
    sce <- eval(parse(text = scei))
    # save sce object
    new.fname <- paste0(scei, ".rda")
    new.fpath <- file.path(data.dir, new.fname)
    if(file.exists(new.fpath) & !overwrite){
      message("Warning, found existing object at ", 
              new.fpath, ". Skipping new file save...")
    } else{
      save(sce, file = new.fpath)
    }
    
    # get true proportions
    true.labels <- sce[[true.label.variable]]
    freq.labels <- table(true.labels)
    prop.labels <- freq.labels/sum(freq.labels)
    true.proportions <- as.numeric(prop.labels)
    names(true.proportions) <- names(freq.labels)
    # save true proportions
    new.fname <- paste0(true.prop.fname.stem, scei, ".rda")
    new.fpath <- file.path(dest.dir, new.fname)
    if(file.exists(new.fpath) & !overwrite){
      message("Warning, found existing object at ", 
              new.fpath, ". Skipping new file save...")
    } else{
      save(true.proportions, file = new.fpath)
    }
  }
  message("Finished with all sce datasets.")
  return(TRUE)
}

new_workflow_table <- function(sce.names = NULL, data.dir = "data",
                               true.prop.fname.stem = "true_proportions_",
                               celltype.variable = "celltype",
                               colnames = c("sce_filepath", 
                                            "true_proportions_path", 
                                            "decon_method", "decon_args", 
                                            "run_info", "assay_name", 
                                            "celltype_variable"),
                               table.dir = ".", table.fname = "workflow_table.csv",
                               overwrite = TRUE){
  # new_workflow_table
  #
  # Begins a new workflow table.
  # 
  # sce.names : Vector of sce/se filenames. If left NULL, writes an example table.
  # data.dir : Name of folder containing sce data objects.
  # true.prop.fname.stem : Beginning filename stem of true proportions data objects.
  # celltype.variable : Name of celltype variable in sce colData.
  # colnames : Column names of the workflow table.
  # table.fname : Filename of new workflow table to write.
  # overwrite : Whether to overwrite an existing workflow table.
  #
  
  # parse overwrite
  table.fpath <- file.path(table.dir, table.fname)
  if(file.exists(table.fpath) & !overwrite){
    message("Found existing workflow table at path ", table.fpath, 
            ". Skipping new table save.")
    return(FALSE)
  }
  
  # start new table
  dfnew <- matrix(nrow = 0, ncol = length(colnames))
  
  # get template row
  newline <- c(file.path("$launchDir", data.dir),  # sce path
               file.path("$launchDir", data.dir), # true proportions path
               "nnls",                            # deconvolution method
               "NA",                              # additional arguments
               "lung_adeno_first_benchmark",      # run label
               "counts",                          # assay name
               celltype.variable)                 # celltype variable name
  
  # update object paths
  check.files <- TRUE
  if(is(sce.names, "NULL")){
    message("Writing example table...")
    sce.names <- "[SCE_FILENAME_HERE]"
    check.files <- FALSE
  }
  for(scei in sce.names){
    message("Working on sce object ", scei, "...")
    linei <- newline
    # check data files
    sce.fpath <- file.path(data.dir, paste0(scei, ".rda"))
    sce.exists <- file.exists(sce.fpath)
    tp.fpath <- paste0(true.prop.fname.stem, scei, ".rda")
    tp.exists <- file.exists(file.path(data.dir, tp.fpath))
    if(check.files){
      if(!sce.exists){
        message("Didn't find file ",sce.fpath,". Skipping data write.")
      } else if(!tp.exists){
        message("Didn't find file ",tp.fpath,". Skipping data write.")
      } else{
        
      }
    }
    linei[1] <- file.path(linei[1], paste0(scei, ".rda"))
    linei[2] <- file.path(linei[2], 
                          paste0(true.prop.fname.stem, scei, ".rda"))
    linei[1] <- paste0('"', linei[1], '"')
    linei[2] <- paste0('"', linei[2], '"')
    dfnew <- rbind(dfnew, linei)
  }
  colnames(dfnew) <- colnames
  
  # save
  write.csv(dfnew, file = table.fpath, row.names = FALSE)
  return(TRUE)
}