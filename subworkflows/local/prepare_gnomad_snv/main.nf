include { DOWNLOADGNOMADSNV } from '../../../modules/local/download_gnomad_snv'
include { BCFTOOLS_ANNOTATE } from '../../../modules/nf-core/bcftools/annotate'
include { BCFTOOLS_MERGE    } from '../../../modules/nf-core/bcftools/merge'
include { BCFTOOLS_QUERY    } from '../../../modules/nf-core/bcftools/query/main'
include { TABIX_BGZIPTABIX  } from '../../../modules/nf-core/tabix/bgziptabix/main'

workflow PREPARE_GNOMAD_SNV {
    take:
    ch_gnomad_nc_snv

    main:
    DOWNLOADGNOMADSNV(ch_gnomad_nc_snv)

    DOWNLOADGNOMADSNV.out.bgz
        .transpose()
        .map {meta, vcf -> 
            def chr = vcf.getBaseName().tokenize('.')[-2]
            def new_meta = meta + [chromosome: chr]
            return [new_meta, vcf, [], [], []]
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
        .set{ ch_merge_in }

    BCFTOOLS_MERGE(ch_merge_in, [[:],[]], [[:],[]], [[:],[]])

    BCFTOOLS_MERGE.out.vcf
            .join(BCFTOOLS_MERGE.out.index, failOnMismatch:true, failOnDuplicate:true)
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