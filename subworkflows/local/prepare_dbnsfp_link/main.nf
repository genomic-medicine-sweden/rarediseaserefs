include { WGET as WGET_LINK    } from '../../../modules/nf-core/wget'
include { WGET as WGET_INDEX    } from '../../../modules/nf-core/wget'


workflow PREPARE_DBNSFP_LINK {
    take:
    ch_dbnsfp_link

    main:

    // Download the db link 
    WGET_LINK(ch_dbnsfp_link) 

    // Make an index channel and download indec 
    ch_dbnsfp_index = ch_dbnsfp_link.map {meta, link -> [meta, link + '.tbi']}
    WGET_INDEX(ch_dbnsfp_index)

    // Join the channels
    ch_dbnsfp_link_index_joined =  WGET_LINK.out.outfile.join(WGET_INDEX.out.outfile) 
                                                         
    emit:
    dbsnfp_link_index = ch_dbnsfp_link_index_joined
}