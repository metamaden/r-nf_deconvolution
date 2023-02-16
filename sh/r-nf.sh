#!/usr/bin/env sh

# Author: Sean Maden
#
# Run an `r-nf` workflow.
#

# manage script paths
rscript_dir=rscript
write_param_script=r-nf_write-params.R
gather_script=r-nf_gather-results.R

# do r-nf run
echo "updating params.config..."
Rscript ./$rscript_dir/$write_param_script
echo "running workflow..."
nextflow run main.nf
echo "gathering results table..."
Rscript ./$rscript_dir/$gather_script

echo "finished r-nf run."
