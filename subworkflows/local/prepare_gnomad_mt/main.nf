include { TABIX_TABIX } from '../../../modules/nf-core/tabix/tabix'
include { WGET        } from '../../../modules/nf-core/wget'

workflow PREPARE_GNOMAD_MT {
    take:
    ch_gnomad_mt_snv

    main:

    WGET(ch_gnomad_mt_snv)

    TABIX_TABIX(WGET.out.outfile)

    WGET.out.outfile
        .join(TABIX_TABIX.out.index, failOnMismatch: true, failOnDuplicate:true)
        .set {ch_mt_vcf_tbi}

    emit:
    gnomad_mt = ch_mt_vcf_tbi
}
