
#!/bin/bash

# Get the FASTA names up to the first space (first grep line)
# Get the full FASTA names (second grep line)
# Put them together in the same file

# Setting up file paths
meta="/proj/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/data/med_surface_total.txt"

out="/proj/omics/env-bio/2025/collaboration/hochroth_negroni_finalproj/tables/station_annotations.txt"
> "$out"

# The first grep gets everything up to the first space in the header name
# The second grep gets the full header name
# This creates a file where the first column is the truncated header and the second column is the full header
paste \
  <(cut -f 1 $meta) \
  <(cut -f 2 $meta | sed -E 's/.*_([0-9]{3})_.*/\1/') \
  > $out

