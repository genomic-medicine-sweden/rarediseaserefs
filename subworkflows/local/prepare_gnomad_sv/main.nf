include { DOWNLOADGNOMADSV  } from '../../../modules/local/download_gnomad_sv'
include { BCFTOOLS_ANNOTATE } from '../../../modules/nf-core/bcftools/annotate'

workflow PREPARE_GNOMAD_SV {
    take:
    val_gnomad_version_sv

    main:
    DOWNLOADGNOMADSV(val_gnomad_version_sv)

    DOWNLOADGNOMADSV.out.vcf
        .map {meta, vcf -> return [meta, vcf, [], [], []]}
        .set {ch_annotate_in}

    BCFTOOLS_ANNOTATE(ch_annotate_in, [], [], [])

    emit:
    gnomad_sv = BCFTOOLS_ANNOTATE.out.vcf.join(BCFTOOLS_ANNOTATE.out.tbi, failOnMismatch: true, failOnDuplicate:true)
}