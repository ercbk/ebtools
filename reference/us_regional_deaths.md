# US Regional COVID-19 Deaths Data Set

Contains rolling 7-day average COVID-19 deaths for US regional areas
from April 1st, 2020 to February 13th, 2021.

## Usage

``` r
us_regional_deaths
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with
1276 rows and 3 columns.

## Details

Data collected by the [Delphi Research
Group](https://github.com/cmu-delphi/covidcast).

## Examples

``` r
head(us_regional_deaths)
#> # A tibble: 6 × 3
#>   date       region    reg_sev_day_deaths
#>   <date>     <chr>                  <dbl>
#> 1 2020-04-01 midwest                 99.0
#> 2 2020-04-01 northeast              490. 
#> 3 2020-04-01 south                   93.3
#> 4 2020-04-01 west                    65.1
#> 5 2020-04-02 midwest                117. 
#> 6 2020-04-02 northeast              595. 
```
