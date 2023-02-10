#!/usr/bin/env sh

# Author: Sean Maden
#
# Run a nextflowr workflow.
#
#

# params
rscript_dir=rscript
write_param_script=write_params.R
gather_script=gather_results.R

# update param.config
echo "updating params.config..."
Rscript ./$rscript_dir/$write_param_script

# run main workflow
echo "running workflow..."
nextflow run main.nf

# gather results into table
echo "gathering results table..."
Rscript ./$rscript_dir/$gather_script

echo "finished nextflowr workflow"