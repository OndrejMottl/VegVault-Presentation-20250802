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
    "here",
    "janitor",
    "jsonlite",
    "knitr",
    "languageserver",
    "renv",
    "pak",
    "rlang",
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
# 3. Graphical options -----
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
image_width <- 2450
image_height <- 1200
image_units <- "px"

# define common color
colors <-
  jsonlite::fromJSON(
    here::here("colors.json")
  )

col_brown_light <- colors$brownLight
col_brown_dark <- colors$brownDark

col_green_light <- colors$greenLight
col_green_dark <- colors$greenDark

col_blue_light <- colors$blueLight
col_blue_dark <- colors$blueDark

col_beige_light <- colors$beigeLight
col_beige_dark <- colors$beigeDark

col_white <- colors$white
col_grey <- colors$grey

# set ggplot output
ggplot2::theme_set(
  ggplot2::theme_minimal() +
    ggplot2::theme(
      text = ggplot2::element_text(
        size = text_size,
        colour = col_blue_dark,
        family = "Renogare"
      ),
      line = ggplot2::element_line(
        linewidth = line_size,
        colour = col_blue_dark
      ),
      axis.text = ggplot2::element_text(
        colour = col_blue_dark,
        size = text_size,
        family = "Renogare"
      ),
      axis.title = ggplot2::element_text(
        colour = col_blue_dark,
        size = text_size,
        family = "Renogare"
      ),
      panel.grid.major = ggplot2::element_line(
        colour = col_beige_light,
        linewidth = line_size
      ),
      panel.grid.minor = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(
        fill = col_beige_light,
        colour = col_beige_light
      ),
      panel.background = ggplot2::element_rect(
        fill = col_brown_light,
        colour = col_brown_light
      ),
    )
)
