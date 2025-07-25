#----------------------------------------------------------#
#
#
#           VegVault - Presentation- 20250802
#
#                   Configuration script
#
#
#                       O. Mottl
#                         2025
#
#----------------------------------------------------------#

# Configuration script with the variables that should be consistent throughout
#   the whole repo. It loads packages, defines important variables,
#   authorises the user, and saves config file.

# Set the current environment
current_env <- environment()


#----------------------------------------------------------#
# 1. Load packages -----
#----------------------------------------------------------#

library(
  "here",
  quietly = TRUE,
  warn.conflicts = FALSE,
  character.only = TRUE,
  verbose = FALSE
)

if (
  isFALSE(
    exists("already_synch", envir = current_env)
  )
) {
  already_synch <- FALSE
}

if (
  isFALSE(already_synch)
) {
  library(here)
  # Synchronise the package versions
  renv::restore(
    lockfile = here::here("renv.lock")
  )
  already_synch <- TRUE

  # Save snapshot of package versions
  # renv::snapshot(lockfile =  here::here("renv.lock"))  # do only for update
}

# Define packages
package_list <-
  c(
    "assertthat",
    "geodata",
    "ggnewscale",
    "here",
    "janitor",
    "jsonlite",
    "knitr",
    "languageserver",
    "renv",
    "pak",
    "rlang",
    "terra",
    "tidyverse",
    "usethis",
    "utils",
    "vaultkeepr"
  )

# Attach all packages
sapply(
  package_list,
  function(x) {
    library(x,
      quietly = TRUE,
      warn.conflicts = FALSE,
      character.only = TRUE,
      verbose = FALSE
    )
  }
)


#----------------------------------------------------------#
# 2. Load functions -----
#----------------------------------------------------------#

# get vector of general functions
fun_list <-
  list.files(
    path = here::here("R/Functions/"),
    pattern = "*.R",
    recursive = TRUE
  )

# source them
if (
  length(fun_list) > 0
) {
  sapply(
    paste0(here::here("R/Functions"), "/", fun_list, sep = ""),
    source
  )
}


#----------------------------------------------------------#
# 3. Get path to VegVault -----
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


#----------------------------------------------------------#
# 4. Graphical options -----
#----------------------------------------------------------#

# define font
sysfonts::font_add(
  family = "Renogare",
  regular = here::here("Fonts/Renogare-Regular.otf")
)
showtext::showtext_auto()

# define general
text_size <- 12
line_size <- 0.1
point_size <- 3

# define output sizes
image_width <- 1050
image_height <- 700
image_units <- "px"

# define common color
colors <-
  jsonlite::fromJSON(
    here::here("colors.json")
  )

# set ggplot output
ggplot2::theme_set(
  ggplot2::theme_minimal() +
    ggplot2::theme(
      text = ggplot2::element_text(
        size = text_size,
        colour = colors$black,
        family = "Renogare"
      ),
      line = ggplot2::element_line(
        linewidth = line_size,
        colour = colors$black
      ),
      axis.text = ggplot2::element_text(
        colour = colors$black,
        size = text_size,
        family = "Renogare"
      ),
      axis.title = ggplot2::element_text(
        colour = colors$black,
        size = text_size,
        family = "Renogare"
      ),
      panel.grid.major = ggplot2::element_line(
        colour = colors$beigeLight,
        linewidth = line_size
      ),
      panel.grid.minor = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(
        fill = colors$beigeLight,
        colour = colors$beigeLight
      ),
      panel.background = ggplot2::element_rect(
        fill = colors$brownLight,
        colour = colors$brownLight
      ),
      plot.margin = ggplot2::margin(
        t = 0,
        r = 1,
        b = 1,
        l = 0,
        unit = "cm"
      )
    )
)
