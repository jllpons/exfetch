process AWK_FILTER_FEATURES {
    label "process_single"

    publishDir "${params.outdir}/awk", mode: 'copy', overwrite: true, pattern: "*.filtered.gff"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gawk:5.3.0@sha25659457604b12b01d91ac0a0cf55937160963be209' :
        'quay.io/biocontainers/gawk@sha256:701d6199235b36d054c24b1d0a889ca5e9740e301e4b46651f54d59576b73cd0' }"

    input:
    path features
    val  filter

    output:
    path "*.filtered.gff", emit: features
    path 'versions.yml',   emit: versions
    path 'report.txt',     emit: report

    script:
    """
cat ${features} | gawk -v filter="${filter}" '
    {
        if (\$3 == filter) {
            print \$0
        }
    }' > ${features}.filtered.gff

cat <<-END_VERSIONS > versions.yml
${task.process}:
    gawk: \$(gawk --version | gawk 'NR==1{print \$3}')
END_VERSIONS

cat <<-END_REPORT > report.txt

# AWK_FILTER_FEATURES task report:
Number of features in the input GFF: \$(wc -l ${features})
Number of features that matched the filter: \$(wc -l ${features}.filtered.gff)
Number of features that did not match the filter: \$(expr \$(wc -l ${features}) - \$(wc -l ${features}.filtered.gff))
END_REPORT
    """
}

process AWK_ADJUST_PHASE {
    label "process_single"

    publishDir "${params.outdir}/awk", mode: 'copy', overwrite: true, pattern: "*.phase_adjusted.gff"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gawk:5.3.0@sha25659457604b12b01d91ac0a0cf55937160963be209' :
        'quay.io/biocontainers/gawk@sha256:701d6199235b36d054c24b1d0a889ca5e9740e301e4b46651f54d59576b73cd0' }"

    input:
    path features

    output:
    path "*.phase_adjusted.gff", emit: features
    path 'versions.yml',         emit: versions
    path 'report.txt',           emit: report

    script:
    """
adjust_phase.awk ${features} > ${features}.phase_adjusted.gff

cat <<-END_VERSIONS > versions.yml
${task.process}:
    adjust_phase.awk: \$(cat adjust_phase.awk)
END_VERSIONS

cat <<-END_REPORT > report.txt

# AWK_ADJUST_PHASE task report:
Number of features in the input GFF: \$(wc -l ${features})
Number of features with adjusted phase: \$(wc -l ${features}.phase_adjusted.gff)
END_REPORT
    """
}


