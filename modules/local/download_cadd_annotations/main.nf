process DOWNLOADCADDANNOTATIONS {
    tag "${meta.id}"
    label 'process_very_long'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/10/10cab5d0be719eb69698474308613bec473f51ac148577ac46378ba2654c74bc/data':
        'community.wave.seqera.io/library/bcftools_perl_wget:869c6f1cad1b1a6f' }"

    input:
    val(meta)

    output:
    tuple val(meta), path("*.tar.gz"), emit: targz

    when:
    task.ext.when == null || task.ext.when

    script:
    def link = meta.mirror.equals("us") ? "https://krishna.gs.washington.edu/download/CADD/v${meta.version}/GRCh38" : "https://kircherlab.bihealth.org/download/CADD/v${meta.version}/GRCh38"
    """
    wget -c -O CADD_GRCh38_v${meta.version}.tar.gz ${link}/GRCh38_v1.7.tar.gz
    """

    stub:
    def link = meta.mirror.equals("us") ? "https://krishna.gs.washington.edu/download/CADD/v${meta.version}/GRCh38" : "https://kircherlab.bihealth.org/download/CADD/v${meta.version}/GRCh38"
    """
    echo wget -c -O CADD_GRCh38_v${meta.version}.tar.gz ${link}/GRCh38_v1.7.tar.gz >>commands
    
    touch CADD_GRCh38_v${meta.version}.tar.gz
    """

}
