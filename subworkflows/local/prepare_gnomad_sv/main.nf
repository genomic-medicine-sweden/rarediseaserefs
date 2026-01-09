include { DOWNLOADGNOMADSV  } from '../../../modules/local/download_gnomad_sv'
include { BCFTOOLS_ANNOTATE } from '../../../modules/nf-core/bcftools/annotate'

workflow PREPARE_GNOMAD_SV {
    take:
    ch_gnomad_nc_sv

    main:

    DOWNLOADGNOMADSV(ch_gnomad_nc_sv)

    DOWNLOADGNOMADSV.out.vcf
        .map {meta, vcf ->
            def new_meta = [id: "gnomad_reformatted.v"+meta.version+".sv.sites"]
            return [new_meta, vcf, [], [], []]}
        .set {ch_annotate_in}

    BCFTOOLS_ANNOTATE(ch_annotate_in, [], [], [])

    BCFTOOLS_ANNOTATE.out.vcf
        .join(BCFTOOLS_ANNOTATE.out.tbi, failOnMismatch: true, failOnDuplicate:true)
        .set {ch_sv_vcf_tbi}

    emit:
    gnomad_sv = ch_sv_vcf_tbi
}
