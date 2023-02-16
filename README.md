# decon_devmethod_workflow

Nextflow workflow for deconvolution method development and benchmarking.

# Setup

## Virtual environment and dependencies

Scripts provided in the `sh` and `yml` folders show which dependencies are required and 
how to install them. For most runs, you will at minimum need a recent version of NextFlow, 
R, and the nnls, SummarizedExperiment, and SingleCellExperiment libraries, with additional 
required dependencies for other deconvolution methods besides the non-negative least 
squares (NNLS) method.

You can use the provided .yml file to set up a conda virtual environment. From the top 
level of `r-nf_deconvolution`, run the following:

```
conda env create -f ./yml/r-nf_deconvolution.yml
```

Activate the new environment with:

```
conda activate r-nf_deconvolution
```

You should now be ready to run `nextflowr-deconvolution`.

## Obtaining example data

Example datasets are contained in the `data` folder. Several setup .R scripts are provided in the `rscript` 
folder to download and prepare example data for a workflow run.

The lung adenocarcinoma dataset from `sc_mixology` (Tian et al 2019) can be downloaded and set up by running:

```
Rscript ./rscript/prepare_lung-adeno-example.R
```

# Quick start

Use a terminal to navigate to the top level of `nextflowr-deconvolution` and run the following:

```
sh ./sh/r-nf.sh
```

This should use example data to produce a series of outputs. The main outputs are stored at the top level in a .csv file called `results_table_*.csv`.
