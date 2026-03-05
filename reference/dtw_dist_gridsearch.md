# Perform a grid search of parameters and `dtwclust` distance functions

`dtw_dist_gridsearch()` performs a gridsearch using a list of parameter
grids and a list of distance functions from the dtwclust package.

## Usage

``` r
dtw_dist_gridsearch(
  query_tbl,
  ref_series,
  dtw_funs,
  dtw_grids,
  num_best = "all"
)
```

## Arguments

- query_tbl:

  Data.frame or tibble containing columns of numeric vectors for each
  query time series that are to be compared to the reference time
  series.

- ref_series:

  Numeric vector; the reference time series which is the series that all
  query series will compared to.

- dtw_funs:

  Named list of dtwclust distance functions. Names need to match those
  in dtw_grids

- dtw_grids:

  Object created by
  [`create_dtw_grids()`](https://ercbk.github.io/ebtools/reference/create_dtw_grids.md)
  or named nested list of parameter name-value pairs that correspond to
  the distance functions. Names need to match those in dtw_funs.

- num_best:

  Integer or "all"; if an integer, then that number of query series with
  the lowest distance values for each parameter configuration will be
  returned; if "all", then all results will be returned. Default is
  "all".

## Value

A tibble with columns for the names of the query series, names of the
distance functions, parameter values, and calculated distances.

## Details

The distance algorithms currently supported are:

- dynamic time warping (`dtw_basic`)

- dynamic time warping with an additional L2 Norm (`dtw2`)

- dynamic time warping with lower bound (`dtw_lb`)

- Triangular Global Alignment Kernel (`gak`)

- Slope Based Distance (`sbd`)

## See also

[`create_dtw_grids()`](https://ercbk.github.io/ebtools/reference/create_dtw_grids.md)
[`dtwclust::dtw_basic()`](https://rdrr.io/pkg/dtwclust/man/dtw_basic.html),
[`dtwclust::dtw2()`](https://rdrr.io/pkg/dtwclust/man/dtw2.html),
[`dtwclust::dtw_lb()`](https://rdrr.io/pkg/dtwclust/man/dtw_lb.html),
[`dtwclust::gak()`](https://rdrr.io/pkg/dtwclust/man/GAK.html),
[`dtwclust::sbd()`](https://rdrr.io/pkg/dtwclust/man/SBD.html)

## Examples

``` r
suppressPackageStartupMessages(library(dtwclust))

head(ohio_covid)[,1:6]
#> # A tibble: 6 × 6
#>   date       cases deaths_lead60 deaths_lead59 deaths_lead58 deaths_lead57
#>   <date>     <dbl>         <dbl>         <dbl>         <dbl>         <dbl>
#> 1 2020-03-22  44.9          43.1          42.6          40.6          42.9
#> 2 2020-03-23  56.3          41.6          43.1          42.6          40.6
#> 3 2020-03-24  71            49.4          41.6          43.1          42.6
#> 4 2020-03-25  88.1          49.1          49.4          41.6          43.1
#> 5 2020-03-26 107.           47.1          49.1          49.4          41.6
#> 6 2020-03-27 139.           40.3          47.1          49.1          49.4

ref_series <- ohio_covid[["cases"]]
query_tbl <- dplyr::select(ohio_covid, -cases, -date)


params_ls_lg <- list(dtw_basic = list(window.size = 5:10,
                                      norm = c("L1", "L2"),
                                      step.pattern = list(symmetric1, symmetric2)),
                     dtw2 = list(step.pattern = list(symmetric1, symmetric2),
                                 window.size = 5:10),
                     dtw_lb = list(window.size = 5:10,
                                   norm = c("L1", "L2"),
                                   dtw.func = "dtw_basic",
                                   step.pattern = list(symmetric2)),
                     sbd = list(znorm = TRUE, return.shifted = FALSE),
                     gak = list(normalize = TRUE, window.size = 5:10))

dtw_grids_lg <- create_dtw_grids(params_ls_lg)

dtw_funs_lg <- list(dtw_basic = dtw_basic,
                    dtw2 = dtw2,
                    dtw_lb = dtw_lb,
                    sbd = sbd,
                    gak = gak)

search_res_lg <- dtw_dist_gridsearch(query_tbl = query_tbl,
                                     ref_series = ref_series,
                                     dtw_funs = dtw_funs_lg,
                                     dtw_grids = dtw_grids_lg,
                                     num_best = 2)

head(search_res_lg)
#> # A tibble: 6 × 10
#>   query  algorithm distance window.size step_pattern_id norm  dtw.func normalize
#>   <chr>  <chr>        <dbl>       <int> <chr>           <chr> <chr>    <lgl>    
#> 1 death… dtw2        39791.           5 symmetric1      NA    NA       NA       
#> 2 death… dtw2        39791.           5 symmetric1      NA    NA       NA       
#> 3 death… dtw2        39791.           5 symmetric2      NA    NA       NA       
#> 4 death… dtw2        39793.           5 symmetric2      NA    NA       NA       
#> 5 death… dtw2        39791.           6 symmetric1      NA    NA       NA       
#> 6 death… dtw2        39791.           6 symmetric1      NA    NA       NA       
#> # ℹ 2 more variables: znorm <lgl>, return.shifted <lgl>


# Can still be ran with a minimal "grid"
params_ls_sm <- list(dtw2 = list(step.pattern = list(symmetric1)))

dtw_grids_sm <- create_dtw_grids(params_ls_sm)

dtw_funs_sm <- list(dtw2 = dtw2)

search_res_sm <- dtw_dist_gridsearch(query_tbl = query_tbl,
                                     ref_series = ref_series,
                                     dtw_funs = dtw_funs_sm,
                                     dtw_grids = dtw_grids_sm,
                                     num_best = "all")

head(search_res_sm)
#> # A tibble: 6 × 4
#>   query         algorithm distance step_pattern_id
#>   <chr>         <chr>        <dbl> <chr>          
#> 1 deaths_lead60 dtw2        39838. symmetric1     
#> 2 deaths_lead59 dtw2        39834. symmetric1     
#> 3 deaths_lead58 dtw2        39831. symmetric1     
#> 4 deaths_lead57 dtw2        39828. symmetric1     
#> 5 deaths_lead56 dtw2        39827. symmetric1     
#> 6 deaths_lead55 dtw2        39825. symmetric1     
```
