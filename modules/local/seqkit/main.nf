process SEQKIT_TRANSLATE_FASTA {
    label "process_single"

    publishDir "${params.outdir}", mode: 'copy', overwrite: true, pattern: '*translated.fasta'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedtools:2.31.1--hf5e1c6e_2@sha256:bf4b0fa21a081e5e071f273787b1e67942d331df' :
        'quay.io/biocontainers/bedtools@sha256:38756b5ac5d0368e91e85a3ed80cc40827506ebd63d449f5418befcba899b486' }"

    input:
    path fasta

    output:
    path "*.translated.fasta", emit: fasta
    path "versions.yml",       emit: versions
    path "report.txt",         emit: report

    script:
    """
seqkit translate ${fasta} --seq-type dna > ${fasta.baseName}.translated.fasta

cat <<-END_VERSIONS > versions.yml
${task.process}:
END_VERSIONS

cat <<-END_REPORT > report.txt

# SEQKIT_TRANSLATE_FASTA task report:
Number of sequences in input fasta before translation: \$(grep '^>' ${fasta} | wc -l)
Number of sequences in output fasta after translation: \$(grep '^>' ${fasta.baseName}.translated.fasta | wc -l)
END_REPORT
    """
}



