#!/usr/bin/env nextflow

// defines process to perform downsampling

// set dsl version
nextflow.enable.dsl=2

process predict_proportions {
    publishDir("$params.results_folder", mode: "copy", overwrite: false)

    input:
        val sce_filepath
        val deconvolution_method
        val assay_name
    output:
        path("deconvolution_results_*")

    script:
    """
    Rscript $params.predict_proportions_script -r $sce_filepath -d $deconvolution_method -a $assay_name
    """
}