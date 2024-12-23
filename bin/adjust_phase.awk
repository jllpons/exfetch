#!/usr/bin/awk -f

# In a GFF file, the CDS features are annotated with the phase of the first base
# of the CDS relative to the reading frame. This script adjusts the positions of
# the CDS feature so when bedtools getfasta is used to extract the CDS sequences,
# the sequences are in frame.

BEGIN {
    FS = "\t";
    OFS = "\t";
}

{
    attribtues = split($9, a, ";");
    gene_id = "";
    for (i = 1; i <= attribtues; i++) {
        split(a[i], b, "=");
        if (b[1] == "gene_id") {
            gene_id = b[2];
        }
    }
    if (gene_id != "") {
        $3 = gene_id;
    }

    if ($7 == "+") {
        $4 = ($4 + $8);

        if ($5 - $4 < 3) {
            next;
        }

    } else {
        $5 = ($5 - $8);

        if ($5 - $4 < 3) {
            next;
        }

    }

        print $0;
}
