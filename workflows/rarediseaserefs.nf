/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_rarediseaserefs_pipeline'
include { PREPARE_CLINVAR_SNV    } from '../subworkflows/local/prepare_clinvar_snv'
include { PREPARE_GNOMAD_SNV     } from '../subworkflows/local/prepare_gnomad_snv'
include { PREPARE_GNOMAD_SV      } from '../subworkflows/local/prepare_gnomad_sv'

include { DOWNLOADGNOMADMT       } from '../modules/local/download_gnomad_mt'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow RAREDISEASEREFS {

    take:
    ch_clnvid_header
    ch_clinvar_snv
    ch_gnomad_mt_snv
    ch_gnomad_nc_snv
    ch_gnomad_nc_sv
    skip_clinvar_snv
    skip_gnomad_mt
    skip_gnomad_nc_snv
    skip_gnomad_nc_sv

    main:

    ch_versions           = channel.empty()
    ch_clinvar_snv_out    = channel.empty()
    ch_gnomad_mt_snv_out  = channel.empty()
    ch_gnomad_nc_snv_out  = channel.empty()
    ch_gnomad_nc_sv_out   = channel.empty()

    if (!skip_clinvar_snv) {
        ch_clinvar_snv_out   = PREPARE_CLINVAR_SNV(ch_clnvid_header, ch_clinvar_snv).clinvar_snv
    }
    if (!skip_gnomad_mt) {
        ch_gnomad_mt_snv_out = DOWNLOADGNOMADMT(ch_gnomad_mt_snv).vcf_tbi
    }
    if (!skip_gnomad_nc_snv) {
        ch_gnomad_nc_snv_out = PREPARE_GNOMAD_SNV(ch_gnomad_nc_snv).gnomad_snv
    }
    if (!skip_gnomad_nc_sv) {
        ch_gnomad_nc_sv_out  = PREPARE_GNOMAD_SV(ch_gnomad_nc_sv).gnomad_sv
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
    clinvar_snv        = ch_clinvar_snv_out
    gnomad_mt          = ch_gnomad_mt_snv_out
    gnomad_nuclear_snv = ch_gnomad_nc_snv_out
    gnomad_nuclear_sv  = ch_gnomad_nc_sv_out
    multiqc_report     = channel.empty()
    versions           = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
