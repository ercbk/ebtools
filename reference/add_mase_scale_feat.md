# Add a scale feature by using a factor derived from the MASE error function

`add_mase_scale_feat()` calculates a MASE scale factor and divides this
factor by the group average scale factor to produce a scale feature.

## Usage

``` r
add_mase_scale_feat(.tbl, .value, ...)
```

## Arguments

- .tbl:

  tibble; data with grouping column and value column

- .value:

  numeric; unquoted name of the column that contains the numeric values
  of the time series

- ...:

  character; one or more unquoted grouping columns

## Value

The original tibble with an additional column, "scale."

## Details

Designed to use with a global forecasting method. It's recommended to
standardize the stacked series that is used as input for this method.
Standardizing the stacked series removes the scale information about
each series in the stack which might be useful in generating the
forecast. Adding a scale feature reintroduces this information back into
the model.

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

new_tbl <- add_mase_scale_feat(group_ts_tbl, .value = value, id)

head(new_tbl)
#> # A tibble: 6 × 4
#>   id    time       value scale
#>   <chr> <date>     <dbl> <dbl>
#> 1 Japan 1981-01-01 14.8  0.812
#> 2 Japan 1981-04-01  9.32 0.812
#> 3 Japan 1981-07-01 10.2  0.812
#> 4 Japan 1981-10-01 19.5  0.812
#> 5 Japan 1982-01-01 17.1  0.812
#> 6 Japan 1982-04-01 10.6  0.812
```
