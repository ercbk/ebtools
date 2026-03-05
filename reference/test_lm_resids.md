# Autocorrelation tests of the residuals of `lm` models with various specifications that have been fitted for a grouping variable

`test_lm_resids()` takes a nested tibble and checks `lm` model residuals
for autocorrelation using Breusch-Godfrey and Durbin-Watson tests.

## Usage

``` r
test_lm_resids(mod_tbl, grp_col, mod_col)
```

## Arguments

- mod_tbl:

  tibble with a grouping variable and a nested list column with a list
  of model objects for each grouping variable value

- grp_col:

  name of the grouping variable column

- mod_col:

  name of the nested list column with the lists of `lm` model objects

## Value

An unnested tibble with the columns for the grouping variable, model
names, and p-values for both tests.

## Details

P-values less than 0.05 indicate autocorrelation is present. If all
p-values round to less than 0.000, then a single "0" will be returned.

## See also

[`DescTools::BreuschGodfreyTest()`](https://andrisignorell.github.io/DescTools/reference/BreuschGodfreyTest.html),
[`DescTools::DurbinWatsonTest()`](https://andrisignorell.github.io/DescTools/reference/DurbinWatsonTest.html)

## Examples

``` r
library(dplyr, warn.conflicts = FALSE)

head(ohio_covid)[ ,1:6]
#> # A tibble: 6 × 6
#>   date       cases deaths_lead60 deaths_lead59 deaths_lead58 deaths_lead57
#>   <date>     <dbl>         <dbl>         <dbl>         <dbl>         <dbl>
#> 1 2020-03-22  44.9          43.1          42.6          40.6          42.9
#> 2 2020-03-23  56.3          41.6          43.1          42.6          40.6
#> 3 2020-03-24  71            49.4          41.6          43.1          42.6
#> 4 2020-03-25  88.1          49.1          49.4          41.6          43.1
#> 5 2020-03-26 107.           47.1          49.1          49.4          41.6
#> 6 2020-03-27 139.           40.3          47.1          49.1          49.4

models_lm <- ohio_covid %>%
  tidyr::pivot_longer(
    cols = contains("lead"),
    names_to = "lead",
    values_to = "lead_deaths"
  ) %>%
  mutate(lead = as.numeric(stringr::str_remove(lead, "deaths_lead"))) %>%
  tidyr::nest(data = c(date, cases, lead_deaths)) %>%
  arrange(lead) %>%
  mutate(model = purrr::map(data, function(df) {
    lm_poly <- lm(lead_deaths ~ cases + poly(date, 3), data = df, na.action = NULL)
    lm_poly_log <- lm(log(lead_deaths) ~ log(cases) + poly(date, 3), data = df, na.action = NULL)
    lm_quad_st <- lm(lead_deaths ~ cases + poly(date, 3), data = df, na.action = NULL)
    lm_quad_log <- lm(log(lead_deaths) ~ log(cases) + poly(date, 3), data = df, na.action = NULL)
    lm_ls <- list(lm_quad_st = lm_quad_st, lm_quad_log = lm_quad_log,
                  lm_poly = lm_poly, lm_poly_log = lm_poly_log)
    return(lm_ls)
  }
  ))

models_tbl <- select(models_lm, -data)
group_var <- "lead"
model_var <- "model"

resid_test_results <- test_lm_resids(models_tbl, group_var, model_var)
head(resid_test_results)
#> # A tibble: 6 × 4
#>    lead mod_name    bg_pval dw_pval
#>   <dbl> <chr>         <dbl>   <dbl>
#> 1     0 lm_quad_st        0       0
#> 2     0 lm_quad_log       0       0
#> 3     0 lm_poly           0       0
#> 4     0 lm_poly_log       0       0
#> 5     1 lm_quad_st        0       0
#> 6     1 lm_quad_log       0       0
```
