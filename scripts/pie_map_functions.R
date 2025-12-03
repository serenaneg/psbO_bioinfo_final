
# Function to generate pie plots on a world map, with the size of the pie plots
# scaled by the total RPKM of the sample
# Pie plots are placed at the coords of the TARA sampling station
# Default lat/lon ranges in function header are set to focus on the Mediterranean
plot_pies_on_map <- function(df, stations_df, size_label,
                             radius_scale = 0.15,
                             lon_min = -10, lon_max = 40,
                             lat_min = 28,  lat_max = 48,
                             lineage_levels,
                             lineage_colors) {
  
  # Use RPKM to compute relative abundances of taxa within a sample
  pie_df <- df %>%
    mutate(lineage = factor(lineage, levels = names(lineage_colors))) %>%
    group_by(Station, lineage) %>%
    summarise(total = sum(rpkm, na.rm = TRUE), .groups = "drop") %>%
    group_by(Station) %>%
    mutate(station_total = sum(total),
           prop = total / station_total) %>%
    ungroup()
  
  # Merge with coordinates from tara stations
  pie_df <- pie_df %>%
    left_join(stations_df, by = "Station") %>%
    drop_na(Latitude, Longitude)
  
  # Scale radius of pie chart to total RPKM for the station
  # I use the square root to mitigate order of magnitude differences between RPKMS
  pie_df <- pie_df %>%
    mutate(radius = sqrt(station_total) * radius_scale)
  
  # Weirdl need to individually specify the arc geometry for each pie chart
  pie_df <- pie_df %>%
    group_by(Station) %>%
    arrange(factor(lineage, levels = lineage_levels)) %>%
    mutate(start = c(0, head(cumsum(prop), -1)) * 2*pi,
           end   = cumsum(prop) * 2*pi) %>%
    ungroup()
  
  # Correct aspect ratio of pie charts to account for the fact that I am not
  # using a projection when mapping these
  # aspect ratio correction = 1 / cos(latitude)
  mean_lat <- mean(c(lat_min, lat_max))
  aspect_ratio <- 1 / cos(mean_lat * pi / 180)
  
  # Plot the pie charts on a world map
  p <- ggplot() +
    borders("world", fill = "grey90", colour = "grey40", linewidth = 0.3) +
    geom_arc_bar(
      data = pie_df,
      aes(
        x0 = Longitude,
        y0 = Latitude,
        r0 = 0,
        r = radius,
        start = start,
        end = end,
        fill = lineage
      ),
      color = "black",       # thin black lines between slices of pies
      linewidth = 0.25,      
      alpha = 0.85         
    ) +
    scale_fill_manual(values = lineage_colors) + # specify the colors
    coord_sf(expand = FALSE) + # attempt to use two coord systems to enforce good looking pies
    coord_fixed(
      ratio = aspect_ratio,
      xlim = c(lon_min, lon_max),
      ylim = c(lat_min, lat_max),
      expand = FALSE
    ) +
    theme_minimal() + # get rid of the coord annotations to match paper
    theme(
      axis.title = element_blank(),
      axis.text  = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      panel.border = element_rect(color = "grey60", fill = NA, linewidth = 0.6),
      panel.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(0, 0, 0, 0)
    )
  
  return(p)
}


# Function to make the grey label to the right of each plot with the size
# fraction information
make_right_strip <- function(plot, label_text) {
  
  # Object that is a grey rectangle spanning the full right side of each plot
  rect <- rectGrob(
    x = 0.887,        # center of the strip
    y = 0.5,
    width  = 0.03,   # adjust strip width
    height = 0.99,
    gp = gpar(fill = "grey85", col = NA)
  )
  
  # Draw the shape and then add the text on top
  ggdraw() +
    # main plot on the left 88%
    draw_plot(plot, x = 0, width = 0.88, height = 1) +
    # grey rectangle
    draw_grob(rect) +
    # vertical label
    draw_label(
      label_text,
      x = 0.888,
      y = 0.5,
      angle = 270,
      fontface = "bold",
      size = 20,
      hjust = 0.5,
      vjust = 0.5
    )
}


# Function to make the rpkm legend from concentric circles
make_rpkm_legend <- function(df,
                             size_scale = 1,
                             x_npc = 0.80,
                             y_npc = 0.1) {
  
  # lazy recompute of RPKM totals for each station
  totals <- df %>%
    group_by(Station) %>%
    summarise(station_total = sum(rpkm, na.rm = TRUE), .groups = "drop")
  
  # Take the max rpkm value for the biggest circle, and scale it down for the 
  # some representative smaller circles
  max_rpkm <- max(totals$station_total)
  legend_vals <- c(max_rpkm, max_rpkm/2, max_rpkm/4)
  
  # need to distinguish between coordinates on the world map, and location on
  # the image panel. This part situates the circles in the grid space
  # tried to get it to be the same size as the pie plots but didnt work, so
  # instead I use size_scale to manually adjust the radius
  r_npc <- sqrt(legend_vals / max_rpkm) * 0.05 * size_scale
  
  # Get length of segments connecting labels and circles
  connector_len  <- 0.017
  
  # Build tree of objects that are placed on image together
  g <- grobTree(
    
    # title of circles
    textGrob(
      "rpkm",
      x = unit(x_npc, "npc"),
      y = unit(y_npc + max(r_npc)*2.5, "npc"),
      gp = gpar(fontsize = 15, fontface = "bold")
    ),
    
    # circles (aligned so bottoms match)
    circleGrob(
      x = unit(x_npc, "npc"),
      y = unit(y_npc, "npc") + unit(r_npc[1], "npc"),
      r = unit(r_npc[1], "npc"),
      gp = gpar(col = "black", fill = NA)
    ),
    circleGrob(
      x = unit(x_npc, "npc"),
      y = unit(y_npc, "npc") + unit(r_npc[2], "npc"),
      r = unit(r_npc[2], "npc"),
      gp = gpar(col = "black", fill = NA)
    ),
    circleGrob(
      x = unit(x_npc, "npc"),
      y = unit(y_npc, "npc") + unit(r_npc[3], "npc"),
      r = unit(r_npc[3], "npc"),
      gp = gpar(col = "black", fill = NA)
    ),
    
    # Connecting segments from circles to labels
    # largest circle
    segmentsGrob(
      x0 = unit(x_npc + r_npc[1]/2.2, "npc"),
      x1 = unit(x_npc + r_npc[1]/2.2 + connector_len, "npc"),
      y0 = unit(y_npc + r_npc[1]*1.5, "npc"),
      y1 = unit(y_npc + r_npc[1]*1.5, "npc"),
      gp = gpar(col = "black", lwd = 0.6)
    ),
    
    # medium circle
    segmentsGrob(
      x0 = unit(x_npc + r_npc[2]/2.2, "npc"),
      x1 = unit(x_npc + r_npc[2]/2.2 + connector_len, "npc"),
      y0 = unit(y_npc + r_npc[2]*1.5, "npc"),
      y1 = unit(y_npc + r_npc[2]*1.5, "npc"),
      gp = gpar(col = "black", lwd = 0.6)
    ),
    
    # smallest circle
    segmentsGrob(
      x0 = unit(x_npc + r_npc[3]/2.2, "npc"),
      x1 = unit(x_npc + r_npc[3]/2.2 + connector_len, "npc"),
      y0 = unit(y_npc + r_npc[3]*1.5, "npc"),
      y1 = unit(y_npc + r_npc[3]*1.5, "npc"),
      gp = gpar(col = "black", lwd = 0.6)
    ),
    
    # Add text labels to right of connector lines
    # I multiply the raw rpkm values from the paper by 100 because that way they
    # match better with the rpkm values shown in figure 8 of the paper
    textGrob(
      sprintf("%.1f", legend_vals*100), 
      x = unit(x_npc + r_npc/2.2 + connector_len, "npc"),
      y = unit(y_npc + r_npc*1.5, "npc"),
      just = "left",
      gp = gpar(fontsize = 9)
    )
  )
  
  # No boundary to object tree
  annotation_custom(
    grob = g,
    xmin = -Inf, xmax = Inf,
    ymin = -Inf, ymax = Inf
  )
}








