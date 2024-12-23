process GREP_FEATURES {
    label "process_single"

    publishDir "${params.outdir}/grep", mode: 'copy', overwrite: true, pattern: "features.gff"

    input:
    path id_list
    path gff

    output:
    path 'features.gff', emit: features
    path 'versions.yml', emit: versions
    path 'report.txt',   emit: report

    script:
    """
rg -Fwf ${id_list} ${gff} > features.gff

cat <<-END_VERSIONS > versions.yml
${task.process}:
    grep: \$(grep --version)
END_VERSIONS

touch missing_ids.txt
cat ${id_list} | xargs -I{} sh -c 'rg -qF "{}" ${gff} || echo "{}"' > missing_ids.txt
cat <<-END_REPORT > report.txt

# GREP_FEATURES task report:
Number of gene IDs in the list: \$(wc -l ${id_list})
Number of features in the input GFF: \$(grep -v '^#' ${gff} | wc -l)
Number of features that matched the gene IDs: \$(grep -v '^#' features.gff | wc -l)
Number of gene IDs that did not match any feature: \$(wc -l missing_ids.txt)
Ids that did not match any feature: \$(cat missing_ids.txt | tr '\n' ';')
END_REPORT
    """
}

