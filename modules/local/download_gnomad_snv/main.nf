process DOWNLOADGNOMADSNV {
    tag "gnomad_snv"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/2a/2a13c06c4ea5fccd55311fda0979caffbe009cd1fcbb629ef2257674f178a4a1/data':
        'community.wave.seqera.io/library/bcftools_wget:3777c03593ee7853' }"

    input:
    val(version)

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.vcf.gz.tbi"), emit: vcf_tbi

    when:
    task.ext.when == null || task.ext.when

    script:
    meta = [id: "gnomad_${version}_snv"]
    """
    for i in {1..22} X Y; do
        wget https://storage.googleapis.com/gcp-public-data--gnomad/release/${version}/vcf/genomes/gnomad.genomes.v${version}.sites.chr\${i}.vcf.bgz
        
        bcftools annotate \\
            --output-type z \\
            --write-index=tbi \\
            --threads ${task.cpus-1} \\
            --output gnomad_reformatted.genomes.v${version}.sites.chr\${i}.vcf.gz \\
            --include "FILTER='PASS'" \\
            --remove "^INFO/AF,INFO/AF_grpmax" \\
            gnomad.genomes.v${version}.sites.chr\${i}.vcf.bgz
        
        rm gnomad.genomes.v${version}.sites.chr\${i}.vcf.bgz
    done
    """

    stub:
    meta = [id: "gnomad_${version}_snv"]
    """
    for i in {1..22} X Y; do
        echo wget https://storage.googleapis.com/gcp-public-data--gnomad/release/${version}/vcf/genomes/gnomad.genomes.v${version}.sites.chr\${i}.vcf.bgz >>commands

        echo bcftools annotate \\
            --output-type z \\
            --write-index=tbi \\
            --threads ${task.cpus-1} \\
            --output gnomad_reformatted.genomes.v${version}.sites.chr\${i}.vcf.gz \\
            --include \\"FILTER=\\'PASS\\'\\" \\
            --remove \\"^INFO/AF,INFO/AF_grpmax\\" \\
            gnomad.genomes.v${version}.sites.chr\${i}.vcf.bgz >>commands

        touch gnomad_reformatted_.genomes.v${version}.sites.chr\${i}.vcf.gz
        touch --output gnomad_reformatted_.genomes.v${version}.sites.chr\${i}.vcf.gz
    done
    """

}