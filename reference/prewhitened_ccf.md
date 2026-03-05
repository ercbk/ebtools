# Calculate cross-correlation coefficients for prewhitened time series

`prewhitened_ccf()` prewhitens time series, calculates cross-correlation
coefficients, and returns statistically significant values.

## Usage

``` r
prewhitened_ccf(
  input,
  output,
  input_col,
  output_col,
  keep_input = "both",
  keep_ccf = "both",
  max.order
)
```

## Arguments

- input:

  tsibble; The influential or "predictor-like" time series

- output:

  tsibble; The affected or "response-like" time series

- input_col:

  string; Name of the numeric column of the input tsibble

- output_col:

  string; Name of the numeric column of the output tsibble

- keep_input:

  string; values: "input_lags", "input_leads" or "both"; Default is
  "both".

- keep_ccf:

  string; values: "positive", "negative", or "both; Default is "both"

- max.order:

  integer; The maximum lag used in the CCF calculation.

## Value

A tibble with the following columns:

- input_type: "lag" or "lead"

- input_series: lag or lead number

- signif_type: "Statistically Significant" or "Not Statistically
  Significant"

- signif_threshold: Threashold CCF value for statistical significance at
  the 95% level

- ccf: Calculated ccf value

## Details

In a cross-correlation in which the direction of influence between two
time-series is hypothesized or known,

- The influential time-series is called the "input" time-series

- The affected time-series is called the "output" time-series

The cross-correlation function calculates correlation values between
lags and leads of the input series and the output series. Sometimes only
correlations between the leads or lags of the input series and the
output series make theoretical sense, or only positive or negative
correlations make theoretical sense.

- The "keep_input" argument specifies whether you want to keep only
  output CCF values involving leads or lags of the input series or both.

- The "keep_ccf" argument specifies whether you want to keep only output
  positive, negative, or both CCF values.

`prewhitened_ccf` differences the series if it's needed, prewhitens, and
outputs either statistically significant values of the CCF or the top
non-statistically significant value if no statistically significant
values are found. The prewhitening method that is used is from Cryer and
Chan (2008, Chapter 11).

## References

Cryer, Jonathan, and Chan, Kung-Sik. 2008. Time Series Analysis With
Applications in R. New York: Springer Science+Business Media (pp.
260-271)

## Examples

``` r
oh_cases <- ohio_covid %>%
   dplyr::select(date, cases) %>%
   tsibble::as_tsibble(index = date)

oh_deaths <- ohio_covid %>%
   dplyr::select(date, deaths_lead0) %>%
   tsibble::as_tsibble(index = date)

oh_ccf_tbl <- prewhitened_ccf(input = oh_cases,
                              output = oh_deaths,
                              input_col = "cases",
                              output_col = "deaths_lead0",
                              max.order = 40,
                              keep_input = "input_lag",
                              keep_ccf = "positive")

oh_ccf_tbl
#> # A tibble: 1 × 5
#>   input_type input_series signif_type                   signif_thresh    ccf
#>   <chr>             <dbl> <chr>                                 <dbl>  <dbl>
#> 1 lag                   6 Not Statistically Significant         0.123 0.0772


library(dplyr, warn.conflicts = FALSE)

reg_cases_tsb <- us_regional_cases %>%
  tsibble::as_tsibble(index = date, key = region) %>%
  tsibble::group_by_key() %>%
  tidyr::nest() %>%
  arrange(region) %>%
  ungroup() %>%
  mutate(id = as.character(row_number()))

reg_deaths_tsb <- us_regional_deaths %>%
  tsibble::as_tsibble(index = date, key = region) %>%
  tsibble::group_by_key() %>%
  tidyr::nest() %>%
  arrange(region) %>%
  ungroup() %>%
  mutate(id = as.character(row_number()))

reg_ccf_vals <- purrr::map2_dfr(reg_cases_tsb$data,
                                reg_deaths_tsb$data,
                                prewhitened_ccf,
                                input_col = "reg_sev_day_cases",
                                output_col = "reg_sev_day_deaths",
                                max.order = 40,
                                .id = "id") %>%
  left_join(reg_cases_tsb %>%
             select(id, region), by = "id")

head(reg_ccf_vals)
#> # A tibble: 6 × 7
#>   id    input_type input_series signif_type          signif_thresh    ccf region
#>   <chr> <chr>             <dbl> <chr>                        <dbl>  <dbl> <chr> 
#> 1 1     lag                  28 Statistically Signi…         0.110  0.132 midwe…
#> 2 1     lag                  21 Statistically Signi…        -0.110 -0.137 midwe…
#> 3 1     lag                  19 Statistically Signi…         0.110  0.110 midwe…
#> 4 1     lag                  18 Statistically Signi…         0.110  0.125 midwe…
#> 5 1     lag                  14 Statistically Signi…        -0.110 -0.110 midwe…
#> 6 1     lag                   0 Statistically Signi…         0.110  0.222 midwe…
```
