process DOWNLOADGNOMADSV {
    tag "${meta.id}"
    label 'process_very_long'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/2a/2a13c06c4ea5fccd55311fda0979caffbe009cd1fcbb629ef2257674f178a4a1/data':
        'community.wave.seqera.io/library/bcftools_wget:3777c03593ee7853' }"

    input:
    val(meta)

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    wget https://storage.googleapis.com/gcp-public-data--gnomad/release/${meta.version}/genome_sv/gnomad.v${meta.version}.sv.sites.vcf.gz
    """

    stub:
    """
    echo wget https://storage.googleapis.com/gcp-public-data--gnomad/release/${meta.version}/genome_sv/gnomad.v${meta.version}.sv.sites.vcf.gz >>commands

    touch gnomad.v${meta.version}.sv.sites.vcf.gz
    """

}
