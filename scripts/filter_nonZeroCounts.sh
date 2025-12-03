# From outputs counts tables, filter keeping only non zero mapped read
# and save only the non empty files

FOLDER_TABLES="/proj/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/tables"

for fl in ${FOLDER_TABLES}/*_reads_counts.tsv; do
    name=$(basename "$fl" _reads_counts.tsv)
    
    # Filter non-zero reads and save to a temporary file
    tmpfile=$(mktemp)

    # Create table

    # Create table only if file not empty --> not used bc Snakemake always require input file
    awk '$3 != 0' "$fl" > "${FOLDER_TABLES}/${name}_nonZeroRead_counts.tsv"
    
    # Only save if the filtered file is not empty
    # if [[ -s "$tmpfile" ]]; then
    #    mv "$tmpfile" "${FOLDER_TABLES}/${name}_nonZeroRead_counts.tsv"
    #    echo "Saved ${name}_nonZeroRead_counts.tsv"
    #else
    #    echo "Skipping ${name}: no non-zero reads"
    #    rm "$tmpfile"
    #fi
done

echo "Done Done"
