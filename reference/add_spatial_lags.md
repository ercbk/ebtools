# Add Spatial Lags of a Variable to a Dataset

Computes spatial lags for a given numeric variable in a dataset using a
neighborhood list from the [spdep](https://r-spatial.github.io/spdep/)
package. It supports inverse distance weighting, exponential, and double
power decay weighting methods along with various normalization
procedures.

## Usage

``` r
add_spatial_lags(nblist, y, .data, lags, type = NULL, parallel = FALSE, ...)
```

## Arguments

- nblist:

  An object of class "nb" from the spdep package which represents the
  neighborhood structure.

- y:

  A character string indicating the name of the numeric variable in
  `.data` for which spatial lags will be computed.

- .data:

  A data frame of class "sf" containing the variable specified by `y`.

- lags:

  A numeric value specifying the number of spatial lags to compute.

- type:

  A character string indicating the type of spatial weights to use.
  Accepted values are `"idw"` (inverse distance weighting), `"exp"`
  (exponential), `"dpd"` (double power decay), or `NULL` (default),
  which applies standard adjacency-based weighting.

- parallel:

  (default: FALSE) Logical indicating whether to use parallel
  processing. Requires having purrr (\>= 1.0.4.9000) installed, [mirai
  (\>= 2.1.0.9000)](https://shikokuchuo.net/mirai/) package installed
  and loaded, and setting
  [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html)
  to the number of desired processes. (See Examples)

- ...:

  Additional arguments passed to
  [`spdep::nb2listw()`](https://r-spatial.github.io/spdep/reference/nb2listw.html)
  or
  [`spdep::nb2listwdist()`](https://r-spatial.github.io/spdep/reference/nb2listwdist.html),
  such as the `style` argument specifying the normalization method or
  `zero-policy` which indicates whether or not to permit the weights
  list to be formed with zero-length weights vectors.

## Value

A tibble containing the original dataset with additional columns for
each computed spatial lag. The spatial lag columns are named
`"spatlag_<lag>_<y>"`. The output also includes weight summary
attributes named `"summ_wgts_spatlag_<lag>"`.

## Details

To obtain a neighborhood list of class "nb," first, a neighborhood
algorithm is fit to the geometry of sf dataset. Then, that object is
coerced into a neighborhood list. For a workflow, see the Misc section
in the [Geospatial, Spatial
Weights](https://ercbk.github.io/Data-Science-Notebook/qmd/geospatial-spatial-weights.html#sec-geo-swgt-misc)
note of my Data Science notebook.

- Valid Types: (`"idw"`, `"exp"`, `"dpd"`).

- Valid Styles: (`"W"`, `"B"`, `"C"`, `"S"`, `"U"`, `"minmax"`,
  `"raw"`).

- See the Spatial Weights section in the [Geospatial, Spatial
  Weights](https://ercbk.github.io/Data-Science-Notebook/qmd/geospatial-spatial-weights.html#sec-geo-swgt-swts)
  note of my Data Science notebook for details

The spatial weights summary is extracted from the output of printing the
[`spdep::nb2listw`](https://r-spatial.github.io/spdep/reference/nb2listw.html)
or
[`spdep::nb2listwdist`](https://r-spatial.github.io/spdep/reference/nb2listwdist.html)
object. It contains characteristics such as the number of regions,
number of nonzero links, percentage of nonzero weights, average number
of links.

- n: This refers to the number of regions (or spatial units) in your
  dataset.

- nn: This refers to the total number of possible pairwise relationships
  between the regions. It is calculated as n × n. This represents the
  total number of possible links if every region were connected to every
  other region, including itself.

- S0: This is the sum of all weights.

- S1: This is related to the sum of the squares of the weights.

- S2: This is related to the sum of the products of the weights for each
  pair of neighbors.

- S0, S1, S2 are constants used in inference for global spatial
  autocorrelation statistics

## Examples

``` r
library(spdep, quietly = TRUE)
#> To access larger datasets in this package, install the spDataLarge
#> package with: `install.packages('spDataLarge',
#> repos='https://nowosad.github.io/drat/', type='source')`
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE

ny8_sf <-
  st_read(system.file(
    "shapes/NY8_bna_utm18.gpkg",
    package = "spData"),
    quiet = TRUE)

dplyr::glimpse(ny8_sf)
#> Rows: 281
#> Columns: 13
#> $ AREAKEY    <chr> "36007000100", "36007000200", "36007000300", "36007000400",…
#> $ AREANAME   <chr> "Binghamton city", "Binghamton city", "Binghamton city", "B…
#> $ X          <dbl> 4.069397, 4.639371, 5.709063, 7.613831, 7.315968, 8.558753,…
#> $ Y          <dbl> -67.3533, -66.8619, -66.9775, -65.9958, -67.3183, -66.9344,…
#> $ POP8       <dbl> 3540, 3560, 3739, 2784, 2571, 2729, 3952, 993, 1908, 948, 1…
#> $ TRACTCAS   <dbl> 3.08, 4.08, 1.09, 1.07, 3.06, 1.06, 2.09, 0.02, 2.04, 0.02,…
#> $ PROPCAS    <dbl> 0.000870, 0.001146, 0.000292, 0.000384, 0.001190, 0.000388,…
#> $ PCTOWNHOME <dbl> 0.32773109, 0.42682927, 0.33773959, 0.46160483, 0.19243697,…
#> $ PCTAGE65P  <dbl> 0.14661017, 0.23511236, 0.13800481, 0.11889368, 0.14157915,…
#> $ Z          <dbl> 0.14197, 0.35555, -0.58165, -0.29634, 0.45689, -0.28123, -0…
#> $ AVGIDIST   <dbl> 0.2373852, 0.2087413, 0.1708548, 0.1406045, 0.1577753, 0.17…
#> $ PEXPOSURE  <dbl> 3.167099, 3.038511, 2.838229, 2.643366, 2.758587, 2.848411,…
#> $ geom       <MULTIPOLYGON [m]> MULTIPOLYGON (((421808.5 46..., MULTIPOLYGON (…

ny8_ct_sf <-
  st_centroid(st_geometry(ny8_sf),
              of_largest_polygon = TRUE)


ny88_nb_sf <-
  knn2nb(knearneigh(ny8_ct_sf,
                    k = 4))

# Compute spatial lags
tib_spat_lags <-
  add_spatial_lags(
    nblist = ny88_nb_sf,
    y = "PCTOWNHOME",
    .data = ny8_sf,
    lags = 2,
    type = "dpd",
    dmax = 25000,
    style = "W",
    zero.policy = TRUE
  )

tib_spat_lags |>
  dplyr::select(PCTOWNHOME,
                spatlag_1_PCTOWNHOME,
                spatlag_2_PCTOWNHOME) |>
  dplyr::glimpse()
#> Rows: 281
#> Columns: 3
#> $ PCTOWNHOME           <dbl> 0.32773109, 0.42682927, 0.33773959, 0.46160483, 0…
#> $ spatlag_1_PCTOWNHOME <dbl> 0.3950168, 0.3680243, 0.3577721, 0.3964721, 0.259…
#> $ spatlag_2_PCTOWNHOME <dbl> 0.3837656, 0.3191021, 0.3381668, 0.2854097, 0.389…

cat(attributes(tib_spat_lags)$summ_wgts_spatlag_1, sep = "\n")
#> Characteristics of weights list object:
#> Neighbour list object:
#> Number of regions: 281 
#> Number of nonzero links: 1124 
#> Percentage nonzero weights: 1.423488 
#> Average number of links: 4 
#> Non-symmetric neighbours list
#> 
#> Weights style: W 
#> Weights constants summary:
#>     n    nn  S0     S1       S2
#> W 281 78961 281 117.94 1171.045


library(mirai)

daemons(2)

tib_spat_lags_para <-
  add_spatial_lags(
    nblist = ny88_nb_sf,
    y = "PCTOWNHOME",
    .data = ny8_sf,
    lags = 2,
    type = "exp",
    zero.policy = TRUE,
    parallel = TRUE
  )
#> ■■■■■■■■■■■■■■■■                  50% | ETA:  7s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s

daemons(0)
```
