// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.

process GRAPHTYPER_GENOTYPE {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::graphtyper=2.7.2" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/graphtyper:2.7.2--h7d7f7ad_0':
        'quay.io/biocontainers/graphtyper:2.7.2--h7d7f7ad_0' }"
        
    publishDir params.outdir, mode: params.publish_dir_mode

    input:
    tuple val(meta), path(bam)
    tuple val(meta2), path(bai)
    path ref
    path ref_fai
    val region

    output:
    tuple val(meta), path("results/*/*.vcf.gz"), emit: vcf
    tuple val(meta), path("results/*/*.vcf.gz.tbi"), emit: tbi
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bam_path_text = bam.join('\n')
    def region_text = region.join('\n')
    """
    printf "$bam_path_text" > bam_list.txt
    printf "$region_text" > region_list.txt 
    graphtyper \\
        genotype \\
        $args \\
        $ref \\
        --sams bam_list.txt \\
        --region_file region_list.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        graphtyper: \$(graphtyper --help | tail -n 1 | sed 's/^   //')
    END_VERSIONS
    """
}
