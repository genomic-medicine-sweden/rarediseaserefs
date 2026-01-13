include { BCFTOOLS_ANNOTATE } from '../../../modules/nf-core/bcftools/annotate'
include { WGET              } from '../../../modules/nf-core/wget'

workflow PREPARE_GNOMAD_SV {
    take:
    ch_gnomad_nuclear_sv

    main:

    WGET(ch_gnomad_nuclear_sv)

    WGET.out.outfile
        .map {meta, vcf ->
            return [meta, vcf, [], [], []]}
        .set {ch_annotate_in}

    BCFTOOLS_ANNOTATE(ch_annotate_in, [], [], [])

    BCFTOOLS_ANNOTATE.out.vcf
        .join(BCFTOOLS_ANNOTATE.out.tbi, failOnMismatch: true, failOnDuplicate:true)
        .set {ch_sv_vcf_tbi}

    emit:
    gnomad_sv = ch_sv_vcf_tbi
}
