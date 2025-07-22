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
  dplyr::select(-dataset_id) %>%
  dplyr::left_join(
    data_paleo_gridpoints %>%
      dplyr::select(
        sample_id_link,
        abiotic_value
      ),
    by = c("sample_id" = "sample_id_link"),
    suffix = c("_vegetation", "_gridpoint")
  )

data_paleo_links <-
  data_paleo_vegetation %>%
  dplyr::select(-dataset_id) %>%
  dplyr::left_join(
    data_paleo_gridpoints,
    by = c("sample_id" = "sample_id_link"),
    suffix = c("_vegetation", "_gridpoint")
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
    linewidth = 0.5
  ) +
  # vegetation points
  ggplot2::geom_point(
    data = data_modern_vegetation_with_temp,
    mapping = ggplot2::aes(
      fill = abiotic_value
    ),
    size = 1,
    color = colors$greenLight,
    shape = 21,
  ) +
  # grid points
  ggplot2::geom_point(
    data = data_modern_gridpoints,
    mapping = ggplot2::aes(
      fill = abiotic_value
    ),
    size = 3,
    color = colors$greenDark,
    shape = 23
  ) +
  ggplot2::scale_fill_gradient(
    low = colors$greenDark,
    high = colors$white,
    name = "Temperature (°C)",
    breaks = scales::pretty_breaks(n = 5)
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
  )

p1_legend <-
  cowplot::get_legend(p1)

p1_without_legend <-
  p1 +
  ggplot2::theme(
    legend.position = "none"
  )

ggplot2::ggsave(
  filename = here::here("Materials", "R_generated", "plot_abiotic_example.png"),
  plot = p1,
  width = image_width * 1,
  height = image_height * 1,
  units = image_units,
  dpi = 150,
  bg = colors$beigeLight
)


# temporal figure
(
  p2

)
