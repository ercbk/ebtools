# Ohio COVID-19 Data Set

Contains rolling 7-day averages of positive COVID-19 cases and leads of
COVID-19 deaths for Ohio from March 22nd, 2020 to December 1st, 2020.

## Usage

``` r
ohio_covid
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 255
rows and 63 columns.

## Details

Data collected from the New York Times COVID-19 data
[repository](https://github.com/nytimes/covid-19-data)

## Examples

``` r
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
```
