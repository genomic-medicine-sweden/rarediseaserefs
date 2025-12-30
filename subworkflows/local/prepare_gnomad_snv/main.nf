include {DOWNLOADGNOMADSNV} from '../../../modules/local/download_gnomad_snv'
include {BCFTOOLS_MERGE   } from '../../../modules/nf-core/bcftools/merge'

workflow PREPARE_GNOMAD_SNV {
    take:
    val_gnomad_version_snv

    main:
    DOWNLOADGNOMADSNV(val_gnomad_version_snv)

    BCFTOOLS_MERGE(DOWNLOADGNOMADSNV.out.vcf_tbi, [[:],[]], [[:],[]], [[:],[]])

    ch_gnomad_snv_out = BCFTOOLS_MERGE.out.vcf.join(BCFTOOLS_MERGE.out.index, failOnMismatch:true, failOnDuplicate:true)

    emit:
    gnomad_snv = ch_gnomad_snv_out
}