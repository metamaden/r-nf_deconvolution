#!/usr/bin/env sh

# Author: Sean Maden
#
# Install conda dependencies.
#

# params
newenv_name=r-nf_deconvolution

# make new env
conda create --name $newenv_name r=4.2.0
conda activate $newenv_name

# install bioconductor dependencies
conda install -c bioconda bioconductor-summarizedexperiment
conda install -c bioconda bioconductor-singlecellexperiment

# install deconvolution methods
# install nnls
conda install -c conda-forge r-nnls
# install music and dependencies
# install.packages(c("nnls", "ggplot2", "TOAST", "Biobase", "MCMCpack"), repos="http://cran.r-project.org")
conda install -c conda-forge r-ggplot2
conda install -c conda-forge toast
conda install -c bioconda bioconductor-biobase
conda install -c conda-forge r-mcmcpack
git clone https://github.com/xuranw/MuSiC MuSiC
R CMD INSTALL MuSiC
