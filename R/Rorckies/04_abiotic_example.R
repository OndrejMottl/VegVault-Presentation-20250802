#----------------------------------------------------------#
#
#
#           VegVault - Presentation- 20250802
#
#            Example of abiotic data structure
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

x_lim <- c(-108, -106)
y_lim <- c(37, 39)

coord_buffer <- 0.5


#----------------------------------------------------------#
# 1. Load data -----
#----------------------------------------------------------#

data_rockies <-
  readr::read_rds(
    here::here("Data", "data_rockies.rds")
  ) %>%
  dplyr::filter(
    coord_long >= x_lim[1],
    coord_long <= x_lim[2],
    coord_lat >= y_lim[1],
    coord_lat <= y_lim[2]
  )


# Create list with all exported raster files
ras_lst <-
  list.files(
    here::here("Data/Spatial/Terrain/Terrain_rasters"),
    full.names = TRUE,
    pattern = ".tif"
  ) %>%
  stringr::str_subset(., pattern = "aux", negate = TRUE)


#----------------------------------------------------------#
# 2. Make high res elevation data -----
#----------------------------------------------------------#

# Load each raster and merge them together
# !!! This takes time !!!
all_rasters <-
  purrr::map(
    .progress = TRUE,
    .x = ras_lst,
    .f = ~ terra::rast(.x)
  ) %>%
  purrr::reduce(
    .f = ~ terra::merge(.x, .y)
  )

# turn into data.frame and filter for the area of interest
data_altitude_raw <-
  all_rasters %>%
  terra::crds() %>%
  data.frame() %>%
  tibble::as_tibble() %>%
  dplyr::bind_cols(
    terra::values(all_rasters, na.rm = TRUE)
  ) %>%
  purrr::set_names(nm = c("long", "lat", "alt_raw")) %>%
  dplyr::filter(
    long >= x_lim[1] - coord_buffer,
    long <= x_lim[2] + coord_buffer,
    lat >= y_lim[1] - coord_buffer,
    lat <= y_lim[2] + coord_buffer
  )


#----------------------------------------------------------#
# 2. Data wrangling -----
#----------------------------------------------------------#

# modern
data_modern_vegetation <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id == 1,
    age == 0
  ) %>%
  dplyr::distinct(
    dataset_id, sample_id,
    coord_long, coord_lat
  )

data_modern_gridpoints <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id == 4,
    age == 0,
    abiotic_variable_id == 1
  ) %>%
  dplyr::distinct(
    dataset_id, sample_id,
    sample_id_link,
    coord_long, coord_lat,
    abiotic_value
  ) %>%
  tidyr::drop_na(abiotic_value)

data_modern_vegetation_with_temp <-
  data_modern_vegetation %>%
  dplyr::select(-dataset_id) %>%
  dplyr::left_join(
    data_modern_gridpoints %>%
      dplyr::select(
        sample_id_link,
        abiotic_value
      ),
    by = c("sample_id" = "sample_id_link"),
    suffix = c("_vegetation", "_gridpoint")
  )


data_modern_links <-
  data_modern_vegetation %>%
  dplyr::select(-dataset_id) %>%
  dplyr::left_join(
    data_modern_gridpoints,
    by = c("sample_id" = "sample_id_link"),
    suffix = c("_vegetation", "_gridpoint")
  )

vec_grid_long <-
  data_modern_gridpoints %>%
  dplyr::distinct(coord_long) %>%
  dplyr::arrange(coord_long) %>%
  dplyr::pull(coord_long)

vec_grid_long_sub <-
  vec_grid_long[seq(1, length(vec_grid_long), 2)]

vec_grid_lat <-
  data_modern_gridpoints %>%
  dplyr::distinct(coord_lat) %>%
  dplyr::arrange(coord_lat) %>%
  dplyr::pull(coord_lat)

vec_grid_lat_sub <-
  vec_grid_lat[seq(1, length(vec_grid_lat), 2)]


# paleo
data_paleo_vegetation <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id == 2,
  ) %>%
  dplyr::distinct(
    dataset_id, sample_id,
    age
  )

data_paleo_gridpoints <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id == 4,
    abiotic_variable_id == 1
  ) %>%
  dplyr::distinct(
    dataset_id, sample_id,
    sample_id_link,
    age,
    abiotic_value
  ) %>%
  tidyr::drop_na(abiotic_value)

data_paleo_vegetation_with_temp <-
  data_paleo_vegetation %>%
  dplyr::left_join(
    data_paleo_gridpoints %>%
      dplyr::select(
        sample_id_link,
        abiotic_value
      ),
    by = c("sample_id" = "sample_id_link"),
    suffix = c("_vegetation", "_gridpoint")
  ) %>%
  dplyr::mutate(
    dataset_id_factor = as.factor(dataset_id)
  )

data_paleo_links <-
  data_paleo_vegetation %>%
  dplyr::left_join(
    data_paleo_gridpoints,
    by = c("sample_id" = "sample_id_link"),
    suffix = c("_vegetation", "_gridpoint")
  ) %>%
  dplyr::mutate(
    dataset_id_vegetation_factor = as.factor(dataset_id_vegetation),
    dataset_id_gridpoint_factor = as.factor(dataset_id_gridpoint)
  )

#----------------------------------------------------------#
# 3. Building the figure -----
#----------------------------------------------------------#

# modern figure
p1 <-
  ggplot2::ggplot(
    data = tibble(),
    ggplot2::aes(
      x = coord_long,
      y = coord_lat
    )
  ) +
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
    xintercept = vec_grid_long_sub,
    col = colors$beigeLight,
    linewidth = 0.1
  ) +
  ggplot2::geom_hline(
    yintercept = vec_grid_lat_sub,
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
  ggplot2::geom_point(
    data = tibble(
      dataset_type = c(
        "Vegetation plot",
        "Fossil pollen archive",
        "Gridpoint"
      )
    ),
    mapping = ggplot2::aes(
      col = dataset_type,
      shape = dataset_type,
      fill = dataset_type,
      y = 1,
      x = 1
    )
  ) +
  ggplot2::scale_color_manual(
    name = "Dataset type",
    values = c(
      colors$greenLight,
      colors$purpleLight,
      colors$greenDark
    ),
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive",
      "Gridpoint"
    )
  ) +
  ggplot2::scale_fill_manual(
    name = "Dataset type",
    values = c(
      colors$greenLight,
      colors$purpleLight,
      colors$greenDark
    ),
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive",
      "Gridpoint"
    )
  ) +
  ggplot2::scale_shape_manual(
    name = "Dataset type",
    values = c(
      21, # vegetation plot
      22, # fossil pollen archive
      24 # gridpoint
    ),
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive",
      "Gridpoint"
    )
  ) +
  ggnewscale::new_scale_fill() +
  # links
  ggplot2::geom_segment(
    data = data_modern_links,
    mapping = ggplot2::aes(
      x = coord_long_vegetation,
      y = coord_lat_vegetation,
      xend = coord_long_gridpoint,
      yend = coord_lat_gridpoint
    ),
    col = colors$grey,
    alpha = 1,
    linewidth = 1
  ) +
  # vegetation points
  ggplot2::geom_point(
    data = data_modern_vegetation_with_temp,
    mapping = ggplot2::aes(
      fill = abiotic_value
    ),
    size = 2,
    color = colors$greenLight,
    shape = 21,
  ) +
  ggplot2::geom_point(
    data = data_modern_vegetation_with_temp,
    size = 0.05,
    color = colors$black,
    alpha = 0.5
  ) +
  # grid points
  ggplot2::geom_point(
    data = data_modern_gridpoints,
    mapping = ggplot2::aes(
      fill = abiotic_value
    ),
    size = 2,
    color = colors$greenDark,
    shape = 24
  ) +
  ggplot2::scale_fill_gradient(
    high = colors$white,
    low = colors$blueLight,
    name = "MAT (°C)",
    breaks = scales::pretty_breaks(n = 5),
    limits = c(-4, 9)
  ) +
  ggplot2::coord_quickmap(
    xlim = x_lim,
    ylim = y_lim
  ) +
  ggplot2::scale_x_continuous(
    breaks = vec_grid_long_sub,
    labels = scales::number_format(accuracy = 0.1)
  ) +
  ggplot2::scale_y_continuous(
    breaks = vec_grid_lat_sub,
    labels = scales::number_format(accuracy = 0.1)
  ) +
  ggplot2::labs(
    x = "Longitude",
    y = "Latitude"
  ) +
  ggplot2::theme(
    plot.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0)
  )

p1_legend <-
  cowplot::get_legend(p1)

p1_without_legend <-
  p1 +
  ggplot2::theme(
    legend.position = "none"
  )

ggplot2::ggsave(
  filename = here::here("Materials", "R_generated", "plot_abiotic_example_spatial.png"),
  plot = p1,
  width = image_width,
  height = image_height * 1.4,
  units = image_units,
  dpi = 300,
  bg = colors$beigeLight
)

# temporal figure
p2 <-
  ggplot2::ggplot(
    data = tibble(),
    ggplot2::aes(
      x = age,
    )
  ) +
  ggplot2::scale_x_continuous(
    trans = "reverse",
    breaks = seq(0, 20e3, 2.5e3)
  ) +
  ggplot2::scale_y_continuous(
    limits = c(0.9, 6),
    breaks = seq(1, 5, 1)
  ) +
  # links
  ggplot2::geom_segment(
    data = data_paleo_links,
    mapping = ggplot2::aes(
      x = age_gridpoint,
      y = as.numeric(dataset_id_vegetation_factor) + 0.5,
      xend = age_vegetation,
      yend = as.numeric(dataset_id_vegetation_factor),
    ),
    color = colors$grey,
    linewidth = 0.5
  ) +
  # vegetation plots
  ggplot2::geom_line(
    data = data_paleo_vegetation_with_temp,
    mapping = ggplot2::aes(
      x = age,
      y = as.numeric(dataset_id_factor),
      group = dataset_id
    ),
    color = colors$grey,
    linewidth = 1,
    alpha = 0.5
  ) +
  ggplot2::geom_point(
    data = data_paleo_vegetation_with_temp,
    mapping = ggplot2::aes(
      x = age,
      y = as.numeric(dataset_id_factor),
      fill = abiotic_value
    ),
    size = 2,
    color = colors$purpleLight,
    shape = 22
  ) +
  ggplot2::geom_point(
    data = data_paleo_vegetation_with_temp,
    mapping = ggplot2::aes(
      x = age,
      y = as.numeric(dataset_id_factor)
    ),
    size = 0.1,
    color = colors$black,
    alpha = 0.5
  ) +
  # grid points
  ggplot2::geom_point(
    data = data_paleo_links %>%
      dplyr::distinct(dataset_id_vegetation_factor, age_gridpoint, abiotic_value),
    mapping = ggplot2::aes(
      x = age_gridpoint,
      y = as.numeric(dataset_id_vegetation_factor) + 0.5,
      fill = abiotic_value
    ),
    size = 2,
    color = colors$greenDark,
    shape = 24
  ) +
  ggplot2::scale_color_gradient(
    high = colors$white,
    low = colors$blueLight,
    name = "MAT (°C)",
    breaks = scales::pretty_breaks(n = 5),
    limits = c(-4, 9)
  ) +
  ggplot2::scale_fill_gradient(
    high = colors$white,
    low = colors$blueLight,
    name = "MAT (°C)",
    breaks = scales::pretty_breaks(n = 5),
    limits = c(-4, 9)
  ) +
  ggplot2::labs(
    x = "Age (cal yr BP)"
  ) +
  ggplot2::theme(
    axis.text.y = ggplot2::element_blank(),
    axis.ticks.y = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    plot.margin = ggplot2::margin(t = 5, r = 0, b = 0, l = 5)
  )

p2_legend <-
  cowplot::get_legend(
    p2 +
      ggplot2::theme(
        legend.position = "bottom",
        # legend.box = "horizontal",
        # legend.box.just = "left",
        # legend.box.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0),
        legend.title.position = "top"
      )
  )

p2_without_legend <-
  p2 +
  ggplot2::theme(
    legend.position = "none"
  )

ggplot2::ggsave(
  filename = here::here("Materials", "R_generated", "plot_abiotic_example_temporal.png"),
  plot = p2_without_legend,
  width = image_width,
  height = image_height / 1.8,
  units = image_units,
  dpi = 300,
  bg = colors$beigeLight
)

#-----------------------------------------------------------#
# This is currently not used,
#-----------------------------------------------------------#

p3 <-
  tibble(
    dataset_type = c(
      "Vegetation plot",
      "Fossil pollen archive",
      "Gridpoint"
    )
  ) %>%
  ggplot2::ggplot(
    ggplot2::aes(
      col = dataset_type,
      shape = dataset_type,
      fill = dataset_type,
      y = 1,
      x = 1
    )
  ) +
  ggplot2::geom_point(
    size = 2
  ) +
  ggplot2::scale_color_manual(
    name = "Dataset type",
    values = c(
      colors$greenLight,
      colors$purpleLight,
      colors$greenDark
    ),
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive",
      "Gridpoint"
    )
  ) +
  ggplot2::scale_fill_manual(
    name = "Dataset type",
    values = c(
      colors$greenLight,
      colors$purpleLight,
      colors$greenDark
    ),
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive",
      "Gridpoint"
    )
  ) +
  ggplot2::scale_shape_manual(
    name = "Dataset type",
    values = c(
      21, # vegetation plot
      22, # fossil pollen archive
      24 # gridpoint
    ),
    labels = c(
      "Vegetation plot",
      "Fossil pollen archive",
      "Gridpoint"
    )
  ) +
  ggplot2::theme(
    legend.position = "right",
    legend.key.spacing = ggplot2::unit(0, "cm"),
    legend.text = ggplot2::element_text(
      margin = ggplot2::margin(t = 0, r = 10, b = 0, l = 0)
    ),
    # legend.box.just = "left",
    legend.box.margin = ggplot2::margin(t = 0, r = 10, b = 0, l = 0),
    legend.title.position = "top"
  )

p3_legend <-
  cowplot::get_legend(
    p3
  )

p_merged_with_legend <-
  cowplot::plot_grid(
    p1_without_legend,
    p2_without_legend,
    NULL,
    cowplot::plot_grid(
      NA,
      p3_legend,
      p2_legend,
      NA,
      ncol = 4,
      nrow = 1,
      rel_widths = c(1, 3, 1, 1)
    ),
    NULL,
    nrow = 5,
    labels = c("A", "B", ""),
    label_colour = colors$white,
    label_fontfamily = "Renogare",
    label_size = text_size * 2,
    rel_heights = c(8, 4, 1, 1, 1)
  )

p_merged_without_legend <-
  cowplot::plot_grid(
    p1_without_legend,
    p2_without_legend,
    nrow = 2,
    labels = c("A", "B"),
    label_colour = colors$white,
    label_fontfamily = "Renogare",
    label_size = text_size * 2,
    rel_heights = c(8, 4)
  )
