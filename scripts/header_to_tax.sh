#!/bin/bash

# Get the FASTA names up to the first space (first grep line)
# Get the full FASTA names (second grep line)
# Put them together in the same file

# Setting up file paths
db="/proj/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/data/psbO_database.fna"
#idx="/proj/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/tables/ERR1726522_reads_counts.tsv"
tables="/proj/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/tables"
bams="/proj/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/outputs/minimap2"

out="${tables}/all_idxstats_annotated.tsv"
> "$out"

# The first grep gets everything up to the first space in the header name
# The second grep gets the full header name
# This creates a file where the first column is the truncated header and the second column is the full header
paste \
  <(grep ">" $db | sed 's/>//' | awk '{print $1}') \
  <(grep ">" $db | sed 's/>//') \
  > "${tables}/id_map.tsv"

# Loop through the count tables and use join to match truncated header with full header
# psbo database headers include taxonomy info
for bam in "$bams"/*.bam
do
    name=$(basename -s "_mapped.bam" ${bam})
    idx="tables/${name}_reads_counts.tsv"

    # Use the truncated FASTA id to join with the idxstats results
    join -1 1 -2 1 \
      <(sort $idx) \
      <(sort "${tables}/id_map.tsv") \
      | awk -v s="$name" 'BEGIN{OFS="\t"} {print s, $0}' \
      | awk '$4 != 0'  >> $out    # Filter out zero reads

done
