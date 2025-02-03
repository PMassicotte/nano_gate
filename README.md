# Nano Gate

![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)

This project is an R-based data processing pipeline designed for:

1. Downloading and processing chlorophyll-a data from NOAA's ERDDAP service.
2. Extracting sea ice concentration data (based on AMRS2) from the AWI's FTP server.

## Features

- Automated data download and processing
- Integration with NOAA's ERDDAP service for chlorophyll-a data
- Extraction of sea ice concentration data from AWI's FTP server

## Data Sources

### Chlorophyll-a (Chla)

- [Ocean Colour CCI](https://www.oceancolour.org/thredds/catalog-cci.html)
- [R Code Example](https://github.com/shospital/r_code/blob/1693cb8a3fb58d9f145175014ddc57d4c27222b2/matchup_satellite_track_data.md?plain=1#L287)
- [NOAA ERDDAP Search](https://coastwatch.pfeg.noaa.gov/erddap/search/index.html?page=1&itemsPerPage=1000&searchFor=cci)

### Sea Ice Concentration

- [AWI FTP Server](ftp://anonymous@ftp.awi.de/sea_ice/product/amsr2/v110)

## Usage

```bash
# Clone the repository
git clone git@github.com:PMassicotte/nano_gate.git

# Navigate to the project directory
cd nano_gate

# Install dependencies using renv
R -e 'renv::restore()'
```

## Usage

You can run the analysis by running the following command:

```bash
R -e 'targets::tar_make()'
```

## References

- [Parallel Targets Workshop](https://carpentries-incubator.github.io/targets-workshop/parallel.html)

These improvements cover additional sections such as features, prerequisites, installation, usage example, contributing, license, acknowledgments, and references. You can copy and paste this updated README into your repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

## Acknowledgments

- [NOAA ERDDAP](https://coastwatch.pfeg.noaa.gov/erddap/index.html)
- [AWI](https://www.awi.de/)

## Code of Conduct

Please note that the nano_gate project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
