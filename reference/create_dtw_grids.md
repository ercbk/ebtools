# Create a parameter grid list for `dtwclust` and `dtw` distance functions

`create_dtw_grids()` creates a nested, parameter grid list for dtwclust
and dtw distance functions to be used in
[`dtw_dist_gridsearch()`](https://ercbk.github.io/ebtools/reference/dtw_dist_gridsearch.md).

## Usage

``` r
create_dtw_grids(params)
```

## Arguments

- params:

  A named list of parameter name-value pairs. The names should be the
  names of the distance functions that correspond to the parameter
  name-value pairs.

## Value

Named, nested list where each element is a list of elements that
represent each possible configuration for the parameters of that
distance function.

## Examples

``` r
params_ls_lg <- list(dtw_basic = list(window.size = 5:10,
                                      norm = c("L1", "L2"),
                                      step.pattern = list(dtw::symmetric1, dtw::symmetric2)),
                     dtw2 = list(step.pattern = list(dtw::symmetric1, dtw::symmetric2),
                                 window.size = 5:10),
                     dtw_lb = list(window.size = 5:10,
                                   norm = c("L1", "L2"),
                                   dtw.func = "dtw_basic",
                                   step.pattern = list(dtw::symmetric2)),
                     sbd = list(znorm = TRUE, return.shifted = FALSE),
                     gak = list(normalize = TRUE, window.size = 5:10))

dtw_grids_lg <- create_dtw_grids(params_ls_lg)
#> Warning: `cross()` was deprecated in purrr 1.0.0.
#> ℹ Please use `tidyr::expand_grid()` instead.
#> ℹ See <https://github.com/tidyverse/purrr/issues/768>.
#> ℹ The deprecated feature was likely used in the ebtools package.
#>   Please report the issue at <https://github.com/ercbk/ebtools/issues>.
str(dtw_grids_lg$dtw_basic[1:4])
#> List of 4
#>  $ :List of 4
#>   ..$ window.size    : int 5
#>   ..$ norm           : chr "L1"
#>   ..$ step.pattern   : 'stepPattern' num [1:6, 1:4] 1 1 2 2 3 3 1 0 0 0 ...
#>   .. ..- attr(*, "npat")= num 3
#>   .. ..- attr(*, "norm")= logi NA
#>   ..$ step_pattern_id: chr "symmetric1"
#>  $ :List of 4
#>   ..$ window.size    : int 6
#>   ..$ norm           : chr "L1"
#>   ..$ step.pattern   : 'stepPattern' num [1:6, 1:4] 1 1 2 2 3 3 1 0 0 0 ...
#>   .. ..- attr(*, "npat")= num 3
#>   .. ..- attr(*, "norm")= logi NA
#>   ..$ step_pattern_id: chr "symmetric1"
#>  $ :List of 4
#>   ..$ window.size    : int 7
#>   ..$ norm           : chr "L1"
#>   ..$ step.pattern   : 'stepPattern' num [1:6, 1:4] 1 1 2 2 3 3 1 0 0 0 ...
#>   .. ..- attr(*, "npat")= num 3
#>   .. ..- attr(*, "norm")= logi NA
#>   ..$ step_pattern_id: chr "symmetric1"
#>  $ :List of 4
#>   ..$ window.size    : int 8
#>   ..$ norm           : chr "L1"
#>   ..$ step.pattern   : 'stepPattern' num [1:6, 1:4] 1 1 2 2 3 3 1 0 0 0 ...
#>   .. ..- attr(*, "npat")= num 3
#>   .. ..- attr(*, "norm")= logi NA
#>   ..$ step_pattern_id: chr "symmetric1"


# Can still be ran with a minimal "grid"
params_ls_sm <- list(dtw2 = list(step.pattern = list(dtw::symmetric1)))

dtw_grids_sm <- create_dtw_grids(params_ls_sm)
head(dtw_grids_sm)
#> $dtw2
#> $dtw2[[1]]
#> $dtw2[[1]]$step.pattern
#> Step pattern recursion:
#> g[i,j] = min(
#>      g[i-1,j-1] +     d[i  ,j  ] ,
#>      g[i  ,j-1] +     d[i  ,j  ] ,
#>      g[i-1,j  ] +     d[i  ,j  ] ,
#>   )
#> 
#>  Normalization hint: NA
#> 
#> $dtw2[[1]]$step_pattern_id
#> [1] "symmetric1"
#> 
#> 
#> 
```
