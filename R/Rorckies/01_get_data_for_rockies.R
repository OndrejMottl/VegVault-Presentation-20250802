#----------------------------------------------------------#
#
#
#           VegVault - Presentation- 20250802
#
#                Get data for the Rockies
#
#
#                       O. Mottl
#                         2025
#
#----------------------------------------------------------#

#----------------------------------------------------------#
# 0. Setup -----
#----------------------------------------------------------#

library(tidyverse)
library(jsonlite)

# install.packages("pak")
# pak::pak("OndrejMottl/vaultkeepr")
library(vaultkeepr)

# Colors

colors <-
  jsonlite::fromJSON(
    here::here("colors.json")
  )

rerun <- FALSE

#----------------------------------------------------------#
# 1. Get path to VegVault -----
#----------------------------------------------------------#

# !!!  IMPORTANT  !!!

# This solution was created due to VegVault data being a large file

# Please download the data from the VegVault repository and place the path to it
#  in the '.secrets/path.yaml' file.

if (
  file.exists(
    here::here(".secrets/path.yaml")
  )
) {
  path_to_vegvault <-
    yaml::read_yaml(
      here::here(".secrets/path.yaml")
    ) %>%
    purrr::chuck(Sys.info()["user"])
} else {
  stop(
    paste(
      "The path to the VegVault data is not specified.",
      " Please, create a 'path.yaml' file."
    )
  )
}

is_rockies_data_present <-
  file.exists(
    here::here("Data", "data_rockies.rds")
  )

if (
  isTRUE(is_rockies_data_present)
) {
  data_rockies <-
    readr::read_rds(
      here::here("Data", "data_rockies.rds")
    )
} else {
  data_rockies <-
    vaultkeepr::open_vault(
      path = path_to_vegvault
    ) %>%
    vaultkeepr::get_datasets() %>%
    vaultkeepr::select_dataset_by_geo(
      lat_lim = c(30, 50),
      long_lim = c(-120, -100),
      sel_dataset_type = c(
        "vegetation_plot",
        "fossil_pollen_archive",
        "gridpoints",
        "traits"
      )
    ) %>%
    vaultkeepr::get_samples() %>%
    vaultkeepr::select_samples_by_age(
      age_lim = c(0, 20000), # 20,000 BP
      verbose = FALSE
    ) %>%
    vaultkeepr::get_taxa() %>%
    vaultkeepr::get_abiotic_data(verbose = FALSE) %>%
    vaultkeepr::select_abiotic_var_by_name(sel_var_name = "bio1") %>%
    vaultkeepr::get_traits(
      verbose = FALSE
    ) %>%
    vaultkeepr::select_traits_by_domain_name(
      sel_domain = "Plant heigh"
    ) %>%
    vaultkeepr::extract_data(
      return_raw_data = TRUE,
      verbose = FALSE
    )


  if (
    isTRUE(rerun)
  ) {
    readr::write_rds(
      data_rockies,
      here::here("Data", "data_rockies.rds"),
      compress = "gz"
    )
  }
}
