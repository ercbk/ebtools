
#' Autocorrelation test of the residuals of dynamic regression `fable` models with various specifications that have been fitted for a grouping variable
#'
#' @description
#' [test_fable_resids()] takes a nested tibble and checks `fable` model residuals for autocorrelation using the Ljung-Box test.
#'
#' @param mod_tbl tibble with a grouping variable and a nested list column with a list of model objects for each grouping variable value
#' @param grp_col name of the grouping variable column
#' @param mod_col name of the nested list column with the lists of `fable` model objects
#'
#' @return An unnested tibble with columns for the grouping variable, model names, and p-values from the Ljung-Box test.
#'
#' @details P-values less than 0.05 indicate autocorrelation is present. If all p-values round to less than 0.000, then a single "0" will be returned.
#'
#' @seealso [feasts::ljung_box()]
#'
#' @export
#'
#' @examples
#'
#' library(dplyr, warn.conflicts = F)
#' library(fable, quietly = T)
#' library(furrr, quietly = T)
#' plan(multisession)
#'
#' head(ohio_covid)[,1:6]
#'
#' models_dyn <- ohio_covid[ ,1:7] %>%
#'   tidyr::pivot_longer(
#'     cols = contains("lead"),
#'     names_to = "lead",
#'     values_to = "lead_deaths"
#'   ) %>%
#'   select(date, cases, lead, lead_deaths) %>%
#'   mutate(lead = as.numeric(stringr::str_remove(lead, "deaths_lead"))) %>%
#'   tsibble::as_tsibble(index = date, key = lead) %>%
#'   tidyr::drop_na() %>%
#'   tidyr::nest(data = c(date, cases, lead_deaths)) %>%
#'   # Run a regression on lagged cases and date vs deaths
#'   mutate(model = furrr::future_map(data, function(df) {
#'     model(.data = df,
#'           dyn_reg = ARIMA(lead_deaths ~ 1 + cases),
#'           dyn_reg_trend = ARIMA(lead_deaths ~ 1 + cases + trend()),
#'           dyn_reg_quad = ARIMA(lead_deaths ~ 1 + cases + poly(date, 2))
#'     )
#'   }
#'   ))
#' # shut down workers
#' plan(sequential)
#'
#' dyn_mod_tbl <- select(models_dyn, -data)
#'
#' fable_resid_res <- test_fable_resids(dyn_mod_tbl, grp_col = "lead", mod_col = "model")
#' head(fable_resid_res)




test_fable_resids <- function(mod_tbl, grp_col, mod_col) {

  # check args
  # col names should be strings
  chk::chk_string(grp_col)
  chk::chk_string(mod_col)
  # make sure mod_tbl is a tibble
  chk::chk_is(mod_tbl, class = "tbl")
  # column with model objs should be a fable class, "mod_df"
  chk::chk_is(mod_tbl[[mod_col]][[1]], class = "mdl_df", x_name = paste(mod_col, "column cells"))
  # mod_tbl should only have 2 columns
  chk::chk_equal(ncol(mod_tbl), 2, x_name = "Number of columns")



  find_resid_freq <- function(mod) {

    freq <- fabletools::augment(mod[[1]]) %>%
      dplyr::pull(.innov) %>%
      forecast::findfrequency(.)

  }

  # Hyndman's guidelines on choosing max lag for nonseasonal and seasonal ts
  find_max_lag <- function(mod, freq) {

    da_lag <- ifelse(freq > 1,
                     # seasonal
                     min(2 * freq, length(stats::residuals(mod))/5),
                     # nonseasonal
                     min(10, length(stats::residuals(mod))/5))

  }

  # calculate p-value for ljung-box test
  calc_lb_pval <- function(mod, max_lag, mod_dof){
    # lag must be > than dof for the test; if it's not, set the lag to dof + 3
    if (mod_dof > max_lag) {
      max_lag_lb <- mod_dof + 3
    } else {
      max_lag_lb <- max_lag
    }
    # create df with resids
    lb_pval <- fabletools::augment(mod[[1]]) %>%
      dplyr::as_tibble() %>%
      # get pval from LB test
      dplyr::summarize(lb_pval = as.numeric(feasts::ljung_box(.innov, lag = max_lag_lb, dof = mod_dof)["lb_pvalue"])) %>%
      dplyr::pull(lb_pval)

    return(lb_pval)
  }


  autocor_tests_res <- mod_tbl %>%
    # convert lists of model objs to model type columns
    tidyr::unnest_wider(col = !!rlang::sym(mod_col)) %>%
    tidyr::pivot_longer(cols = -!!rlang::sym(grp_col), names_to = "mod_name", values_to = "mod_obj") %>%
    dplyr::mutate(resid_freq = purrr::map_dbl(mod_obj, ~purrr::exec("find_resid_freq", .x)),
                  max_lag = purrr::map2_dbl(mod_obj, resid_freq,
                                            ~purrr::exec("find_max_lag", .x, .y)),
                  mod_dof = purrr::map_dbl(mod_obj, ~length(.x[[1]]$fit$model$coef)),
                  # get pval of ljung-box test
                  lb_pval = purrr::pmap_dbl(list(mod_obj, max_lag, mod_dof), .f = calc_lb_pval) %>%
                    round(3)) %>%
    dplyr::select(lead, mod_name, lb_pval) %>%
    dplyr::arrange(dplyr::desc(lb_pval))


  return(autocor_tests_res)

}




