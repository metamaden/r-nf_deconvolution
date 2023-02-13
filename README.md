# decon_devmethod_workflow

Nextflow workflow for deconvolution method development and benchmarking.

# Setup

From the top level of `r-nf_deconvolution`, run the following:

```
conda env create -f ./yml/r-nf_deconvolution.yml
```

Activate the new environment with:

```
conda activate r-nf_deconvolution
```

You should now be ready to run `nextflowr-deconvolution` (continue reading).

# Quick start

Use a terminal to navigate to the top level of `nextflowr-deconvolution` and run the following:

```
sh ./sh/r-nf.sh
```

This should use example data to produce a series of outputs. The main outputs are stored at the top level in a .csv file called `results_table_*.csv`.