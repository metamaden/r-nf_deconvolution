#!/usr/bin/env nextflow

// This is the main workflow script for example 4.

// set dsl version
nextflow.enable.dsl=2

// include modules for workflow

include { predict_proportions as predict_prop } from "$launchDir/modules/predict_proportions"
include { analyze_results as analyze_res } from "$launchDir/modules/analyze_results"

// define a new workflow
workflow {
    
    // parse channels
    sce = channel.fromList( params.sce_filepath )
    method = channel.fromList( params.decon_method )
    assay = channel.fromList( params.assay_name )
    true_proportions_path = channel.fromList( params.true_proportions_path )
    
    // run workflow
    predict_prop( sce, method, assay )
    predict_prop.out.view()
    analyze_res( predict_prop.out, true_proportions_path )
}

workflow.onComplete {
    println "Pipeline successfully completed at: $workflow.complete"
}

workflow.onError {
    println "Pipeline stopped with following error: $workflow.errorMessage"
}

