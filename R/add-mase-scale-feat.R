#' Add a scale feature by using a factor derived from the MASE error function
#'
#' @description
#' [add_mase_scale_feat()] calculates a MASE scale factor and divides this factor by the group average scale factor to produce a scale feature.
#'
#' @param .tbl tibble; data with grouping column and value column
#' @param .value numeric; unquoted name of the column that contains the numeric values of the time series
#' @param ... character; one or more unquoted grouping columns
#'
#' @return The original tibble with an additional column, "scale."
#'
#' @details Designed to use with a global forecasting method. It's recommended to standardize the stacked series that is used as input for this method. Standardizing the stacked series removes the scale information about each series in the stack which might be useful in generating the forecast. Adding a scale feature reintroduces this information back into the model.
#'
#' @references Pablo Montero-Manso, Rob J. Hyndman, Principles and algorithms for forecasting groups of time series: Locality and globality, International Journal of Forecasting, 2021 [link](https://robjhyndman.com/publications/global-forecasting/)
#'
#' @export
#'
#' @examples
#'
#' library(dplyr, warn.conflicts = FALSE)
#'
#' group_ts_tbl <- tsbox::ts_tbl(fpp2::arrivals)
#'
#' head(group_ts_tbl)
#'
#' new_tbl <- add_mase_scale_feat(group_ts_tbl, .value = value, id)
#'
#' head(new_tbl)



add_mase_scale_feat <- function(.tbl, .value, ...) {

  ### checks ###
  # making ... into obj that can be tested
  dots <- rlang::enquos(..., .named = TRUE)
  # group column(s) required
  chk::chk_not_empty(dots, x_name = "... (group columns)")

  # check types
  ts_value <- .tbl %>% dplyr::pull({{.value}})
  grps <- .tbl %>% dplyr::select(...)

  purrr::walk(grps, ~chk::chk_character_or_factor(.x, x_name = "... (group columns)"))
  chk::chk_is(.tbl, class = "tbl")
  chk::chk_numeric(ts_value, x_name = ".value")


  # calculates MASE scale factor
  calc_mase_scal = function(grp_val) {

    x <- dplyr::select(grp_val,{{.value}}) %>% dplyr::pull(1)
    frq = floor(stats::frequency(x))

    if (length(x) < frq) {
      warning("MASE calc: Series shorter than its period, period will be set to 1 for MASE calculations")
      frq = 1
    }

    # part of the denominator of scaled error equation in MASE
    tibble::tibble(scale_factor = mean(abs(utils::head(as.vector(x), -frq) - utils::tail(as.vector(x), -frq))))

  }


  grp_tbl <- .tbl %>% dplyr::group_by(...)
  grp_names <- names(dplyr::group_keys(grp_tbl))

  # calc scale column for each group's series
  scales <- grp_tbl %>%
    dplyr::group_map(~calc_mase_scal(.x)) %>%
    dplyr::bind_rows() %>%
    dplyr::bind_cols(dplyr::group_keys(grp_tbl)) %>%
    # the other parts of the scaled error equation in MASE
    dplyr::mutate(scale = scale_factor / mean(scale_factor)) %>%
    dplyr::select(-scale_factor)

  # add scale column to original tbl
  ts_scale_tbl <- grp_tbl %>%
    dplyr::left_join(scales, by = grp_names) %>%
    dplyr::ungroup()

}


