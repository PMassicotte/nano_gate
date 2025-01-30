download_to_df <- function(date, longitude, latitude, temporal_res = c(
                             "8Day",
                             "Daily",
                             "Monthly"
                           )) {
  url <- "https://coastwatch.pfeg.noaa.gov/erddap/"
  dataset <- paste0("pmlEsaCCI60OceanColor", temporal_res)
  data_info <- rerddap::info(dataset, url = url)
  parameter <- "chlor_a"

  xlen <- 0.2
  ylen <- 0.2
  extracted_chlor_a <- rxtracto(
    data_info,
    parameter = parameter,
    xcoord = longitude,
    ycoord = latitude,
    tcoord = date,
    xlen = xlen,
    ylen = ylen,
    progress_bar = TRUE
  )

  extracted_chlor_a_df <- extracted_chlor_a |>
    as_tibble() |>
    clean_names() |>
    mutate(across(everything(), ~ replace(., is.nan(.), NA))) |>
    mutate(
      date = date,
      longitude = longitude,
      latitude = latitude,
      .before = 1L
    )


  extracted_chlor_a_df
}
