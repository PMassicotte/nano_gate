library(targets)
library(tarchetypes) # Load other packages as needed.
library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(sf)
library(rnaturalearth)

# Set default ggplot2 font size and font family
theme_set(theme_minimal())
theme_update(
  panel.border = element_blank(),
  axis.ticks = element_blank(),
  strip.background = element_blank(),
  strip.text = element_text(size = 12L, face = "bold"),
  plot.title = element_text(size = 14L)
)

# Source additional R scripts
tar_source()

tar_option_set(format = tar_format_nanoparquet())

tar_source()

list(
  tar_files_input(station_files, dir_ls(path(".", "data", "raw", "stations"))),
  tar_target(
    name = stations,
    command = import_geo_position(station_files),
    pattern = map(station_files)
  ),
  tar_target(stations_plot, plot_stations(stations), format = "rds"),
  tar_target(
    stations_plot_pdf,
    {
      filename <- fs::path("graphs", "stations.pdf")

      ggsave(
        filename = filename,
        plot = stations_plot,
        device = cairo_pdf,
        width = 6L,
        height = 6L
      )

      knitr::plot_crop(filename)
    },
    format = "file"
  )
)
