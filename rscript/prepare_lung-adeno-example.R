#!/usr/bin/env R

# Author: Sean Maden
#
# Prepare example using lung adenocarcinoma references from `sc_mixology` 
# (Tian et al 2019).
#

# manage paths
download.script.fpath <- "./rscript/download_lung-adeno-sce.R"

# download example data
source(download.script.fpath)
