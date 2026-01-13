include { BCFTOOLS_ANNOTATE } from '../../../modules/nf-core/bcftools/annotate'
include { BCFTOOLS_CONCAT   } from '../../../modules/nf-core/bcftools/concat'
include { BCFTOOLS_QUERY    } from '../../../modules/nf-core/bcftools/query/main'
include { TABIX_BGZIPTABIX  } from '../../../modules/nf-core/tabix/bgziptabix/main'
include { WGET              } from '../../../modules/nf-core/wget'

workflow PREPARE_GNOMAD_SNV {
    take:
    ch_gnomad_nc_snv

    main:
    WGET(ch_gnomad_nc_snv)

    WGET.out.outfile
        .map {meta, vcf ->
            return [meta, vcf, [], [], []]
        }
        .set {ch_annotate_in}

    BCFTOOLS_ANNOTATE(ch_annotate_in, [], [], [])

    BCFTOOLS_ANNOTATE.out.vcf
        .join(BCFTOOLS_ANNOTATE.out.tbi, failOnMismatch:true, failOnDuplicate:true)
        .map { meta, vcf, tbi ->
            def new_meta = meta - meta.subMap('chromosome')
            return [new_meta, vcf, tbi]
        }
        .groupTuple()
        .set{ ch_concat_in }

    BCFTOOLS_CONCAT(ch_concat_in)

    BCFTOOLS_CONCAT.out.vcf
            .join(BCFTOOLS_CONCAT.out.tbi, failOnMismatch:true, failOnDuplicate:true)
            .set {ch_gnomad_snv_vcf}

    BCFTOOLS_QUERY(
        ch_gnomad_snv_vcf,
        [],
        [],
        [])

    TABIX_BGZIPTABIX(BCFTOOLS_QUERY.out.output)

    TABIX_BGZIPTABIX.out.gz_index
        .join(ch_gnomad_snv_vcf)
        .set {ch_gnomad_snv}

    emit:
    gnomad_snv = ch_gnomad_snv
}
