#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/rarediseaserefs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/rarediseaserefs
    Website: https://nf-co.re/rarediseaserefs
    Slack  : https://nfcore.slack.com/channels/rarediseaserefs
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { RAREDISEASEREFS         } from './workflows/rarediseaserefs'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_rarediseaserefs_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_rarediseaserefs_pipeline'
include { getGenomeAttribute      } from './subworkflows/local/utils_nfcore_rarediseaserefs_pipeline'
include { parseSkipList           } from './subworkflows/local/utils_nfcore_rarediseaserefs_pipeline'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow NFCORE_RAREDISEASEREFS {

    take:
    samplesheet // channel: samplesheet read in from --input

    main:

    //
    // WORKFLOW: Run pipeline
    //
    skip_gnomad_mt          = parseSkipList(params.skip_downloads, 'gnomad_mt')
    skip_gnomad_nuclear_snv = parseSkipList(params.skip_downloads, 'gnomad_nuclear_snv')
    skip_gnomad_nuclear_sv  = parseSkipList(params.skip_downloads, 'gnomad_nuclear_sv')

    RAREDISEASEREFS (
        skip_gnomad_mt,
        skip_gnomad_nuclear_snv,
        skip_gnomad_nuclear_sv,
        params.gnomad_version_mt,
        params.gnomad_version_snv,
        params.gnomad_version_sv
    )

    emit:
    gnomad_mt          = RAREDISEASEREFS.out.gnomad_mt
    gnomad_nuclear_snv = RAREDISEASEREFS.out.gnomad_nuclear_snv
    gnomad_nuclear_sv  = RAREDISEASEREFS.out.gnomad_nuclear_sv
    multiqc_report     = RAREDISEASEREFS.out.multiqc_report // channel: /path/to/multiqc_report.html
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input,
        params.help,
        params.help_full,
        params.show_hidden
    )

    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_RAREDISEASEREFS (
        PIPELINE_INITIALISATION.out.samplesheet
    )
    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        NFCORE_RAREDISEASEREFS.out.multiqc_report
    )

    publish:
    gnomad_mt          = NFCORE_RAREDISEASEREFS.out.gnomad_mt
    gnomad_nuclear_snv = NFCORE_RAREDISEASEREFS.out.gnomad_nuclear_snv
    gnomad_nuclear_sv  = NFCORE_RAREDISEASEREFS.out.gnomad_nuclear_sv
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

output {
    gnomad_mt {
        path 'gnomad'
    }
    gnomad_nuclear_snv {
        path 'gnomad'
    }
    gnomad_nuclear_sv {
        path 'gnomad'
    }
}
