#!/usr/bin/env R

# Author: Sean Maden
#
# Write params.config from a CSV file
#

#-------------
# manage paths
#-------------
worktable.fname <- "workflow_table.csv"
md.fname <- "params_metadata.csv"
params.fname <- "params.config"

#----------
# load data
#----------
con <- file(params.fname)
lp <- readLines(con)
wt <- read.csv(worktable.fname)
md <- read.csv(md.fname); rownames(md) <- md[,1]

#--------------------
# get new param lines
#--------------------
# get data to write
which.param <- which(md$type=="param")
variable.names <- md[which.param,]$variable
wt.colnames <- colnames(wt)
variables.provided <- intersect(variable.names, wt.colnames)

# make new lines
variable.lines <- lapply(variables.provided, function(variable.iter){
  append.str <- md[variable.iter,]$append_string
  append.str <- ifelse(is.na(append.str)|append.str=="NA", "", append.str)
  values <- paste0(append.str, wt[,variable.iter])
  values <- paste0('"', gsub('"', '', values), '"', collapse = ", ")
  paste0("    ", variable.iter, " = [", values, "]")
})

#---------------------
# update params.config
#---------------------
# get start line
line.start.str <- ".*// LIST CHANNEL INPUTS"
which.start <- which(grepl(line.start.str, lp))

# write params
new.lines <- lp[1:(which.start+1)]
new.lines <- c(new.lines, unlist(variable.lines), "}")
writeLines(text = new.lines, con = con)
