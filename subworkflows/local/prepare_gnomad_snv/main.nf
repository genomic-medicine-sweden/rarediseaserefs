include {DOWNLOADGNOMADSNV } from '../../../modules/local/download_gnomad_snv'
include {BCFTOOLS_MERGE    } from '../../../modules/nf-core/bcftools/merge'
include {BCFTOOLS_QUERY    } from '../../../modules/nf-core/bcftools/query/main'
include { TABIX_BGZIPTABIX } from '../../../modules/nf-core/tabix/bgziptabix/main'

workflow PREPARE_GNOMAD_SNV {
    take:
    val_gnomad_version_snv

    main:
    DOWNLOADGNOMADSNV(val_gnomad_version_snv)

    BCFTOOLS_MERGE(DOWNLOADGNOMADSNV.out.vcf_tbi, [[:],[]], [[:],[]], [[:],[]])

    ch_gnomad_snv_vcf = BCFTOOLS_MERGE.out.vcf.join(BCFTOOLS_MERGE.out.index, failOnMismatch:true, failOnDuplicate:true)

    BCFTOOLS_QUERY(
        ch_gnomad_snv_vcf,
        [],
        [],
        [])

    TABIX_BGZIPTABIX(BCFTOOLS_QUERY.out.output)

    emit:
    gnomad_snv = TABIX_BGZIPTABIX.out.gz_index.join(ch_gnomad_snv_vcf)
}