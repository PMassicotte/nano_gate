#' Import geographic positions from an Excel file
#'
#' @param file Path to the Excel file containing geographic positions
#' @return A data frame with columns: date, latitude, longitude
#' @export
import_geo_position <- function(file) {
  positions <- read_excel(
    file,
    col_names = c("date", "latitude", "longitude"),
    skip = 1L
  ) |>
    mutate(date = as.Date(date))


  positions
}

#' Plot stations on a world map
#'
#' @param stations A data frame with columns: date, latitude, longitude
#' @return A ggplot object displaying stations on a world map
#' @export
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
