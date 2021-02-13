#' Calculate cross-correlation coefficients for prewhitened time series
#'
#' @description
#' [prewhitened_ccf()] prewhitens time series, calculates cross-correlation coefficients, and returns statistically significant values.
#'
#' @param input tsibble; The influential or "predictor-like" time series
#' @param output tsibble; The affected or "response-like" time series
#' @param input_col string; Name of the numeric column of the input tsibble
#' @param output_col string; Name of the numeric column of the output tsibble
#' @param keep_input string; values: "input_lags", "input_leads" or "both"; Default is "both".
#' @param keep_ccf string; values: "positive", "negative", or "both; Default is "both"
#' @param max.order integer; The maximum lag used in the CCF calculation.
#'
#' @return A tibble with the following columns:
#'
#' - input_type: "lag" or "lead"
#' - input_series: lag or lead number
#' - signif_type: "Statistically Significant" or "Not Statistically Significant"
#' - signif_threshold: Threashold CCF value for statistical significance at the 95% level
#' - ccf: Calculated ccf value
#'
#'
#' @details
#' In a cross-correlation in which the direction of influence between two time-series is hypothesized or known,
#'
#' - the influential time-series is called the "input" time-series
#' - the affected time-series is called the "output" time-series
#'
#' Sometimes only correlations between leads of the input series (or lags of the input series) and the output series make theoretical sense, or only positive or negative correlations make theoretical sense. The "keep_input" argument specifies whether you want to only output CCF values involving leads of the input series, lags of the input series, or both. The "keep_ccf" argument specifies whether you want to only output positive, negative, or both CCF values
#'
#' The prewhitening method that is used is from Cryer and Chan (2008, Chapter 11) Time Series Analysis. `prewhitened_ccf` differences the series if it's needed and outputs either statistically significant values of the CCF or the top non-statistically significant value if no statistically significant values are found.
#'
#' @references Cryer, D., Chan, K. (2008) Time Series Analysis, Springer Science+Business Media, LLC
#'
#'
#' @export
#'
#' @examples
#'
#' oh_cases <- ohio_covid %>%
#'    dplyr::select(date, cases) %>%
#'    tsibble::as_tsibble(index = date)
#'
#' oh_deaths <- ohio_covid %>%
#'    dplyr::select(date, deaths_lead0) %>%
#'    tsibble::as_tsibble(index = date)
#'
#' oh_ccf_tbl <- prewhitened_ccf(input = oh_cases,
#'                               output = oh_deaths,
#'                               input_col = "cases",
#'                               output_col = "deaths_lead0",
#'                               max.order = 40,
#'                               keep_input = "input_lag",
#'                               keep_ccf = "positive")
#'
#' oh_ccf_tbl



prewhitened_ccf <- function(input,
                            output,
                            input_col,
                            output_col,
                            keep_input = "both",
                            keep_ccf = "both",
                            max.order)
{

  # check args
  # check if series are tsibbles
  chk::chk_is(input, class = "tbl_ts")
  chk::chk_is(output, class = "tbl_ts")


  # check for only 1 numeric col
  count_num_numerics <- function(x) {
    classes_vec <- purrr::map_chr(x, ~class(.x))
    numerics_count <- sum(stringr::str_count(classes_vec, pattern = "numeric"))
  }

  chk::chk_equal(count_num_numerics(input), 1, x_name = "Number of numeric columns for input")
  chk::chk_equal(count_num_numerics(output), 1, x_name = "Number of numeric columns for output")

  keep_input_val <- match.arg(keep_input,
                              choices = c("input_lags",
                                          "input_leads",
                                          "both"),
                              several.ok = FALSE)

  keep_ccf_val <- match.arg(keep_ccf,
                            choices = c("positive",
                                        "negative",
                                        "both"),
                            several.ok = FALSE)


  # number of seasonal differences
  input_num_sdiffs <- input %>%
    fabletools::features_if(is.numeric, feasts::unitroot_nsdiffs) %>%
    dplyr::select(tidyselect::contains("nsdiffs")) %>%
    dplyr::pull()
  output_num_sdiffs <- output %>%
    fabletools::features_if(is.numeric, feasts::unitroot_nsdiffs) %>%
    dplyr::select(tidyselect::contains("nsdiffs")) %>%
    dplyr::pull()

  # choose largest sdiffs and apply it to both series
  sdiffs <- ifelse(input_num_sdiffs > output_num_sdiffs, input_num_sdiffs, output_num_sdiffs)

  if (sdiffs != 0) {
    input <- input %>%
      dplyr::mutate_if(is.numeric, tsibble::difference, sdiffs)
    output <- input %>%
      dplyr::mutate_if(is.numeric, tsibble::difference, sdiffs)
  }

  # number of differences
  input_num_diffs <- input %>%
    fabletools::features_if(is.numeric, feasts::unitroot_ndiffs) %>%
    dplyr::select(tidyselect::contains("ndiffs")) %>%
    dplyr::pull()
  output_num_diffs <- output %>%
    fabletools::features_if(is.numeric, feasts::unitroot_ndiffs) %>%
    dplyr::select(tidyselect::contains("ndiffs")) %>%
    dplyr::pull()

  # choose largest diffs and apply it to both series
  diffs <- ifelse(input_num_diffs > output_num_diffs, input_num_diffs, output_num_diffs)

  if (diffs != 0) {
    input <- input %>%
      dplyr::mutate_if(is.numeric, tsibble::difference, diffs)
    output <- output %>%
      dplyr::mutate_if(is.numeric, tsibble::difference, diffs)      }

  # There's a warning when the AR mod is fit and n isn't big enough to handle whatever the largest p is.
  # This trims down max.order so there isn't a warning because the parade of warnings bothers me.
  some_number <- (nrow(input) - 2) - max.order

  if (some_number <= max.order) {
    max.order <- max.order - (max.order - some_number + 1)
  }

  # fit AR model with processed input series
  input_ar_mod <- input %>%
    dplyr::rename_if(is.numeric, ~stringr::str_replace(.x, ".*", "value")) %>%
    # AR hates NAs
    tidyr::drop_na() %>%
    fabletools::model(fable::AR(value ~ order(p = 1:max.order), ic = "bic"))

  # pull AR coefs
  input_ar <- coef(input_ar_mod) %>%
    dplyr::filter(stringr::str_detect(term, "ar")) %>%
    dplyr::pull(estimate)


  # linearly filter both series with input AR coefs
  input_fil <- input %>%
    dplyr::mutate(dplyr::across(where(is.numeric), ~stats::filter(.x, filter = c(1, -input_ar),
                                                                  method = 'convolution', sides = 1)))
  output_fil <- output %>%
    dplyr::mutate(dplyr::across(where(is.numeric), ~stats::filter(.x, filter = c(1, -input_ar),
                                                           method = 'convolution', sides = 1)))
  # ccf fun needs a tsb
  whitened_tsb <- input_fil %>%
    dplyr::left_join(output_fil, by = c("date"))

  # Calc CCF vals
  ccf_vals <- whitened_tsb %>%
    feasts::CCF(!!rlang::sym(input_col), !!rlang::sym(output_col),
                lag_max = max.order, type = "correlation") %>%
    dplyr::mutate(signif_thresh = 1.96/sqrt(nrow(whitened_tsb)),
                  signif_type = ifelse(ccf >= signif_thresh | ccf <= -signif_thresh,
                                       "Statistically Significant",
                                       "Not Statistically Significant"),
                  signif_thresh = ifelse(ccf > 0, signif_thresh, -signif_thresh),
                  # lags have their own class believe it or not
                  lag = as.numeric(lag)) %>%
    dplyr::as_tibble() %>%
    dplyr::select(input_series = lag, signif_type, signif_thresh, ccf)

  # keep only lags, leads, or both
  if (keep_input_val == "input_lags"){

    input_filtered <- ccf_vals %>%
      dplyr::filter(input_series < 0) %>%
      dplyr::mutate(input_type = "lag",
                    input_series = -input_series) %>%
      dplyr::select(input_type, dplyr::everything())

  } else if (keep_input_val == "input_leads") {

    input_filtered <- ccf_vals %>%
      dplyr::filter(input_series > 0) %>%
      dplyr::mutate(input_type = "lead") %>%
      dplyr::select(input_type, dplyr::everything())

  } else if (keep_input_val == "both") {

    input_filtered <- ccf_vals %>%
      dplyr::mutate(input_type = ifelse(input_series > 0 , "lead", "lag"),
                    input_series = abs(input_series)) %>%
      dplyr::select(input_type, dplyr::everything())
  }

  # keep only positive, negative, or both
  if (keep_ccf_val == "positive"){

    ccf_filtered <- input_filtered %>%
      dplyr::filter(ccf > 0)

  } else if (keep_ccf_val == "negative") {

    ccf_filtered <- input_filtered %>%
      dplyr::filter(ccf < 0)

  } else if (keep_ccf_val == "both") {

    ccf_filtered <- input_filtered
  }


  signif_ccf_vals <- ccf_filtered %>%
    dplyr::filter(signif_type == "Statistically Significant")

  # if no lags were stat signif at 95% conf.level then take largest no signif lag
  if (nrow(signif_ccf_vals) == 0) {
    ccf_vals_final <- ccf_filtered %>%
      dplyr::slice_max(abs(ccf))
  } else {
    ccf_vals_final <- signif_ccf_vals
  }

  return(ccf_vals_final)
}



