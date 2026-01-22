include { WGET as WGET_LINK    } from '../../../modules/nf-core/wget'
include { WGET as WGET_INDEX    } from '../../../modules/nf-core/wget'


workflow PREPARE_DBNSFP_LINK {
    take:
    ch_dbnsfp_link

    main:

    WGET_LINK(ch_dbnsfp_link)


/* 
    WGET.out.outfile
        .join(TABIX_TABIX.out.index, failOnMismatch: true, failOnDuplicate:true)
        .set {ch_mt_vcf_tbi}
*/ 

    emit:
    dbnsfp_link_downloaded = WGET_LINK.out.outfile
}