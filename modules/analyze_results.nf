#!/usr/bin/env nextflow

// defines process to perform downsampling

// set dsl version
nextflow.enable.dsl=2

process analyze_results {
    publishDir("$params.results_folder", mode: "copy", overwrite: false)

    input:
        val results_filepath
        val true_proportions_path
    output:
        path("deconvolution_analysis_*")

    script:
    """
    Rscript $params.analyze_results_script -r $results_filepath -t $true_proportions_path
    """
}