process DOWNLOADGNOMADSV {
    tag "gnomad_sv"
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
    meta = [id: "gnomad_${version}_sv"]
    """
    wget https://storage.googleapis.com/gcp-public-data--gnomad/release/${version}/genome_sv/gnomad.v${version}.sv.sites.vcf.gz

    bcftools annotate \\
        --output-type z \\
        --write-index=tbi \\
        --threads ${task.cpus-1} \\
        --output gnomad_reformatted.r${version}.sv.sites.vcf.gz \\
        --include "FILTER='PASS'" \\
        --remove "^INFO/AF,INFO/AC" \\
        gnomad.v${version}.sv.sites.vcf.gz

    rm gnomad.v${version}.sv.sites.vcf.gz
    """

    stub:
    meta = [id: "gnomad_${version}_sv"]
    """
    for i in X Y; do
        echo wget https://storage.googleapis.com/gcp-public-data--gnomad/release/${version}/genome_sv/gnomad.v${version}.sv.sites.vcf.gz >>commands

        echo bcftools annotate \\
            --output-type z \\
            --write-index=tbi \\
            --threads ${task.cpus-1} \\
            --output gnomad_reformatted.r${version}.sv.sites.vcf.gz \\
            --include \\"FILTER=\\'PASS\\'\\" \\
            --remove \\"^INFO/AF,INFO/AC\\" \\
            gnomad.v${version}.sv.sites.vcf.gz >>commands

        touch gnomad_reformatted.r${version}.sv.sites.vcf.gz
        touch gnomad_reformatted.r${version}.sv.sites.vcf.gz.tbi
    done
    """

}