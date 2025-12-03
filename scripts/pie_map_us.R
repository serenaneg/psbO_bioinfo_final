# Note: need pie_map_functions.R, rpkm csvs, and station coordinate file
# in order to run this script

library(dplyr)
library(ggforce)
library(ggplot2)
library(tidyr)
library(patchwork)
library(cowplot)
library(grid)

setwd("//wsl.localhost/Ubuntu-24.04/home/ahochroth/enviro_bioinfo/final_project")

# Read in data frames of non-zero reads for each size class

# 0.8-5um
small <- read.csv("08_5_nonZero_rpkm_assigned_tax_bwa.csv") %>%
  rename(lineage = assigned_tax, rpkm = RPKM) 
small <- small[small$lineage != "", ] # Get rid of blanks in lineage
small <- small[small$lineage != "Other cyanobacteria", ] # Dont want this for this plot
small$size_fraction = "0.8-5" # Add size fraction label

# Do this to get RPKM on similar magnitude to reference paper (no idea what is up
# with their rpkm)
small$rpkm = small$rpkm / 10^6

# 5-20um
mid   <- read.csv("5_20_nonZero_rpkm_assigned_tax_bwa.csv")%>% 
  rename(lineage = assigned_tax, rpkm = RPKM)
mid <- mid[mid$lineage != "", ]
mid$size_fraction = "5-20"

# Do this to get RPKM on similar magnitude to reference
mid$rpkm = mid$rpkm / 10^6

# 20-180um
large <- read.csv("20_180_nonZero_rpkm_assigned_tax_bwa.csv")%>% 
  rename(lineage = assigned_tax, rpkm = RPKM)
large <- large[large$lineage != "", ]
large$size_fraction = "20-180"
large <- na.omit(large)

# Do this to get RPKM on similar magnitude to reference
large$rpkm = large$rpkm / 10^6

# Station files with coords
stations <- read.csv("tara_stations.csv")

# Load in the pie map function
source("pie_map_functions.R")

#________________________________________________________________________

# Standardized color scale for the lineages
lineage_colors <- c(
  "Diatoms"                        = "#ff7f0e",
  "Chlorophytes"                    = "#1f77b4",
  "Dinoflagellates"                = "#2ca02c",
  "Other eukaryotic phytoplankton" = "#9467bd",
  "Haptophytes"                    = "#d62728",
  "Pelagophytes"                   = "#8c564b",
  "Prochlorococcus"                = "#bcbd22",
  "Synechococcus"                  = "#e377c2",
  "Trichodesmium"                  = "#17becf"
)

# Standardized list order for the lineages
all_lineages <- c(
  "Prochlorococcus", 
  "Synechococcus", 
  "Trichodesmium", 
  "Dinoflagellates", 
  "Diatoms", 
  "Haptophytes", 
  "Chlorophytes", 
  "Pelagophytes",  
  "Other eukaryotic phytoplankton"
)


# choose radius_scale to make the pie charts more visible and similar to paper
pie_scale_small <- 0.8
pie_scale_mid   <- 0.8
pie_scale_large <- 0.9

#________________________________________________________________________


#   Generate Pie-Maps (these use the same radius_scale numbers)
# 0.8-5um
p_small <- plot_pies_on_map(
  df = small,
  stations_df = stations,
  size_label = "0.8–5 µm",
  lineage_levels = all_lineages,
  lineage_colors = lineage_colors,
  radius_scale = pie_scale_small
)

# 5-20um
p_mid <- plot_pies_on_map(
  df = mid,
  stations_df = stations,
  size_label = "5–20 µm",
  lineage_levels = all_lineages,
  lineage_colors = lineage_colors,
  radius_scale = pie_scale_mid
)

# 20-180um
p_large <- plot_pies_on_map(
  df = large,
  stations_df = stations,
  size_label = "20–180 µm",
  lineage_levels = all_lineages,
  lineage_colors = lineage_colors,
  radius_scale = pie_scale_large
)

#__________________________________________________________________________

# Regularize the lineages (ensure factors have same levels across dfs)
small$lineage <- factor(small$lineage, levels = all_lineages)
mid$lineage   <- factor(mid$lineage,   levels = all_lineages)
large$lineage <- factor(large$lineage, levels = all_lineages)

# Build a dummy tibble to generate a single figure legend for all three plots
legend_dummy <- tibble(
  x = 1:length(all_lineages),
  y = 1,
  lineage = factor(all_lineages, levels = all_lineages)
)

# Generate the legend using the standardized taxa/colors
p_legend_source <- ggplot(legend_dummy, aes(x, y, fill = lineage)) +
  geom_tile() +
  scale_fill_manual(values = lineage_colors, breaks = all_lineages, labels = all_lineages) +
  theme(
    legend.position = "right",
    legend.key.size = unit(0.9, "cm"),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold"),
    legend.spacing.y = unit(0.3, "cm")
  )

# Isolate legend
legend_grob <- get_legend(p_legend_source)


# Remove legends from the three panels

p_small_noleg <- p_small + theme(legend.position = "none")
p_mid_noleg   <- p_mid   + theme(legend.position = "none")
p_large_noleg <- p_large + theme(legend.position = "none")

#__________________________________________________________________________

# Add right-side strip labels
p_small_strip <- make_right_strip(p_small_noleg, "0.8–5 µm")
p_mid_strip   <- make_right_strip(p_mid_noleg,   "5–20 µm")
p_large_strip <- make_right_strip(p_large_noleg, "20–180 µm")

# Force zero margins on the strips to remove whitespace between the plots
p_small_strip  <- p_small_strip  + theme(plot.margin = margin(0,0,0,0))
p_mid_strip    <- p_mid_strip    + theme(plot.margin = margin(0,0,0,0))
p_large_strip  <- p_large_strip  + theme(plot.margin = margin(0,0,0,0))

# Add rpkm legends to figures
p_small_strip  <- p_small_strip  + make_rpkm_legend(small, size_scale = 1.0)
p_mid_strip    <- p_mid_strip    + make_rpkm_legend(mid,   size_scale = 1.0)
p_large_strip  <- p_large_strip  + make_rpkm_legend(large, size_scale = 1.0)

#__________________________________________________________________________

# stack the panels vertically
plots_col <- (
  p_small_strip /
    p_mid_strip /
    p_large_strip
) &
  theme(plot.margin = unit(c(0,0,0,0), "pt"))

# Combine everything into final plot
final <- plot_grid(plots_col, legend_grob, ncol = 2, rel_widths = c(1, 0.15))

# Save as pdf
pdf("bigplot_us_test.pdf", width = 14, height = 16)
print(final)
dev.off()
