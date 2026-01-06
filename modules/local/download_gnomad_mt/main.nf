process DOWNLOADGNOMADMT {
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
    meta = [id: "gnomad_${version}_mt"]
    """
    wget -O gnomad.genomes.v${version}.sites.chrM.vcf.gz https://storage.googleapis.com/gcp-public-data--gnomad/release/${version}/vcf/genomes/gnomad.genomes.v${version}.sites.chrM.vcf.bgz
    wget -O gnomad.genomes.v${version}.sites.chrM.vcf.gz.tbi https://storage.googleapis.com/gcp-public-data--gnomad/release/${version}/vcf/genomes/gnomad.genomes.v${version}.sites.chrM.vcf.bgz.tbi
    """

    stub:
    meta = [id: "gnomad_${version}_mt"]
    """
        echo wget -O gnomad.genomes.v${version}.sites.chrM.vcf.gz https://storage.googleapis.com/gcp-public-data--gnomad/release/${version}/vcf/genomes/gnomad.genomes.v${version}.sites.chrM.vcf.bgz >>commands
        echo wget -O gnomad.genomes.v${version}.sites.chrM.vcf.gz.tbi https://storage.googleapis.com/gcp-public-data--gnomad/release/${version}/vcf/genomes/gnomad.genomes.v${version}.sites.chrM.vcf.bgz.tbi >>commands

        touch gnomad.genomes.v${version}.sites.chrM.vcf.gz
        touch gnomad.genomes.v${version}.sites.chrM.vcf.gz.tbi
    done
    """

}