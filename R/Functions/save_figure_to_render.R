save_figure_to_render <- function(
    sel_plot,
    image_width = 1050, # [config]
    image_height = 700, # [config]
    image_unit = "px" # [config]
    ) {
  file_name <-
    substitute(sel_plot) %>%
    deparse()

  ggplot2::ggsave(
    here::here(
      "Materials/VegVault/Data_overview/",
      paste0(
        file_name,
        ".png"
      )
    ),
    plot = sel_plot,
    width = image_width,
    height = image_height,
    units = image_units,
    bg = colors$beigeLight # [config]
  )

  include_graphics_absolute_path(
    here::here(
      "Materials/VegVault/Data_overview/",
      paste0(
        file_name,
        ".png"
      )
    )
  )
}
