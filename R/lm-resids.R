#' Autocorrelation tests of the residuals of `lm` models with various specifications that have been fitted for a grouping variable
#'
#' @description
#' [test_lm_resids()] takes a nested tibble and checks `lm` model residuals for autocorrelation using Breusch-Godfrey and Durbin-Watson tests
#'
#' @param mod_tbl tibble with a grouping variable and a nested list column with a list of model objects for each grouping variable value
#' @param grp_col name of the grouping variable column
#' @param mod_col name of the nested list column with the lists of `lm` model objects
#'
#' @return An unnested tibble with the columns for the grouping variable, model names, and p-values for both tests.
#'
#' @details P-values less than 0.05 indicate autocorrelation is present. If all p-values round to less than 0.000, then a single "0" will be returned.
#'
#' @seealso [DescTools::BreuschGodfreyTest()], [DescTools::DurbinWatsonTest()]
#'
#' @export
#'
#' @examples
#'
#' library(dplyr)
#'
#' head(ohio_covid)
#'
#' models_lm <- ohio_covid %>%
#'   tidyr::pivot_longer(
#'     cols = contains("lead"),
#'     names_to = "lead",
#'     values_to = "lead_deaths"
#'   ) %>%
#'   mutate(lead = as.numeric(stringr::str_remove(lead, "deaths_lead"))) %>%
#'   tidyr::nest(data = c(date, cases, lead_deaths)) %>%
#'   arrange(lead) %>%
#'   mutate(model = purrr::map(data, function(df) {
#'     lm_poly <- lm(lead_deaths ~ cases + poly(date, 3), data = df, na.action = NULL)
#'     lm_poly_log <- lm(log(lead_deaths) ~ log(cases) + poly(date, 3), data = df, na.action = NULL)
#'     lm_quad_st <- lm(lead_deaths ~ cases + poly(date, 3), data = df, na.action = NULL)
#'     lm_quad_log <- lm(log(lead_deaths) ~ log(cases) + poly(date, 3), data = df, na.action = NULL)
#'     lm_ls <- list(lm_quad_st = lm_quad_st, lm_quad_log = lm_quad_log,
#'                   lm_poly = lm_poly, lm_poly_log = lm_poly_log)
#'     return(lm_ls)
#'   }
#'   ))
#'
#' models_tbl <- select(models_lm, -data)
#' group_var <- "lead"
#' model_var <- "model"
#'
#' resid_test_results <- test_lm_resids(models_tbl, group_var, model_var)
#' head(resid_test_results)




test_lm_resids <- function(mod_tbl, grp_col, mod_col) {

  # check args
  # col names should be strings
  chk::chk_string(grp_col)
  chk::chk_string(mod_col)
  # make sure mod_tbl is a tibble
  chk::chk_is(mod_tbl, class = "tbl")
  # mod_tbl should only have 2 columns
  chk::chk_equal(ncol(mod_tbl), 2, x_name = "Number of columns")
  # column with model objs should be a nested list
  chk::chk_list(mod_tbl[[mod_col]][[1]], x_name = paste(mod_col, "column cells"))

  # Hyndman's guidelines on choosing max lag for BG test for nonseasonal and seasonal ts
  find_max_lag <- function(freq, mod) {
    res <- ifelse(freq > 1,
                  # seasonal
                  min(2 * freq, length(stats::residuals(mod))/5),
                  # nonseasonal
                  min(10, length(stats::residuals(mod))/5))
    return(res)
  }

  autocor_tests_res <- mod_tbl %>%
    # unnest model list column into name and obj columns
    tidyr::unnest_longer(col = !!rlang::sym(mod_col), indices_to = "mod_name", values_to = "mod_obj") %>%
    # ts that are nonseasonal will have a freq of 1
    dplyr::mutate(resid_freq = purrr::map_dbl(mod_obj, ~forecast::findfrequency(residuals(.x))),
                  max_lag = purrr::map2_dbl(resid_freq, mod_obj,
                                            ~purrr::exec("find_max_lag", .x, .y)),
                  bg_pval = purrr::map2_dbl(mod_obj, max_lag,
                                            ~DescTools::BreuschGodfreyTest(formula = .x,
                                                                           order = .y)$p.value) %>%
                    # if all pvals round to 3 zeros, then it will just return 1 zero
                    round(3),
                  dw_pval = purrr::map_dbl(mod_obj,
                                           ~DescTools::DurbinWatsonTest(formula = .x)$p.value) %>%
                    round(3)) %>%
    dplyr::select(-mod_obj, -resid_freq, -max_lag)

  return(autocor_tests_res)
}



