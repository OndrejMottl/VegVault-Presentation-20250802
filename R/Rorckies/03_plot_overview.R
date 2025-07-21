
coord_buffer <- 10

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


# vegetation plots
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

# age
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
    breaks = c(1, 10, 100, 1000, 10000, 100000),
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
  geom_histogram() +
  ggplot2::labs(
    x = "Age (cal yr BP)",
    y = "Number of samples"
  )

# temperature
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
    size = 1
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

data_rockies %>%
  dplyr::distinct(age)

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
    name = "Altitude (m)"
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
    )
  ) + 
  ggplot2::labs(
    x = "Longitude",
    y = "Latitude"
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
