#' Build Sea Ice Concentration Raster URLs
#'
#' This function generates URLs for downloading sea ice concentration raster
#' data for the given stations.
#'
#' @param stations A data frame containing station information.
#' @return A character vector of URLs for downloading sea ice concentration
#' raster data.
#' @export
build_sic_raster_urls <- function(stations) {
  df <- stations |>
    mutate(hemisphere = if_else(latitude < 0L, "sh", "nh")) |>
    group_nest(hemisphere) |>
    crossing(
      sic_date = seq(
        as.Date("2024-01-01"),
        as.Date("2024-12-31"),
        by = "1 day"
      )
    ) |>
    mutate(
      sic_url = glue(
        paste0(
          "/vsicurl/ftp://ftp.awi.de/sea_ice/product/amsr2/v110/{hemisphere}/",
          "{year}/{mm}/{hemisphere}_SIC-LEADS_{yyyymmdd}00_{mmdd}12.tiff" # nolint
        ),
        year = format(sic_date, "%Y"),
        yyyymmdd = format(sic_date, "%Y%m%d"),
        mm = format(sic_date, "%m"),
        mmdd = format(sic_date, "%m%d")
      )
    ) |>
    unnest(data) |>
    relocate(hemisphere, .before = latitude)

  df
}

#' Extract Sea Ice Concentration
#'
#' This function extracts sea ice concentration data from a raster file
#' and associates it with the given data frame of geographical points.
#'
#' @param df A data frame containing columns: longitude, latitude, and sic_url.
#' @return A tibble with sea ice concentration data and the original data frame
#' columns.
#' @export
extract_sic <- function(df) {
  pts <- df |>
    vect(
      geom = c("longitude", "latitude"),
      crs = "EPSG:4326",
      keepgeom = TRUE
    )

  r <- rast(unique(df[["sic_url"]]))

  r[r > 100L] <- NA
  r <- r / 100L

  pts <- pts |>
    project(r)

  sic <- terra::extract(r, pts, bind = TRUE) |>
    as_tibble() |>
    rename("sea_ice_concentraton" = 8L) |>
    select(-sic_url, -tar_group)


  sic
}


#' Calculate the number of open water days (OWD)
#'
#' This function calculates the number of open water days based on sea ice
#' concentration (SIC) data.
#'
#' @param sic A data frame containing sea ice concentration data.
#' @param threshold A numeric value between 0 and 1 representing the SIC
#' threshold.
#' @return A data frame summarizing the number of open water days by
#' hemisphere, longitude, and latitude.
calculate_owd <- function(sic, threshold) {
  tar_assert_true(
    threshold >= 0L && threshold <= 1L,
    "SIC threshold must be between 0 and 1"
  )

  sic_clean <- sic |>
    drop_na(sea_ice_concentraton) |>
    filter(sic_date <= date)

  owd <- sic_clean |>
    summarize(
      number_open_water_day = sum(sea_ice_concentraton <= threshold),
      .by = c(date, hemisphere, longitude, latitude)
    )

  owd
}

#' Plot Open Water Day (OWD)
#'
#' This function creates a plot of the number of open water days prior to the
#' sampling date.
#'
#' @param owd A data frame containing the number of open water days with
#' longitude and latitude coordinates.
#' @return A ggplot object representing the open water days on a map.
plot_open_water_day <- function(owd) {
  wm <- ne_download()

  owd |>
    st_as_sf(coords = c("longitude", "latitude"), crs = "EPSG:4326") |>
    ggplot() +
    geom_sf(data = wm, linewidth = 0.1) +
    geom_sf(aes(size = number_open_water_day), color = "red") +
    scale_size_continuous(range = c(0.5, 2L)) +
    labs(
      size = str_wrap(
        "Number of open water day prior to the sampling date",
        20L
      )
    ) +
    coord_sf(crs = "+proj=robin")
}
