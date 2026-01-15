include { TABIX_TABIX } from '../../../modules/nf-core/tabix/tabix'
include { WGET        } from '../../../modules/nf-core/wget'

workflow PREPARE_CADD_SCORES {
    take:
    ch_cadd_scores

    main:

    WGET(ch_cadd_scores)

    TABIX_TABIX(WGET.out.outfile)

    WGET.out.outfile
        .join(TABIX_TABIX.out.index, failOnMismatch: true, failOnDuplicate:true)
        .set {ch_cadd_scores_out}

    emit:
    cadd_scores = ch_cadd_scores_out
}
