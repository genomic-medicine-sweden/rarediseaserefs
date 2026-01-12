include { DOWNLOADCADDANNOTATIONS } from '../../../modules/local/download_cadd_annotations'
include { UNTAR                   } from '../../../modules/nf-core/untar'

workflow PREPARE_CADD_ANNOTATIONS {
    take:
    ch_cadd_annotations

    main:
    DOWNLOADCADDANNOTATIONS(ch_cadd_annotations)

    UNTAR(DOWNLOADCADDANNOTATIONS.out.targz)

    emit:
    cadd_annotations = UNTAR.out.untar
}
