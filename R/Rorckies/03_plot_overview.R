#----------------------------------------------------------#
#
#
#           VegVault - Presentation- 20250802
#
#              Make data overview for Rockies
#
#
#                       O. Mottl
#                         2025
#
#----------------------------------------------------------#

#----------------------------------------------------------#
# 0. Setup -----
#----------------------------------------------------------#

library(
  "here",
  quietly = TRUE,
  warn.conflicts = FALSE,
  character.only = TRUE,
  verbose = FALSE
)

source(
  here::here("R", "___setup_project___.R")
)

coord_buffer <- 10


#----------------------------------------------------------#
# 1. Load data -----
#----------------------------------------------------------#

data_rockies <-
  readr::read_rds(
    here::here("Data", "data_rockies.rds")
  )

data_altitude_raw <-
  readr::read_rds(
    here::here("Data/Spatial/Terrain/data_altitude_raw.rds")
  ) %>%
  dplyr::filter(
    long >= -120 - coord_buffer,
    long <= -100 + coord_buffer,
    lat >= 30 - coord_buffer,
    lat <= 50 + coord_buffer
  )


#----------------------------------------------------------#
# 1. spatial plot -----
#----------------------------------------------------------#

p1_with_with_legend <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id %in% c(1, 2) & age <= 200
  ) %>%
  dplyr::distinct(dataset_id, sample_id, .keep_all = TRUE) %>%
  dplyr::select(
    dataset_type_id,
    sample_id,
    coord_long, coord_lat
  ) %>%
  dplyr::left_join(
    data_rockies %>%
      dplyr::filter(
        dataset_type_id == 4 & age <= 200
      ) %>%
      dplyr::distinct(
        sample_id_link,
        abiotic_value
      ),
    by = c("sample_id" = "sample_id_link")
  ) %>%
  ggplot2::ggplot() +
  ggplot2::borders(
    fill = colors$brownDark,
    col = NA
  ) +
  # altitude
  ggplot2::geom_tile(
    data = data_altitude_raw,
    ggplot2::aes(
      x = long,
      y = lat,
      fill = alt_raw
    ),
    col = NA,
    alpha = 1
  ) +
  ggplot2::geom_vline(
    xintercept = seq(-120, -100, 5),
    col = colors$beigeLight,
    linewidth = 0.1
  ) +
  ggplot2::geom_hline(
    yintercept = seq(30, 50, 5),
    col = colors$beigeLight,
    linewidth = 0.1
  ) +
  ggplot2::scale_fill_gradient2(
    low = colors$brownDark,
    high = colors$beigeLight,
    mid = colors$brownLight,
    midpoint = 2000,
    name = "Altitude (m)",
    guide = "none"
  ) +
  ggnewscale::new_scale_fill() +
  # vegetation
  ggplot2::geom_point(
    ggplot2::aes(
      x = coord_long,
      y = coord_lat,
      fill = abiotic_value,
      col = as.factor(dataset_type_id),
      shape = as.factor(dataset_type_id),
      size = as.factor(dataset_type_id)
    ),
    alpha = 0.8
  ) +
  ggplot2::geom_point(
    data = data_rockies %>%
      dplyr::filter(
        dataset_type_id %in% c(1, 2) & age <= 200
      ) %>%
      dplyr::distinct(dataset_id, dataset_type_id, coord_long, coord_lat),
    ggplot2::aes(
      x = coord_long,
      y = coord_lat
    ),
    size = 0.1,
    col = colors$black,
    alpha = 0.5
  ) +
  ggplot2::coord_quickmap(
    xlim = c(-120, -100),
    ylim = c(30, 50)
  ) +
  ggplot2::scale_fill_gradient(
    low = colors$blueLight,
    high = colors$white,
    # midpoint = 10,
    breaks = scales::pretty_breaks(n = 5),
    limits = c(-10, 25),
    name = "MAT (°C)"
  ) +
  ggplot2::scale_color_manual(
    values = c(
      colors$greenLight,
      colors$purpleLight
    ),
    name = "Dataset type",
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive"
    )
  ) +
  ggplot2::scale_shape_manual(
    values = c(21, 22),
    name = "Dataset type",
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive"
    )
  ) +
  ggplot2::scale_size_manual(
    values = c(3, 5),
    name = "Dataset type",
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive"
    ),
    guide = "none"
  ) +
  ggplot2::labs(
    x = "Longitude",
    y = "Latitude"
  ) +
  ggplot2::guides(
    shape = ggplot2::guide_legend(
      override.aes = list(
        size = 5,
        fill = c(
          colors$greenLight,
          colors$purpleLight
        )
      ),
      nrow = 2,
      ncol = 1
    )
  ) +
  ggplot2::theme(
    legend.position = "right",
    # legend.box = "horizontal",
    # legend.box.just = "left",
    #     legend.spacing.x = ggplot2::unit(1, "cm"),
    # legend.title = ggplot2::element_blank()
  )

legend_points <-
  cowplot::get_legend(
    p1_with_with_legend +
      ggplot2::guides(
        fill = "none"
      )
  )

# cowplot::ggdraw(legend_points)

p1_without_legend <-
  p1_with_with_legend +
  ggplot2::theme(
    legend.position = "none"
  )


#----------------------------------------------------------#
# 2. temporal plot -----
#----------------------------------------------------------#

p2_with_legend <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id %in% c(1, 2)
  ) %>%
  dplyr::distinct(dataset_id, dataset_type_id, sample_id, age) %>%
  ggplot(
    ggplot2::aes(
      x = age,
      fill = as.factor(dataset_type_id)
    )
  ) +
  scale_y_continuous(
    trans = "log1p",
    breaks = c(1, 10, 100, 10e3, 10e4, 10e5, 10e6),
    labels = scales::scientific
  ) +
  ggplot2::scale_x_continuous(
    trans = "reverse",
    breaks = seq(0, 20e3, 5e3),
    labels = seq(0, 20, 5),
  ) +
  ggplot2::coord_cartesian(
    xlim = c(20e3, 0)
  ) +
  ggplot2::scale_fill_manual(
    values = c(
      colors$greenLight,
      colors$purpleLight
    ),
    name = "Dataset type",
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive"
    )
  ) +
  geom_histogram(
    binwidth = 1000,
    col = colors$black,
    linewidth = 0.1
  ) +
  ggplot2::labs(
    x = "Age (cal ka yr BP)",
    y = "Number of samples"
  )

legend_type <-
  cowplot::get_legend(
    p2_with_legend
  )

# cowplot::ggdraw(legend_type)

p2_without_legend <-
  p2_with_legend +
  ggplot2::theme(
    legend.position = "none"
  ) +
  ggplot2::annotation_custom(
    grob = legend_points,
    xmin = 10e3,
    xmax = 20e3,
    ymin = 1e3,
    ymax = 1e4
  )


#----------------------------------------------------------#
# 3. MAT per time -----
# ----------------------------------------------------------#

p3_with_legend <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id == 4,
  ) %>%
  dplyr::distinct(dataset_id, sample_id, sample_id_link, .keep_all = TRUE) %>%
  tidyr::drop_na(age, abiotic_value) %>%
  dplyr::select(
    dataset_id,
    sample_id,
    sample_id_link,
    age,
    abiotic_value
  ) %>%
  dplyr::left_join(
    data_rockies %>%
      dplyr::filter(
        dataset_type_id %in% c(1, 2)
      ) %>%
      dplyr::distinct(
        dataset_id, sample_id, dataset_type_id
      ),
    by = c("sample_id_link" = "sample_id"),
    suffix = c("_gridpoint", "_vegetation")
  ) %>%
  tidyr::drop_na(dataset_type_id) %>%
  dplyr::distinct(
    dataset_type_id, dataset_id_vegetation, age, abiotic_value
  ) %>%
  ggplot2::ggplot() +
  ggplot2::scale_x_continuous(
    trans = "reverse",
    breaks = seq(0, 20e3, 5e3),
    labels = seq(0, 20, 5),
  ) +
  ggplot2::coord_cartesian(
    xlim = c(20e3, 0)
  ) +
  ggplot2::geom_line(
    ggplot2::aes(
      x = age,
      y = abiotic_value,
      # col = abiotic_value,
      group = dataset_id_vegetation
    ),
    linewidth = 1,
    col = colors$grey,
    alpha = 0.5
  ) +
  ggplot2::geom_point(
    ggplot2::aes(
      x = age,
      y = abiotic_value,
      fill = abiotic_value,
      col = as.factor(dataset_type_id),
      shape = as.factor(dataset_type_id),
    ),
    size = 2,
    alpha = 0.8
  ) +
  ggplot2::geom_point(
    ggplot2::aes(
      x = age,
      y = abiotic_value
    ),
    size = 0.1,
    col = colors$black,
    alpha = 0.5
  ) +
  ggplot2::scale_fill_gradient(
    low = colors$blueLight,
    high = colors$white,
    # midpoint = 10,
    breaks = scales::pretty_breaks(n = 5),
    limits = c(-10, 25),
    name = "MAT (°C)"
  ) +
  ggplot2::scale_color_manual(
    values = c(
      colors$greenLight,
      colors$purpleLight
    ),
    name = "Dataset type",
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive"
    )
  ) +
  ggplot2::scale_shape_manual(
    values = c(21, 22),
    name = "Dataset type",
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive"
    )
  ) +
  ggplot2::labs(
    x = "Age (cal ka yr BP)",
    y = "MAT (°C)"
  ) +
  ggplot2::theme(
    legend.position = "bottom",
    legend.title.position = "top",
  )

legend_temperature <-
  cowplot::get_legend(
    p3_with_legend +
      ggplot2::guides(
        shape = "none",
        col = "none"
      )
  )

# cowplot::ggdraw(legend_temperature)

p3_without_legend <-
  p3_with_legend +
  ggplot2::theme(
    legend.position = "none"
  )


#----------------------------------------------------------#
# 4. traits -----
# ----------------------------------------------------------#

vec_taxa_id_traits <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id == 3
  ) %>%
  dplyr::distinct(taxon_id_trait) %>%
  tidyr::drop_na() %>%
  dplyr::pull(taxon_id_trait)

vec_taxa_id_vegetation <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id %in% c(1, 2)
  ) %>%
  dplyr::distinct(taxon_id) %>%
  tidyr::drop_na() %>%
  dplyr::pull(taxon_id)

vec_taxa_all <-
  c(
    vec_taxa_id_traits,
    vec_taxa_id_vegetation
  ) %>%
  unique()

con <-
  DBI::dbConnect(
    RSQLite::SQLite(),
    path_to_vegvault
  )

data_class_table <-
  dplyr::tbl(con, "TaxonClassification") %>%
  dplyr::filter(
    taxon_id %in% vec_taxa_all
  ) %>%
  dplyr::select(taxon_id, taxon_genus) %>%
  dplyr::collect()


data_to_plot_traits <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id == 3
  ) %>%
  tidyr::drop_na(trait_domain_id, trait_name, trait_value) %>%
  dplyr::distinct(
    dataset_id,
    sample_id,
    taxon_id_trait,
    .keep_all = TRUE
  ) %>%
  dplyr::select(
    taxon_id_trait,
    trait_value
  ) %>%
  dplyr::left_join(
    data_class_table,
    by = dplyr::join_by("taxon_id_trait" == "taxon_id")
  ) %>%
  dplyr::group_by(
    taxon_genus
  ) %>%
  dplyr::summarise(
    trait_value = mean(trait_value, na.rm = TRUE),
    .groups = "drop"
  )

vec_outliers <-
  data_to_plot_traits %>%
  purrr::chuck("trait_value") %>%
  boxplot(plot = FALSE) %>%
  purrr::chuck("out")

data_to_plot_traits_filtered <-
  data_to_plot_traits %>%
  dplyr::filter(
    !trait_value %in% vec_outliers
  )


p4 <-
  data_to_plot_traits_filtered %>%
  ggplot2::ggplot(
    mapping = ggplot2::aes(
      y = trait_value,
      x = 1
    ),
  ) +
  ggplot2::geom_violin(
    col = NA,
    fill = colors$blueDark
  ) +
  ggplot2::geom_jitter(
    col = colors$black,
    size = 0.5,
    alpha = 0.5,
    width = 0.1
  ) +
  ggplot2::geom_boxplot(
    col = colors$black,
    outlier.shape = NA,
    width = 0.1,
  ) +
  ggplot2::labs(
    y = "Average plant height of genus (cm)",
  ) +
  ggplot2::scale_y_continuous(
    breaks = scales::breaks_pretty(n = 5)
  ) +
  ggplot2::theme(
    axis.text.x = ggplot2::element_blank(),
    axis.ticks.x = ggplot2::element_blank(),
    axis.title.x = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.minor.x = ggplot2::element_blank(),
    legend.position = "none"
  )



#----------------------------------------------------------#
# 5. Construct the plot -----
# ----------------------------------------------------------#

p_combined_legends <-
  cowplot::plot_grid(
    legend_points,
    legend_temperature,
    ncol = 2,
    nrow = 1
  )

p_combined_legends_1 <-
  cowplot::plot_grid(
    p1_without_legend,
    p_combined_legends,
    ncol = 1,
    nrow = 2,
    rel_heights = c(1, 0.2),
    labels = c("A", ""),
    label_colour = colors$white,
    label_fontfamily = "Renogare",
    label_size = text_size * 2
  )

p_combined_23 <-
  cowplot::plot_grid(
    p2_without_legend +
      theme(
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = ggplot2::margin(0, 0, 0, 0)
      ),
    p3_without_legend,
    ncol = 1,
    nrow = 2,
    align = "v",
    labels = c("B", "C"),
    label_colour = colors$white,
    label_fontfamily = "Renogare",
    label_size = text_size * 2
  )

p_combined_all <-
  cowplot::plot_grid(
    p_combined_legends_1,
    p_combined_23,
    p4,
    ncol = 3,
    nrow = 1,
    rel_widths = c(16, 10, 8),
    labels = c("", "", "D"),
    label_colour = colors$white,
    label_fontfamily = "Renogare",
    label_size = text_size * 2
  )

ggplot2::ggsave(
  filename = here::here("Materials", "R_generated", "plot_overview_rockies.png"),
  plot = p_combined_all,
  width = image_width * 1.2,
  height = image_height * 1,
  units = image_units,
  dpi = 150,
  bg = colors$beigeLight
)
