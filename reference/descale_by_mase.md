# Back-transform a MASE-scaled column

`descale_by_mase()` back-transforms a group time series that has been
scaled by a factor derived from the MASE error function.

## Usage

``` r
descale_by_mase(.tbl, .value, scale_factors, ...)
```

## Arguments

- .tbl:

  tibble; data with a value (class: numeric) column and group (class:
  character) column(s)

- .value:

  numeric; unquoted name of the column that contains the scaled numeric
  values

- scale_factors:

  tibble; tibble extracted from the `scale_factors` attribute of the
  output of
  [`scale_by_mase()`](https://ercbk.github.io/ebtools/reference/scale_by_mase.md).
  Grouping columns should match those in `.tbl`. (See details)

- ...:

  character; one or more unquoted grouping columns

## Value

The original tibble with the `.value` column back-transformed to the
orginal scale.

## Details

Scaling a grouped time series can be helpful for global forecasting
methods when using machine learning and deep learning algorithms.
Scaling by MASE and using MASE as the error function is equivalent to to
minimizing the MAE in the preprocessed time series.

The `scale_factors` tibble can be extracted by
`scale_factors <- attributes(mase_scaled_tbl)$scale_factors` where
`mase_scaled_tbl` is the output of
[`scale_by_mase()`](https://ercbk.github.io/ebtools/reference/scale_by_mase.md).

## References

Pablo Montero-Manso, Rob J. Hyndman, Principles and algorithms for
forecasting groups of time series: Locality and globality, International
Journal of Forecasting, 2021
[link](https://robjhyndman.com/publications/global-forecasting/)

## Examples

``` r
library(dplyr, warn.conflicts = FALSE)

group_ts_tbl <- tsbox::ts_tbl(fpp2::arrivals)

head(group_ts_tbl)
#> # A tibble: 6 × 3
#>   id    time       value
#>   <chr> <date>     <dbl>
#> 1 Japan 1981-01-01 14.8 
#> 2 Japan 1981-04-01  9.32
#> 3 Japan 1981-07-01 10.2 
#> 4 Japan 1981-10-01 19.5 
#> 5 Japan 1982-01-01 17.1 
#> 6 Japan 1982-04-01 10.6 

new_tbl <- scale_by_mase(.tbl = group_ts_tbl, .value = value, id)

glimpse(new_tbl)
#> Rows: 508
#> Columns: 3
#> $ id    <chr> "Japan", "Japan", "Japan", "Japan", "Japan", "Japan", "Japan", "…
#> $ time  <date> 1981-01-01, 1981-04-01, 1981-07-01, 1981-10-01, 1982-01-01, 198…
#> $ value <dbl> 0.7221063, 0.4559204, 0.4972521, 0.9542486, 0.8372481, 0.5193120…

scale_factors <- attributes(new_tbl)$scale_factors

orig_tbl <- descale_by_mase(new_tbl, value, scale_factors, id)

head(orig_tbl)
#> # A tibble: 6 × 3
#>   id    time       value
#>   <chr> <date>     <dbl>
#> 1 Japan 1981-01-01 14.8 
#> 2 Japan 1981-04-01  9.32
#> 3 Japan 1981-07-01 10.2 
#> 4 Japan 1981-10-01 19.5 
#> 5 Japan 1982-01-01 17.1 
#> 6 Japan 1982-04-01 10.6 
```
