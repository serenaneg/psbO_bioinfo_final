# psbO_bioinfo_final

## psbO: a new gene marker for estimating phytoplankton abundances from metagenomes

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
We first evaluated which mapping tool performed better by testing both on the 5–20 µm size fraction. BWA recovered slightly more reads than Minimap2 overall. Most of the reads missed by Minimap2 belonged to other eukaryotic phytoplankton groups, whereas BWA retrieved a higher number of Trichodesmium reads. Therefore, all he following analyses have been performed using BWA, because performance was comparable and to be consistent with the tool used in the original paper.

<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reads_minimap_bwa.png" 
    width="45%"/>
</p>

#### Comparison between read counts
In general, our results reproduce the main patterns of variability in the phytoplankton community across the three selected size classes. The strongest agreement occurs in the largest size fraction, where we observe only a slight overestimation of Dinoflagellates and an underestimation of Haptophytes. Interestingly, despite this fraction having the greatest number of missing stations between the reference dataset and ours, it still shows the best overall correspondence.
In the smallest size fraction, our analysis appears to miss a substantial number of Synechococcus reads, while showing higher contributions from Pelagophytes and Haptophytes. If these groups were more consistent with the reference results, the relative proportion of Synechococcus would likely increase.
For the medium size fraction, we again underestimate diatoms—largely because our dataset lacks a key station near the Strait of Gibraltar (see Biogeography maps), which skews the read distribution. We also find a slightly lower abundance of Trichodesmium compared to the reference data.
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reference_reads.png" width="50%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reads_bwa.png" width="49%" />
</p>

The station-by-station comparison showed generally strong agreement between our results and those reported by the authors, indicating that we were largely successful in reproducing their analysis. However, not all stations were available on the HPC, and due to time and storage constraints, we did not download the missing samples. These gaps affected our ability to fully match the reference results, as the presence or absence of specific stations can substantially influence total read counts and overall community proportions.

For the small size fraction, agreement was good overall, though Prochlorococcus tended to be underestimated. Notably, the close match in Haptophyte abundance suggests that one of the authors’ stations may have contained exceptionally high Synechococcus reads, skewing their total counts for this species.

In the mid-size fraction, the correspondence was almost identical, with the main differences occurring at station 18—where we slightly underestimated Diatoms and overestimated other Eukaryotic phytoplankton. Moreover, from this plot is now obvious how missing station 6 from our dataset explains the discrepancy in total read counts, given its very high abbundance in Diatoms.

The large size fraction had the most missing stations, which affected the broader patterns; nevertheless, for the stations we were able to compare, we reproduced the main trends. For example, station 25 was dominated by Diatoms and Dinoflagellates only, in both analyses, and station 18 showed similar high contributions from other eukaryotes. Station 30, in particular, displayed an excellent match between the two datasets.
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_08-5.png" width="70%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_5-20.png" width="70%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_20-180.png" width=70% />
</p>

### Scatterplots
Overall, the agreement between our results and those reported in the study is very strong. Both r and statistically significant p-values (except for Other cyanobacteria) support the authors’ conclusion that psbO is a reliable metric for estimating abundance compared to traditional methods. The same conclusion extends to the biovolume analysis, where, as noted in the original paper, correlations are slightly weaker than for abundance. We therefore concur that psbO provides a more robust measure of community abundance than biovolume.

-- **Scatterplots size 0.8-5 µm** psbO read counts vs Flow Cytometry counts (left column) and psbO derived biovolumne vs Flow Cytometry counts (right columns). % is relative to the total psbO reads within the size fraction.

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

 -- **Scatterplots size 20-180 µm** psbO read counts vs Optical Microscopy. % is relative to the total psbO reads within the size fraction.
Overall, the data distributions between the two analyses are very similar. However, because the sample size is small, even minor variations can lead to large changes in the statistical metrics, which explains why both our p-values and those reported by the authors are relatively large. In some cases—such as dinoflagellates—we do not even recover a positive correlation coefficient, reflecting the sensitivity of the statistics to limited sampling.

Finally, the same analysis could not be performed for the 5–20 µm size fraction because the corresponding reads table was not made available.

 Paper's reference
  <p float="center">
    <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/3d268952dca27fbc64709422bd05c28259ee439c/plots/psbO_vs_optMicr_counts_20-180um_ref.png" width="80%" />
  </p>
 Our results 
 <p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/d1ba4d8e0034e69755e479fdc57ffa5bbd0a4161/plots/psbO_vs_optMicr_counts_20-180um.png" width="80%" />
 </p>
 
### Biogeography
Overall, the main variability patterns are well captured across all size fractions (left side is the paper's reference, right side our results) and the major trends are consistent between the two analyses. In the smallest size fraction, both datasets show a wide spread of Synechococcus, indicating good agreement in the dominant groups. In the medium-size fraction, the absence of diatoms at one missing station is clearly reflected in our results, yet the overall pattern is still reproduced, with dinoflagellates emerging as the most abundant group in both analyses. For the large size fraction, we tend to overestimate haptophytes and miss some of the diversity present in the reference dataset; our results are more strongly dominated by dinoflagellates, whereas the authors observed greater variability, including higher contributions from diatoms and haptophytes in the eastern Mediterranean.
More broadly, we tend to underestimate chlorophytes and overestimate haptophytes, but the key community-level patterns remain consistent.
 <p float="center">
<img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/db742cb0e75890347a8fbd5b8d3585b810f725be/plots/biogeography_ref.png" width="45%" />
<img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/db742cb0e75890347a8fbd5b8d3585b810f725be/plots/biogeography_replicated.png" width="45%" />
 </p>
 
## Reproducibility Issues and Conclusions
- **Data Download (75% score)**: most datasets were accessible, and the authors were responsive and willing to share raw read files when contacted. However, the data locations were not clearly documented, leaving readers to determine the correct files on their own. In addition, key resources were missing: the optical microscopy reads table for the 5–20 µm size fraction was not available, and the 20–180 µm fraction lacked biovolume information, preventing biovolume calculations for the larger classes. Several stations were also missing from the HPC environment, which further limited replication.
- **Mapping and Filtering (50% score)**: Although the authors stated which mapping tools and versions were used, they did not describe the downstream filtering steps. These relied on a custom “bamFilter” tool that is no longer maintained (therefore, we were not able to use it because of versions too old), and the parameters were reported only in highly technical jargon, making them difficult to interpret or reproduce.
- **Analysis Workflow (30% score)**: many analytical steps were insufficiently described. The authors did not explain how RPKM was calculated, nor what their relative-abundance percentages were normalized against (station-level totals? sample totals? size-class totals?). To ensure internal consistency, we defined relative abundance as the percentage of total psbO reads within each size fraction.
- **Lack of Code or Workflow Sharing (0% score)**: No GitHub, Zenodo, or other code and data repository was provided. Not acceptable for a 2022 bioinformatics paper and a major issue for reproducibility!
- **Author Responsiveness (90% score)**: Despite these issues, the corresponding author was helpful and responsive when contacted for clarification. Therefore, the corresponding authors were actually corresponding.


### Conclusions
Although we were not able to reproduce the exact numerical results, we successfully replicated the main variability patterns across size fractions and taxa. The analysis proved to be highly sensitive to methodological choices—such as normalization metrics, filtering parameters, and station availability—underscoring the need for thorough documentation. Missing just a few samples, especially if they represent highly divergent communities, can substantially shift the results and alter community-level interpretations.

Therefore, this project leaves us with these main takeaways:
- Document every step of the workflow
- Explicitly define all variables and calculations
- Provide clear guidance for data access
- Maintain a public code repository (e.g., GitHub)
- Never assume that readers will know a priori your methods.

[The code for these figures can be found in the Jupyter Notebooks and R Scripts inside `scripts\`.]


