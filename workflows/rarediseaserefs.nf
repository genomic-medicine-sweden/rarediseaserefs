/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { paramsSummaryMap         } from 'plugin/nf-schema'
include { paramsSummaryMultiqc     } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText   } from '../subworkflows/local/utils_nfcore_rarediseaserefs_pipeline'
include { PREPARE_CADD_ANNOTATIONS } from '../subworkflows/local/prepare_cadd_annotations'
include { PREPARE_CADD_SCORES      } from '../subworkflows/local/prepare_cadd_scores'
include { PREPARE_CLINVAR_SNV      } from '../subworkflows/local/prepare_clinvar_snv'
include { PREPARE_GNOMAD_MT        } from '../subworkflows/local/prepare_gnomad_mt'
include { PREPARE_GNOMAD_SNV       } from '../subworkflows/local/prepare_gnomad_snv'
include { PREPARE_GNOMAD_SV        } from '../subworkflows/local/prepare_gnomad_sv'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow RAREDISEASEREFS {

    take:
    ch_chrom_map
    ch_clnvid_header
    ch_cadd_annotations
    ch_cadd_score
    ch_clinvar_snv
    ch_gnomad_mt_snv
    ch_gnomad_nuclear_snv
    ch_gnomad_nuclear_sv
    skip_cadd_annotations
    skip_cadd_score
    skip_clinvar_snv
    skip_gnomad_mt
    skip_gnomad_nuclear_snv
    skip_gnomad_nuclear_sv

    main:

    ch_versions               = channel.empty()
    ch_cadd_annotations_out   = channel.empty()
    ch_cadd_score_out         = channel.empty()
    ch_clinvar_snv_out        = channel.empty()
    ch_gnomad_mt_snv_out      = channel.empty()
    ch_gnomad_nuclear_snv_out = channel.empty()
    ch_gnomad_nuclear_sv_out  = channel.empty()

    if (!skip_cadd_annotations) {
        ch_cadd_annotations_out   = PREPARE_CADD_ANNOTATIONS(ch_cadd_annotations).cadd_annotations
    }
    if (!skip_cadd_score) {
        ch_cadd_score_out         = DOWNLOADCADDSCORES(ch_cadd_score).tsv_tbi
    }
    if (!skip_clinvar_snv) {
        ch_clinvar_snv_out        = PREPARE_CLINVAR_SNV(ch_chrom_map, ch_clinvar_snv, ch_clnvid_header).clinvar_snv
    }
    if (!skip_gnomad_mt) {
        ch_gnomad_mt_snv_out      = PREPARE_GNOMAD_MT(ch_gnomad_mt_snv).gnomad_mt
    }
    if (!skip_gnomad_nuclear_snv) {
        ch_gnomad_nuclear_snv_out = PREPARE_GNOMAD_SNV(ch_gnomad_nuclear_snv).gnomad_snv
    }
    if (!skip_gnomad_nuclear_sv) {
        ch_gnomad_nuclear_sv_out  = PREPARE_GNOMAD_SV(ch_gnomad_nuclear_sv).gnomad_sv
    }
    //
    // Collate and save software versions
    //
    def topic_versions = Channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'rarediseaserefs_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    emit:
    cadd_annotations   = ch_cadd_annotations_out
    cadd_scores        = ch_cadd_score_out
    clinvar_snv        = ch_clinvar_snv_out
    gnomad_mt          = ch_gnomad_mt_snv_out
    gnomad_nuclear_snv = ch_gnomad_nuclear_snv_out
    gnomad_nuclear_sv  = ch_gnomad_nuclear_sv_out
    multiqc_report     = channel.empty()
    versions           = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
