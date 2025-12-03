# scripts/rpkm.py
import pandas as pd
import sys
import os

table_in = sys.argv[1]
rpkm_tab = sys.argv[2]

if not os.path.exists(table_in) or os.path.getsize(table_in) == 0:
    with open(rpkm_tab, "w") as f:
        f.write("")
    sys.exit(0)

table = pd.read_csv(table_in, sep='\t', header=None,
                    names=['gene_id', 'length', 'mapped_counts', 'unmapped_counts'])
table = table[table['gene_id'] != "*"]

total_mapped = table['mapped_counts'].sum()
table['RPKM'] = (1e9 * table['mapped_counts']) / (total_mapped * table['length'])
table['RPKM_abund'] = table['RPKM'] / table['RPKM'].sum()

table.to_csv(rpkm_tab, sep='\t', index=False)

