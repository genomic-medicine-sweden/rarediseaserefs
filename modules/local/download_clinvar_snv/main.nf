process DOWNLOADCLINVARSNV {
    tag "clinvar_snv"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/10/10cab5d0be719eb69698474308613bec473f51ac148577ac46378ba2654c74bc/data':
        'community.wave.seqera.io/library/bcftools_perl_wget:869c6f1cad1b1a6f' }"

    input:
    val(meta)

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.vcf.gz.tbi"), emit: vcf_tbi

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${meta.version}.vcf.gz
    wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${meta.version}.vcf.gz.tbi
    """

    stub:
    """
    echo wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${meta.version}.vcf.gz >>commands
    echo wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${meta.version}.vcf.gz.tbi >>commands
    touch clinvar_reformatted_${meta.version}.vcf.gz
    tocuh clinvar_reformatted_${meta.version}.vcf.gz.tbi
    """

}