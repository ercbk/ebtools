# Pooled Temporal Variogram

Computes a pooled temporal variogram by holding space fixed and pooling
squared temporal differences across spatial locations. Each row of `Y`
is a spatial location and each column is a time point.

## Usage

``` r
pooled_temporal_variogram(
  Y,
  max_lag = NULL,
  max_time_diff = NULL,
  bin_width = 7,
  lag_unit = NULL,
  datetime = FALSE
)
```

## Arguments

- Y:

  A numeric space-time matrix. Rows are locations and columns are time
  points The column names must either be character strings of dates
  (YYYY-MM-DD) or datetimes (YYYY-MM-DD hh-mm-ss)

- max_lag:

  Maximum index-based lag (regular time grid case).

- max_time_diff:

  Maximum time difference (irregular time grid case).

- bin_width:

  Width of temporal bins expressed in the same time units as lag_unit.

- lag_unit:

  is "secs", "mins", "hours", "days", or "weeks". If the time points are
  dates, then the default is "days". If the time points are datetimes
  (w/datetime = TRUE), then the default is "secs".

- datetime:

  is TRUE or FALSE (Default), It indicates whether the column names are
  dates (default) or datetimes.

## Value

An object of class `gstatVariogram` and `data.frame` that's compatible
with `gstat::fit.variogram()`. The dataframe contains the following
variables:

- np:

  The number of valid (not NA) time difference pairs in that temporal
  bin.

- dist:

  The center value of all time difference pairs represented in that
  temporal bin.

- gamma:

  The semivariance value associated with that temporal bin.

- dir.hor, dir.ver, and id:

  Given constant values, because they aren't used in this context.

## Details

The purpose of this function is to obtain starting values for the time
portion of a few of the spatio-temporal variogram models. It's inspired
by the pooled spatial variogram specification used in section 2.2 of the
'gstat' vignette, [Introduction to Spatio-Temporal
Variography](https://cran.r-project.org/web/packages/gstat/vignettes/st.pdf).
Unfortunately, there doesn't seem to be a way to use
`gstat::variogram()` to fit a pooled temporal version of the variogram
in that section.

See [Geospatial, Spatio-Temporal \>\> Grid
Layouts](https://ercbk.github.io/Data-Science-Notebook/qmd/geospatial-spat-temp.html#sec-geo-sptemp-grlay)
in my notebook for details on regular (full) grids and irregular grids.

See Example 2 in my notebook for a more in-depth example of using this
function ([Geospatial, Spatio-Temporal \>\> EDA \>\> Temporal
Dependence](https://ercbk.github.io/Data-Science-Notebook/qmd/geospatial-spat-temp.html#sec-geo-sptemp-eda-ac)
\>\> Example 2).

Let: \\Y\_{s,t}\\ denote the observation at location \\s = 1,\dots,S\\
and time \\t = 1,\dots,T\\.

The pooled estimator is:

\$\$ \hat{\gamma}(h_t) = \frac{1}{2 N_k(h_t)} \sum\_{k=1}^{K}
\sum\_{s=1}^{S} \left( Y\_{s,t} - Y\_{s,t+u} \right)^2 \$\$

where:

- \\h_t\\ is a temporal bin

- \\N_k(h_t)\\ is the number of valid (not NA) time difference pairs in
  that temporal bin

- \\K\\ is the number of time difference pairs

- \\S\\ is number of spatial locations

- \\u\\ is temporal separation

## Examples

``` r
Y <- matrix(
  c(
    10, 11, 15, 14, 13,   # location 1
    8,  9, 12, 11, 10,    # location 2
    5,  6,  8,  7,  9     # location 3
  ),
  nrow = 3,
  byrow = TRUE
)

rownames(Y) <- c("loc1", "loc2", "loc3")

# dates as column names
colnames(Y) <- as.character(seq.Date(
  as.Date("2023-01-01"),
  as.Date("2023-05-01"),
  by = "month"
))

Y
#>      2023-01-01 2023-02-01 2023-03-01 2023-04-01 2023-05-01
#> loc1         10         11         15         14         13
#> loc2          8          9         12         11         10
#> loc3          5          6          8          7          9

pooled_temporal_variogram(
  Y = Y,
  max_time_diff = 100, # days
  bin_width = 30,      # days
)
#>   np dist    gamma dir.hor dir.ver   id
#> 1  3   15 4.833333       0       0 var1
#> 2 15   45 2.533333       0       0 var1
#> 3  6   75 1.916667       0       0 var1
#> 4  3  105 4.833333       0       0 var1



# datetimes as column names
colnames(Y) <- as.character(seq(
  as.POSIXct("2023-01-15 12:00:00"),
  by = "30 min",
  length.out = 5
))

pooled_temporal_variogram(
  Y = Y,
  max_time_diff = 500,  # minutes
  bin_width = 60,       # minutes
  lag_unit = "mins",
  datetime = TRUE
)
#>   np dist    gamma dir.hor dir.ver   id
#> 1 12   30 1.708333       0       0 var1
#> 2 15   90 3.866667       0       0 var1
#> 3  3  150 4.833333       0       0 var1
```
