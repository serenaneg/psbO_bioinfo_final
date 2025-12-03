# psbO_bioinfo_final

## A "robust" approach to estimate relative phytoplankton cell abundances

Metabarcoding of rRNA genes (16S/18S) is widely used to estimate microbial community composition, but is limited by PCR amplification biases caused by mismatches between universal primers and the target sites of certain species, as well as variability in marker gene copy number across taxa, which can lead to poor correlations between observed rRNA gene abundance and actual abundance or biomass. To address these limitations, [Pierella Karlusich et al. (2023)][https://onlinelibrary.wiley.com/doi/epdf/10.1111/1755-0998.13592] proposes a PCR-free sequencing method for evaluating phytoplankton community diversity by using a newly described and verified genetic marker, psbO. PsbO is a single-copy core photosynthetic gene that codes for an extrinsic subunit of photosystem II (PSII). This protein has been shown to be universally present across both prokaryotic and eukaryotic photosynthetic organisms and can be used to assess taxonomy with high fidelity. 

To reproduce the analyses from the original paper—and given the limitations of the available size-fractionated data—we restricted our study to surface samples (upper 5 m) from Mediterranean Tara Oceans stations. We first processed the 5–20 µm size fraction by mapping metagenomic reads to the psbO gene database provided by the authors, using both Minimap2 and BWA. Read abundances were used as a proxy for relative cell abundance.
Each resulting SAM file was indexed using SAMtools and converted to BAM format for downstream analysis. We then applied CoverM to filter mapped reads based on the following criteria:
--min-read-aligned-length 70
--min-read-percent-identity 80
--min-read-aligned-percent 80

Filtered and re-indexed files were processed with samtools idxstats to extract read counts, which were subsequently converted to RPKM using a custom Python script. The entire workflow was implemented using Snakemake, and the final merging of abundance tables with sample metadata (including station information) and psbO taxonomy was performed in Python.
After conducting a sensitivity analysis to determine which mapper recovered the highest number of psbO reads, we repeated the workflow for the 0.8–5 µm and 20–180 µm size fractions using BWA.
Finally, we compared our mapped read counts and RPKM estimates with those reported by the authors, and evaluated the accuracy of our relative abundance and biovolume estimates by benchmarking them against Tara Oceans imaging datasets: flow cytometry for the 0.8–5 µm fraction and optical microscopy for the 20–180 µm fraction.

A summary of all datasets used in this study, along with their estimated sizes, is provided in the table below. A detailed comparison between our results and those of the original authors follows.

### Datasets used for the analysis

| Type of Data | Description | Etimated Size |
| :-------------- | :----------------------: | ------------: |
| Flow Cytometry| Table with flow cytometry-based determinations of abundance and biovolume for picophytoplankton in Tara Oceans samples.| 17 KB    |
| psbO sequence database|Fasta file containing >18,000 unique psbO sequences covering cyanobacteria, photosynthetic protists, macroalgae, and land plants.| 11.8 MB   |
| Ocean Microbial Reference Gene Catalog v2 (OMRGC.v2)|Gene catalog and associated quantitative data from 370 marine metagenomes and 187 metatranscriptomes from Tara Oceans Expedition.| ~ 30 GB      |

### Comparison Analysis
We first evaluated which mapping tool performed better by testing both on the 5–20 µm size fraction. BWA recovered slightly more reads than Minimap2 overall. Most of the reads missed by Minimap2 belonged to other eukaryotic phytoplankton groups, whereas BWA retrieved a higher number of Trichodesmium reads. Therefore, all he following analyssi has been perfomed using BWA.
![reads minimap vs bwa](https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reads_minimap_bwa.png)

#### Comparison between reads counts
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reference_reads.png" width="50%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reads_bwa.png" width="49%" />
</p>
