import_geo_position <- function(file) {
  positions <- read_excel(
    file,
    col_names = c("date", "latitude", "longitude"),
    skip = 1L
  ) |>
    mutate(date = as.Date(date))


  positions
}

plot_stations <- function(stations) {
  wm <- ne_download()

  stations_sf <- stations |>
    st_as_sf(coords = c("longitude", "latitude"), crs = "EPSG:4326")

  p <- ggplot() +
    geom_sf(data = wm, linewidth = 0.1) +
    geom_sf(data = stations_sf, size = 0.5, color = "red") +
    coord_sf(crs = "+proj=robin")


  p
}
