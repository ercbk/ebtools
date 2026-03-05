# Indiana COVID-19 Positivity Rates Data Set

Contains weekly COVID-19 positivity rates for metropolitan statistical
areas in Indiana from April 4th, 2020 to January 30th, 2021.

## Usage

``` r
indiana_pos_rate
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 528
rows and 3 columns.

## Details

Data collected from state health departments and curated in my [Indiana
COVIDcast
Dashboard](https://github.com/ercbk/Indiana-COVIDcast-Dashboard/tree/master/data)
repository.

## Examples

``` r
head(indiana_pos_rate)
#> # A tibble: 6 × 3
#>   end_date   msa         pos_rate
#>   <date>     <chr>          <dbl>
#> 1 2020-04-04 Bloomington   0.112 
#> 2 2020-04-11 Bloomington   0.125 
#> 3 2020-04-18 Bloomington   0.111 
#> 4 2020-04-25 Bloomington   0.0281
#> 5 2020-05-02 Bloomington   0.0232
#> 6 2020-05-09 Bloomington   0.0233
```
