# psbO_bioinfo_final

## A "robust" approach to estimate relative phytoplankton cell abundances

Metabarcoding of rRNA genes (16S/18S) is widely used to estimate microbial community composition, but is limited by PCR amplification biases caused by mismatches between universal primers and the target sites of certain species, as well as variability in marker gene copy number across taxa, which can lead to poor correlations between observed rRNA gene abundance and actual abundance or biomass. To address these limitations, [Pierella Karlusich et al. (2023)](https://onlinelibrary.wiley.com/doi/epdf/10.1111/1755-0998.13592) propose a PCR-free sequencing method for evaluating phytoplankton community diversity by using a newly described and verified genetic marker, psbO. PsbO is a single-copy core photosynthetic gene that codes for an extrinsic subunit of photosystem II (PSII). This protein has been shown to be universally present across both prokaryotic and eukaryotic photosynthetic organisms and can be used to assess taxonomy with high fidelity. 

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
We first evaluated which mapping tool performed better by testing both on the 5–20 µm size fraction. BWA recovered slightly more reads than Minimap2 overall. Most of the reads missed by Minimap2 belonged to other eukaryotic phytoplankton groups, whereas BWA retrieved a higher number of Trichodesmium reads. Therefore, all he following analyses have been performed using BWA.

<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reads_minimap_bwa.png" 
    width="45%"/>
</p>

#### Comparison between read counts
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reference_reads.png" width="50%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reads_bwa.png" width="49%" />
</p>

The station-by-station comparison showed good agreement between our results and those reported by the authors. However, not all sample stations were available on the HPC, and due to time and storage constraints, we chose not to download the additional missing samples.
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_08-5.png" width="70%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_5-20.png" width="70%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_20-180.png" width=70% />
</p>

### Scatterplots
-- Scatterplots size 0.8-5 um psbO read counts vs Flow Cytometry counts (left column) and psbO derived biovolumne vs Flow Cytometry counts (right columns).

Paper's reference
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/ddd58bbb8bc30bef6e3ebf72d6028abd000ea485/plots/psbO_vs_flow_counts_08-5um_ref.png" width="49%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/ddd58bbb8bc30bef6e3ebf72d6028abd000ea485/plots/psbO_vs_flow_biovolume_08-5um_ref.png" width=49% />
 </p> 

Our results
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/ddd58bbb8bc30bef6e3ebf72d6028abd000ea485/plots/psbO_vs_flow_counts_08-5um.png" width="49%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/ddd58bbb8bc30bef6e3ebf72d6028abd000ea485/plots/psbO_vs_flow_biovolume_08-5um.png" width=49% />
 </p> 

 -- Scatterplots size 20-180 um psbO read counts vs Optical Microscopy.

 Paper's reference
  <p float="center">
    <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/3d268952dca27fbc64709422bd05c28259ee439c/plots/psbO_vs_optMicr_counts_20-180um_ref.png" width="80%" />
  </p>
 Our results 
 <p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/d1ba4d8e0034e69755e479fdc57ffa5bbd0a4161/plots/psbO_vs_optMicr_counts_20-180um.png" width="80%" />
 </p>
 
### Biogeography
 <p float="center">
<img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/84cb8c3d721961658e38cf6bf8a5acf8b162b081/plots/biogeography_ref.pdf" width="45%" />
<img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/84cb8c3d721961658e38cf6bf8a5acf8b162b081/plots/biogeography_replicated.pdf" width="45%" />
 </p>
 
## Reproducibility Issues and Conclusions


