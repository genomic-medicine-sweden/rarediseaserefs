process DOWNLOADCLINVARSNV {
    tag "gnomad_snv"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/10/10cab5d0be719eb69698474308613bec473f51ac148577ac46378ba2654c74bc/data':
        'community.wave.seqera.io/library/bcftools_perl_wget:869c6f1cad1b1a6f' }"

    input:
    val(version)

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.vcf.gz.tbi"), emit: vcf_tbi

    when:
    task.ext.when == null || task.ext.when

    script:
    meta = [id: "clinvar_${version}"]
    """
    wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${version}.vcf.gz
    wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${version}.vcf.gz.tbi

    echo '##INFO=<ID=CLNVID,Number=1,Type=Integer,Description="ClinVar Variation ID">' > clnvid_header.txt
    bcftools annotate \\
        --threads ${task.cpus - 1} \\
        --header-lines clnvid_header.txt \\
        clinvar_${version}.vcf.gz | \\
    perl -nae 'if(\$_ =~ /^#/) { print \$_; } else { chomp; print \$_ . ";CLNVID=" . \$F[2] . "\\n"; }' | \\
    bgzip -c > clinvar_reformatted_${version}.vcf.gz
    bcftools index -t clinvar_reformatted_${version}.vcf.gz

    rm clinvar_${version}.vcf.gz clinvar_${version}.vcf.gz.tbi
    """

    stub:
    meta = [id: "clinvar_${version}"]
    """
    echo wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${version}.vcf.gz >>commands
    echo wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_${version}.vcf.gz.tbi >>commands
    touch clinvar_reformatted_${version}.vcf.gz
    tocuh clinvar_reformatted_${version}.vcf.gz.tbi
    """

}