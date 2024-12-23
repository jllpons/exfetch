process BEDTOOLS_GET_FASTA {
    label "process_single"

    publishDir "${params.outdir}", mode: 'copy', overwrite: true, pattern: '*.fasta'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedtools:2.31.1--hf5e1c6e_2@sha256:bf4b0fa21a081e5e071f273787b1e67942d331df' :
        'quay.io/biocontainers/bedtools@sha256:38756b5ac5d0368e91e85a3ed80cc40827506ebd63d449f5418befcba899b486' }"

    input:
    path fasta
    path gff

    output:
    path '*.fasta',        emit: fasta
    path 'versions.yml',   emit: versions
    path 'report.txt',     emit: report

    script:
    """
bedtools getfasta -fi ${fasta} -bed ${gff} -s -name > features.fasta

cat <<-END_VERSIONS > versions.yml
${task.process}:
    grep: \$(grep --version)
END_VERSIONS

cat <<-END_REPORT > report.txt

# BEDTOOLS_GETFASTA task report:
Number of features in the input file: \$(grep -v '^#' ${gff} | wc -l)
Number of sequences in the output file: \$(grep '^>' features.fasta | wc -l)
END_REPORT
    """
}

