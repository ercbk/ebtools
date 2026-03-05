# US Regional COVID-19 Positive Cases Data Set

Contains rolling 7-day average COVID-19 cases for US regional areas from
April 1st, 2020 to February 13th, 2021.

## Usage

``` r
us_regional_cases
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with
1276 rows and 3 columns.

## Details

Data collected by the [Delphi Research
Group](https://github.com/cmu-delphi/covidcast).

## Examples

``` r
head(us_regional_cases)
#> # A tibble: 6 × 3
#>   date       region    reg_sev_day_cases
#>   <date>     <chr>                 <dbl>
#> 1 2020-04-01 midwest               2884.
#> 2 2020-04-01 northeast            13252.
#> 3 2020-04-01 south                 3797.
#> 4 2020-04-01 west                  2258.
#> 5 2020-04-02 midwest               3128.
#> 6 2020-04-02 northeast            14121.
```
