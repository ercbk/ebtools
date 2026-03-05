# Autocorrelation test of the residuals of dynamic regression `fable` models with various specifications that have been fitted for a grouping variable

`test_fable_resids()` takes a nested tibble and checks `fable` model
residuals for autocorrelation using the Ljung-Box test.

## Usage

``` r
test_fable_resids(mod_tbl, grp_col, mod_col)
```

## Arguments

- mod_tbl:

  tibble with a grouping variable and a nested list column with a list
  of model objects for each grouping variable value

- grp_col:

  name of the grouping variable column

- mod_col:

  name of the nested list column with the lists of `fable` model objects

## Value

An unnested tibble with columns for the grouping variable, model names,
and p-values from the Ljung-Box test.

## Details

P-values less than 0.05 indicate autocorrelation is present. If all
p-values round to less than 0.000, then a single "0" will be returned.

## See also

[`feasts::ljung_box()`](https://feasts.tidyverts.org/reference/portmanteau_tests.html)

## Examples

``` r
 library(dplyr, warn.conflicts = FALSE)
 library(fable, quietly = TRUE)
 library(mirai)

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

 daemons(3)

 models_dyn <- ohio_covid[ ,1:7] %>%
  tidyr::pivot_longer(
    cols = contains("lead"),
    names_to = "lead",
    values_to = "lead_deaths"
  ) %>%
  select(date, cases, lead, lead_deaths) %>%
  mutate(lead = as.numeric(stringr::str_remove(lead, "deaths_lead"))) %>%
  tsibble::as_tsibble(index = date, key = lead) %>%
  tidyr::drop_na() %>%
  tidyr::nest(data = c(date, cases, lead_deaths)) %>%
  # Run a regression on lagged cases and date vs deaths
  mutate(model = purrr::map(data, purrr::in_parallel(\(df) {
    fabletools::model(
      .data = df,
      dyn_reg = fable::ARIMA(lead_deaths ~ 1 + cases),
      dyn_reg_trend = fable::ARIMA(lead_deaths ~ 1 + cases + trend()),
      dyn_reg_quad = fable::ARIMA(lead_deaths ~ 1 + cases + poly(date, 2))
    )})))

 # shut down workers
 daemons(0)

 dyn_mod_tbl <- select(models_dyn, -data)
 fable_resid_res <- test_fable_resids(dyn_mod_tbl, grp_col = "lead", mod_col = "model")
 head(fable_resid_res)
#> # A tibble: 6 × 3
#>    lead mod_name     lb_pval
#>   <dbl> <chr>          <dbl>
#> 1    56 dyn_reg        0.037
#> 2    58 dyn_reg        0.035
#> 3    59 dyn_reg        0.031
#> 4    57 dyn_reg        0.026
#> 5    60 dyn_reg        0.016
#> 6    58 dyn_reg_quad   0.005
```
