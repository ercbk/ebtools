# Scale a group time series by using a factor derived from the MASE error function

`scale_by_mase()` scales a group time series by using a factor derived
from the MASE error function.

## Usage

``` r
scale_by_mase(.tbl, .value, ...)
```

## Arguments

- .tbl:

  tibble; data with a value (class: numeric) column and group (class:
  character) column(s)

- .value:

  numeric; unquoted name of the column that contains the numeric values

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

For each series, a MASE scale factor is calculated using the denominator
of the MASE scaled error equation. Then, the series is divided by this
factor.

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

head(new_tbl)
#> # A tibble: 6 × 3
#>   id    time       value
#>   <chr> <date>     <dbl>
#> 1 Japan 1981-01-01 0.722
#> 2 Japan 1981-04-01 0.456
#> 3 Japan 1981-07-01 0.497
#> 4 Japan 1981-10-01 0.954
#> 5 Japan 1982-01-01 0.837
#> 6 Japan 1982-04-01 0.519

attributes(new_tbl)$scale_factors
#> # A tibble: 4 × 2
#>   id    scale
#>   <chr> <dbl>
#> 1 Japan 20.4 
#> 2 NZ    33.0 
#> 3 UK    37.5 
#> 4 US     9.69
```
