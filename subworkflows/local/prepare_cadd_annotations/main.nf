include { WGET  } from '../../../modules/nf-core/wget'
include { UNTAR } from '../../../modules/nf-core/untar'

workflow PREPARE_CADD_ANNOTATIONS {
    take:
    ch_cadd_annotations

    main:
    WGET(ch_cadd_annotations)

    UNTAR(WGET.out.outfile)

    emit:
    cadd_annotations = UNTAR.out.untar
}
