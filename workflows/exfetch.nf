include { AWK_ADJUST_PHASE       } from '../modules/local/awk'
include { AWK_FILTER_FEATURES    } from '../modules/local/awk'
include { BEDTOOLS_GET_FASTA     } from '../modules/local/bedtools'
include { GREP_FEATURES          } from '../modules/local/grep'
include { SEQKIT_TRANSLATE_FASTA } from '../modules/local/seqkit'

workflow EXFETCH {

    take:
    list        // (str) - Path to the list of gene IDs
    fasta       // (str) - Path to the reference FASTA file
    gff         // (str) - Path to the GFF file
    outdir      // (str) - Output directory
    translate   // (bool) - Translate the exons to amino acids
    filter      // (str) - Filter the GFF features to some specific type
    ch_versions // (Channel) - Channel to send the versions to

    main:

    ch_list = Channel.fromPath(list)
    ch_fasta = Channel.fromPath(fasta)
    ch_gff = Channel.fromPath(gff)

    ch_report = Channel.empty()

    GREP_FEATURES(
        id_list = ch_list,
        gff     = ch_gff,
    )
    ch_versions = ch_versions.mix(GREP_FEATURES.out.versions)
    ch_report = ch_report.mix(GREP_FEATURES.out.report)

    AWK_FILTER_FEATURES(
        features = GREP_FEATURES.out.features,
        filter = filter,
    )
    ch_versions = ch_versions.mix(AWK_FILTER_FEATURES.out.versions)
    ch_report = ch_report.mix(AWK_FILTER_FEATURES.out.report)

    AWK_ADJUST_PHASE(
        features = AWK_FILTER_FEATURES.out.features,
    )
    ch_versions = ch_versions.mix(AWK_ADJUST_PHASE.out.versions)
    ch_report = ch_report.mix(AWK_ADJUST_PHASE.out.report)

    BEDTOOLS_GET_FASTA(
        fasta = ch_fasta,
        features = AWK_ADJUST_PHASE.out.features,
    )
    ch_versions = ch_versions.mix(BEDTOOLS_GET_FASTA.out.versions)
    ch_report = ch_report.mix(BEDTOOLS_GET_FASTA.out.report)

    ch_fasta = BEDTOOLS_GET_FASTA.out.fasta

    if (translate) {
        SEQKIT_TRANSLATE_FASTA(
            fasta = BEDTOOLS_GET_FASTA.out.fasta,
        )
        ch_versions = ch_versions.mix(SEQKIT_TRANSLATE_FASTA.out.versions)
        ch_report = ch_report.mix(SEQKIT_TRANSLATE_FASTA.out.report)
        ch_fasta = SEQKIT_TRANSLATE_FASTA.out.fasta
    }

    emit:
    fasta  = ch_fasta
    report = ch_report
    versions = ch_versions
}

