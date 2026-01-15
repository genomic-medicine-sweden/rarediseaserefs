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
    if (params.cadd_mirror.equals("us")) {
        cadd_link           = "https://krishna.gs.washington.edu/download/CADD/v${params.cadd_version}/GRCh38"
    } else {
        cadd_link           = "https://kircherlab.bihealth.org/download/CADD/v${params.cadd_version}/GRCh38"
    }

    ch_cadd_annotations     = channel.of([
                                    [id:"cadd_" + params.cadd_version, version:params.cadd_version],
                                    cadd_link + "/GRCh38_v${params.cadd_version}.tar.gz"
                                    ])
    ch_cadd_scores          = channel.of([
                                    [id:"cadd_" + params.cadd_version, version:params.cadd_version],
                                    cadd_link + "/whole_genome_SNVs.tsv.gz"
                                    ])
    ch_chrom_map            = channel.fromPath("$projectDir/assets/chrom_map.txt", checkIfExists: true).collect()
    ch_clnvid_header        = channel.fromPath("$projectDir/assets/clnvid_header.txt", checkIfExists: true).collect()
    ch_clinvar_snv          = channel.of([
                                    [id:"clinvar_${params.clinvar_version_snv}_snv", version: params.clinvar_version_snv],
                                    "https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${params.clinvar_version_snv}.vcf.gz"
                                ])
    ch_gnomad_nuclear_snv   = channel.of(*1..22, 'X', 'Y')
                                .map { chr ->
                                        def ver = params.gnomad_snv_version
                                        return[[id:"gnomad_${ver}_snv", version: ver, chromosome: chr],
                                        "https://storage.googleapis.com/gcp-public-data--gnomad/release/${ver}/vcf/genomes/gnomad.genomes.v${ver}.sites.chr${chr}.vcf.bgz"]
                                }
    ch_gnomad_nuclear_sv    = channel.of([
                                    [id:"gnomad_" + params.gnomad_sv_version + "_sv", version: params.gnomad_sv_version],
                                    "https://storage.googleapis.com/gcp-public-data--gnomad/release/${params.gnomad_sv_version}/genome_sv/gnomad.v${params.gnomad_sv_version}.sv.sites.vcf.gz"
                                ])
    ch_gnomad_mt_snv        = channel.of([
                                    [id:"gnomad_" + params.gnomad_mt_version + "_mt", version: params.gnomad_mt_version],
                                    "https://storage.googleapis.com/gcp-public-data--gnomad/release/${params.gnomad_mt_version}/vcf/genomes/gnomad.genomes.v${params.gnomad_mt_version}.sites.chrM.vcf.bgz"
                                ])

    skip_cadd_annotations   = parseSkipList(params.skip_downloads, 'cadd_annotations')
    skip_cadd_scores        = parseSkipList(params.skip_downloads, 'cadd_scores')
    skip_clinvar_snv        = parseSkipList(params.skip_downloads, 'clinvar_snv')
    skip_gnomad_mt          = parseSkipList(params.skip_downloads, 'gnomad_mt')
    skip_gnomad_nuclear_snv = parseSkipList(params.skip_downloads, 'gnomad_nuclear_snv')
    skip_gnomad_nuclear_sv  = parseSkipList(params.skip_downloads, 'gnomad_nuclear_sv')

    RAREDISEASEREFS (
        ch_chrom_map,
        ch_clnvid_header,
        ch_cadd_annotations,
        ch_cadd_scores,
        ch_clinvar_snv,
        ch_gnomad_mt_snv,
        ch_gnomad_nuclear_snv,
        ch_gnomad_nuclear_sv,
        skip_cadd_annotations,
        skip_cadd_scores,
        skip_clinvar_snv,
        skip_gnomad_mt,
        skip_gnomad_nuclear_snv,
        skip_gnomad_nuclear_sv
    )

    emit:
    cadd_annotations   = RAREDISEASEREFS.out.cadd_annotations
    cadd_scores        = RAREDISEASEREFS.out.cadd_scores
    clinvar_snv        = RAREDISEASEREFS.out.clinvar_snv
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
    cadd_annotations   = NFCORE_RAREDISEASEREFS.out.cadd_annotations
    cadd_scores        = NFCORE_RAREDISEASEREFS.out.cadd_scores
    clinvar_snv        = NFCORE_RAREDISEASEREFS.out.clinvar_snv
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
    cadd_annotations {
        path 'cadd/data'
    }
    cadd_scores {
        path 'cadd'
    }
    clinvar_snv {
        path 'clinvar'
    }
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
