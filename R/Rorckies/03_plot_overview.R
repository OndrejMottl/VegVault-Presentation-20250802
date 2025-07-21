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
    alpha = 1
  ) +
  ggplot2::geom_point(
    data = data_rockies %>%
      dplyr::filter(
        dataset_type_id %in% c(1, 2)
      ) %>%
      dplyr::distinct(dataset_id, dataset_type_id, coord_long, coord_lat),
    ggplot2::aes(
      x = coord_long,
      y = coord_lat
    ),
    size = 0.1,
    col = colors$black,
  ) +
  ggplot2::coord_quickmap(
    xlim = c(-120, -100),
    ylim = c(30, 50)
  ) +
  ggplot2::scale_fill_gradient(
    low = colors$greenDark,
    high = colors$white,
    name = "Temperature (°C)"
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


p_1_legend <-
  cowplot::get_legend(
    p1_with_with_legend
  )

cowplot::ggdraw(p_1_legend)

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
    labels = scales::comma
  ) +
  ggplot2::scale_x_continuous(
    trans = "reverse",
    breaks = c(0, 5000, 10000, 15000, 20000),
    labels = c(
      "0",
      "5,000",
      "10,000",
      "15,000",
      "20,000"
    )
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
  ) +
  ggplot2::labs(
    x = "Age (cal yr BP)",
    y = "Number of samples"
  )

p2_legend <-
  cowplot::get_legend(
    p2_with_legend
  )

cowplot::ggdraw(p2_legend)

p2_without_legend <-
  p2_with_legend +
  ggplot2::theme(
    legend.position = "none"
  )


#----------------------------------------------------------#
# 3. Temperature per time -----
# ----------------------------------------------------------#

p3_with_legend <-
  data_rockies %>%
  dplyr::filter(
    dataset_type_id == 4,
  ) %>%
  dplyr::distinct(dataset_id, sample_id, .keep_all = TRUE) %>%
  dplyr::select(
    dataset_id,
    age,
    abiotic_value
  ) %>%
  ggplot2::ggplot() +
  ggplot2::scale_x_continuous(
    trans = "reverse",
    breaks = c(0, 5000, 10000, 15000, 20000),
    labels = c(
      "0",
      "5,000",
      "10,000",
      "15,000",
      "20,000"
    )
  ) +
  ggplot2::geom_line(
    ggplot2::aes(
      x = age,
      y = abiotic_value,
      col = abiotic_value,
      group = dataset_id
    ),
    linewidth = 1,
  ) +
  ggplot2::geom_point(
    ggplot2::aes(
      x = age,
      y = abiotic_value,
      col = abiotic_value,
    ),
    size = 5
  ) +
  ggplot2::scale_color_gradient(
    low = colors$greenDark,
    high = colors$white,
    name = "Temperature (°C)"
  ) +
  ggplot2::labs(
    x = "Age (cal yr BP)",
    y = "Temperature (°C)"
  )

p3_legend <-
  cowplot::get_legend(
    p3_with_legend
  )

cowplot::ggdraw(p3_legend)

p3_without_legend <-
  p3_with_legend +
  ggplot2::theme(
    legend.position = "none"
  )


# ----------------------------------------------------------#

data_rockies %>%
  dplyr::filter(
    dataset_type_id %in% c(1, 2)
  ) %>%
  dplyr::distinct(dataset_id, dataset_type_id, coord_long, coord_lat) %>%
  ggplot2::ggplot() +
  ggplot2::borders(
    fill = colors$brownDark,
    col = NA
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
  ggplot2::geom_point(
    ggplot2::aes(
      x = coord_long,
      y = coord_lat,
      color = as.factor(dataset_type_id)
    ),
    size = 3
  ) +
  ggplot2::geom_point(
    ggplot2::aes(
      x = coord_long,
      y = coord_lat,
    ),
    size = 0.1,
    col = colors$black,
  ) +
  ggplot2::coord_quickmap(
    xlim = c(-120, -100),
    ylim = c(30, 50)
  ) +
  ggplot2::scale_fill_gradient2(
    low = colors$brownDark,
    high = colors$beigeLight,
    mid = colors$brownLight,
    midpoint = 2000,
    name = "Altitude (m)"
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
  )


con <-
  DBI::dbConnect(
    RSQLite::SQLite(),
    path_to_vegvault
  )


data_rockies %>%
  dplyr::left_join(
    dplyr::tbl(con, "DatasetTypeID") %>%
      dplyr::collect(),
    by = "dataset_type_id"
  )
