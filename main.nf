include { EXFETCH } from './workflows/exfetch.nf'

help_message = """
E X F E T C H   P I P E L I N E
===============================
exfetch retrieves exon-derived sequences (nucleotides or translated)
from a specified list of gene IDs.

Usage:
    nextflow run main.nf --list <list> --fasta <fasta> --gff <gff>
    nextflow run main.nf -params-file <yaml>

Required arguments:
    --list <list>       : A list of gene IDs to retrieve sequences for.
    --fasta <fasta>     : A reference FASTA file containing the genome sequence.
    --gff <gff>         : A GFF file containing the gene annotations.

Optional arguments:
    --outdir <outdir>   : Output directory (default: exfetch_out).
    --translate         : Translate the exons to amino acids.
    --filter <filter>   : Filter the GFF features to some specific type [default: ${params.filter}].
    --version           : Print the version number.
    --help              : Print this help message.
"""

init_summary = """
E X F E T C H   P I P E L I N E
===============================
list         : ${params.list}
fasta        : ${params.fasta}
gff          : ${params.gff}
outdir       : ${params.outdir}
translate    : ${params.translate}
filter       : ${params.filter}

---


Run as       : ${workflow.commandLine}
Started at   : ${workflow.start}
Config files : ${workflow.configFiles}

--
"""

def validateParams() {

    if (params.help) {
        println help_message
        System.exit(0)
    }
    if (params.version) {
        println "${params.manifest.name} v${params.manifest.version}"
        System.exit(0)
    }

    if (params.list == null || params.fasta == null || params.gff == null) {
        println help_message
        System.exit(1)
    }

    if (!file(params.list).exists()) {
        println "Error: List file not found: ${params.list}"
        System.exit(1)
    }
    if (!file(params.fasta).exists()) {
        println "Error: FASTA file not found: ${params.fasta}"
        System.exit(1)
    }
    if (!file(params.gff).exists()) {
        println "Error: GFF file not found: ${params.gff}"
        System.exit(1)
    }
}


def completionMsg() {

    if (workflow.success) {
        if (workflow.stats.ignoredCount == 0) {
            log.info "Pipeline completed successfully!"
        }
        else {
            log.info "Pipeline completed successully, but with errored processes"
        }
    }
    else {
        log.error "Pipeline completed with errors"
    }

}


workflow {

    main:

    // Validate input parameters
    validateParams()
    // Initialization Summary - Everything looks good so far
    log.info init_summary




    ch_versions = Channel.empty()
    // WORKFLOW: After validation, main workflow is launched here
    EXFETCH(
        params.list,
        params.fasta,
        params.gff,
        params.outdir,
        params.translate,
        params.filter,
        ch_versions,
    )
    ch_versions = ch_versions.mix(EXFETCH.out.versions)
    ch_report = EXFETCH.out.report




    // Save versions of all tools used in the pipeline
    ch_versions.collectFile(
        storeDir: "${params.outdir}/pipeline_info/",
        name: 'versions.yml',
        sort: true,
        newLine: true
    )
    // Save the final report
    ch_report.collectFile(
        storeDir: "${params.outdir}/",
        name: 'report.txt',
        newLine: true
    )

    // Display any error encountered during the workflow
    workflow.onComplete {
        completionMsg()
    }
}
