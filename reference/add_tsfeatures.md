# Add time series features calculated by the tsfeatures package

`add_tsfeatures()` adds a set of calculated features from the
[tsfeatures](https://pkg.robjhyndman.com/tsfeatures/) package for each
time series in the group. These features provide information about
various characteristics of the time series.

## Usage

``` r
add_tsfeatures(.tbl, ..., standardize = TRUE, parallel = FALSE)
```

## Arguments

- .tbl:

  tibble; data with date (class: Date), value (class: numeric), and
  group (class: character) columns

- ...:

  character; one or more unquoted grouping columns

- standardize:

  logical; If TRUE (default), the function with standardize each
  feature.

- parallel:

  logical; If TRUE, features will be calculated in parallel. Default is
  FALSE.

## Value

The original tibble with 20 additional feature columns.

## Details

Function can be used with a global forecasting method or for EDA. See
the [tsfeatures](https://pkg.robjhyndman.com/tsfeatures/) website for
more details on these features.

## References

Pablo Montero-Manso, Rob J. Hyndman, Principles and algorithms for
forecasting groups of time series: Locality and globality, International
Journal of Forecasting, 2021
[link](https://robjhyndman.com/publications/global-forecasting/)

## See also

[`tsfeatures::tsfeatures()`](http://pkg.robjhyndman.com/tsfeatures/reference/tsfeatures.md)

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

new_tbl <- add_tsfeatures(group_ts_tbl, id)

head(new_tbl)
#> # A tibble: 6 × 23
#>   id    time       value frequency nperiods seasonal_period trend  spike
#>   <chr> <date>     <dbl>     <dbl>    <dbl>           <dbl> <dbl>  <dbl>
#> 1 Japan 1981-01-01 14.8          4        1               4 0.327 0.0853
#> 2 Japan 1981-04-01  9.32         4        1               4 0.327 0.0853
#> 3 Japan 1981-07-01 10.2          4        1               4 0.327 0.0853
#> 4 Japan 1981-10-01 19.5          4        1               4 0.327 0.0853
#> 5 Japan 1982-01-01 17.1          4        1               4 0.327 0.0853
#> 6 Japan 1982-04-01 10.6          4        1               4 0.327 0.0853
#> # ℹ 15 more variables: linearity <dbl>, curvature <dbl>, e_acf1 <dbl>,
#> #   e_acf10 <dbl>, seasonal_strength <dbl>, peak <dbl>, trough <dbl>,
#> #   entropy <dbl>, x_acf1 <dbl>, x_acf10 <dbl>, diff1_acf1 <dbl>,
#> #   diff1_acf10 <dbl>, diff2_acf1 <dbl>, diff2_acf10 <dbl>, seas_acf1 <dbl>
```
