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
We first evaluated which mapping tool performed better by testing both on the 5–20 µm size fraction. BWA recovered slightly more reads than Minimap2 overall. Most of the reads missed by Minimap2 belonged to other eukaryotic phytoplankton groups, whereas BWA retrieved a higher number of Trichodesmium reads. Therefore, all he following analyses have been performed using BWA, because performance was comparable and to be consistent with the tool used in the original paper.

<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reads_minimap_bwa.png" 
    width="45%"/>
</p>

#### Comparison between read counts
Our comparison shows good agreement for the largest size fraction, although we underestimate diatoms because one station in the Strait of Gibraltar is missing (see Biogeography figure). Interestingly, this is also the fraction for which the two analyses are most comparable, despite having the greatest number of missing stations. Overall, our counts show a higher contribution of haptophytes; removing these would increase the relative proportion of Synechococcus. For the smallest size fraction, we observe elevated pelagophytes and proportionally fewer Synechococcus, but still an overrepresentation of haptophytes. In the mid–size fraction, we again underestimate diatoms due to the missing Gibraltar station and show a slightly lower abundance of Trichodesmium.
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reference_reads.png" width="50%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/fc9cba0073b20ecc2f90fcbedc8744fbe0272cb5/plots/reads_bwa.png" width="49%" />
</p>

The station-by-station comparison showed good agreement between our results and those reported by the authors. However, not all sample stations were available on the HPC, and due to time and storage constraints, we chose not to download the additional missing samples.

On a station by station, fine stations, we did a good job in reprecating the analysis and good comparison, however, we didn't always have the same stations there were few sample that biased the results for the results and wherethe we had or not that samples affets our capability in reproducing the reustls.


Small size fraction: good greement for the most part, pro under estimated but intestring hapt looks similar which might mean that one of their stations had very high reads of synechochocossu which skewed the results for the total reads counts.

Mid Size class: almost identiycal agreement, station 32 under estimating diatoms and overest  estimaing hapt. However, missing station 6 is the reason why we have different total reds counts.

Large size fraction: missing a lot more station, which affect the picture, but for the stations we replicate the general trends. Maybe not the same number but we;re replicating the main patterns eg. station 24 just diat and dinoflageklates and sta 18 18 big chnck of other euks. Station 30 stands out for great matching.
<p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_08-5.png" width="70%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_5-20.png" width="70%" />
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/985f48bdf3a042c69f33a4da3962eec03e01492a/plots/byStation_reads_20-180.png" width=70% />
</p>

### Scatterplots
In general, the overall agreement is really good. Larger p-values can be explained by the fact that we had a less number of stations. We support their conclusion that psbO is a good metric for abundance compared to traditional methods. R values are high eccept for cyanobacteria and p-values are always singificant. Same conlcusion can be extended to the biovolume analysis. As the paper found, the correlation is slightly worst with biovolume.  We therefore concur with thei conclusion that psbO is a better metric for reads abbundance than biovolume.

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
Overall,the data distribution looks similar, but due small sample size the, minor variation cuses lareg variation in the statistic a and both our and their p value are large and someting is not even find a positive r (dinoflagellates)

 Paper's reference
  <p float="center">
    <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/3d268952dca27fbc64709422bd05c28259ee439c/plots/psbO_vs_optMicr_counts_20-180um_ref.png" width="80%" />
  </p>
 Our results 
 <p float="center">
  <img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/d1ba4d8e0034e69755e479fdc57ffa5bbd0a4161/plots/psbO_vs_optMicr_counts_20-180um.png" width="80%" />
 </p>
 
### Biogeography
The station not too fat off, but major trands are visible between both, for instance the smallest size fraction, both we have wide spread of synechococcus; in the midium size fraction is clear the missing of iatoms from one station, but overall we;re repridcitng the paptern where dinoflagellates are the most abundant sepecies. Finally, for large size fraction we have some over estimation of haptophytes and in general missing some diversity that they have, out is mostly dominated by dinoflageltes, when instead they had more varibalily (e.g. more diatomes and happt in the east med). IN general we're understainamted chlorophytes  over estimating hapt. 
 <p float="center">
<img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/db742cb0e75890347a8fbd5b8d3585b810f725be/plots/biogeography_ref.png" width="45%" />
<img src="https://github.com/serenaneg/psbO_bioinfo_final/blob/db742cb0e75890347a8fbd5b8d3585b810f725be/plots/biogeography_replicated.png" width="45%" />
 </p>
 
## Reproducibility Issues and Conclusions
- Data Download: 75%. Generally the data were available and they were available for clarifications and shared their raw reds data, but they were not clear in pointing out the resources aand was left to the redeard to figure out the correct file. Also, for Optical Miscriscopy they didn't make available the reads table for the medium size but only 20-180, which in additoin didnt have biovolume information, therefore we weren't able to calculate that for the larger size fractions. Missin stationgs from the HPC for some fraxctions.
- Mapping/Filtering: 30%. They mentioned whihc tool and the version but no indication about filering which was downstream, dutim filtering paramamter from custim develped bamFilter tool which was not kept updated. Parametes were mentioned only in very high jargon and not helpsul fro data relplication.
- Analysis. 'Everythin was relative'.They did not decribe how they calculated RPKM and whwn they did mention rpkm it was not clear what they used rpkm for (e.g. relative abb within a station or all station). For the scatter plots they had % relative reads but they never exlain relative to what, id the station, the sample, the total size abundance, therefore we decied to do % relative to the total psbO reads within a give size fraction


