include { BCFTOOLS_ANNOTATE } from '../../../modules/nf-core/bcftools/annotate'
include { GAWK              } from '../../../modules/nf-core/gawk'
include { TABIX_BGZIPTABIX  } from '../../../modules/nf-core/tabix/bgziptabix/main'
include { WGET              } from '../../../modules/nf-core/wget'

workflow PREPARE_CLINVAR_SNV {
    take:
    ch_clnvid_header
    ch_clinvar_snv

    main:
    WGET(ch_clinvar_snv)

    WGET.out.outfile
        .map {meta, vcf -> return [meta, vcf, [], [], []]}
        .set {ch_annotate_in}

    BCFTOOLS_ANNOTATE(ch_annotate_in, [], ch_clnvid_header, [])

    GAWK(BCFTOOLS_ANNOTATE.out.vcf, [], false)

    TABIX_BGZIPTABIX(GAWK.out.output)

    emit:
    clinvar_snv = TABIX_BGZIPTABIX.out.gz_index
}
