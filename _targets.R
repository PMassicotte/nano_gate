library(targets)
library(tarchetypes) # Load other packages as needed.
library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(sf)
library(rnaturalearth)
library(rerddap)
library(rerddapXtracto)
library(crew)
library(terra)
library(glue)
library(httpgd)

# Set default ggplot2 font size and font family
theme_set(theme_minimal())
theme_update(
  panel.border = element_blank(),
  axis.ticks = element_blank(),
  strip.background = element_blank(),
  strip.text = element_text(size = 12L, face = "bold"),
  plot.title = element_text(size = 14L)
)

tar_option_set(
  format = tar_format_nanoparquet(),
  controller = crew_controller_local(workers = 12L)
)

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
  ),
  tar_target(
    station_data,
    split(stations, seq_len(nrow(stations))),
    iteration = "list",
    format = "rds"
  ),
  tar_target(
    daily_chla,
    do.call(download_to_df, c(station_data, list(temporal_res = "Daily"))),
    pattern = map(station_data),
    deployment = "worker"
  ),
  tar_target(
    weekly_chla,
    do.call(download_to_df, c(station_data, list(temporal_res = "8Day"))),
    pattern = map(station_data),
    deployment = "worker"
  ),
  tar_target(
    monthly_chla,
    do.call(download_to_df, c(station_data, list(temporal_res = "Monthly"))),
    pattern = map(station_data),
    deployment = "worker"
  ),
  tar_file(
    daily_chla_file,
    write_csv_file(
      daily_chla,
      fs::path("data", "clean", "daily_chla.csv")
    )
  ),
  tar_file(
    weekly_chla_file,
    write_csv_file(
      weekly_chla,
      fs::path("data", "clean", "weekly_chla.csv")
    )
  ),
  tar_file(
    monthly_chla_file,
    write_csv_file(
      monthly_chla,
      fs::path("data", "clean", "monthly_chla.csv")
    )
  ),
  tar_target(sic_url, build_sic_raster_urls(stations)),
  tar_group_by(sic_group_url, sic_url, hemisphere, sic_date),
  tar_option_set(
    controller = crew_controller_local(workers = 24L)
  ),
  tar_target(
    sic,
    possibly(extract_sic, otherwise = tibble())(sic_group_url),
    pattern = map(sic_group_url),
    deployment = "worker",
    format = "rds"
  ),
  tar_file(
    sic_csv_file,
    write_csv_file(
      sic,
      fs::path("data", "clean", "sic.csv")
    )
  ),
  tar_target(owd, calculate_owd(sic, 0.15)),
  tar_file(
    sic_owd_csv_file,
    write_csv_file(
      owd,
      fs::path("data", "clean", "sic_owd.csv")
    )
  ),
  tar_target(sic_owd_plot, plot_open_water_day(owd), format = "rds"),
  tar_file(
    sic_owd_plot_file,
    {
      filename <- fs::path("graphs", "sic_owd_plot.pdf")

      ggsave(
        filename = filename,
        plot = sic_owd_plot,
        device = cairo_pdf,
        width = 6L,
        height = 6L
      )

      knitr::plot_crop(filename)
    }
  )
)
