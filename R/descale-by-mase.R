#' Back-transform a MASE-scaled column
#'
#' @description [descale_by_mase()] back-transforms a group time series that has been scaled by a factor derived from the MASE error function.
#'
#' @param .tbl tibble; data with a value (class: numeric) column and group (class: character) column(s)
#' @param .value numeric; unquoted name of the column that contains the scaled numeric values
#' @param  scale_factors tibble; tibble extracted from the `scale_factors` attribute of the output of [scale_by_mase()]. Grouping columns should match those in `.tbl`. (See details)
#' @param ... character; one or more unquoted grouping columns
#'
#' @return The original tibble with the `.value` column back-transformed to the orginal scale.
#'
#' @details Scaling a grouped time series can be helpful for global forecasting methods when using machine learning and deep learning algorithms. Scaling by MASE and using MASE as the error function is equivalent to to minimizing the MAE in the preprocessed time series.
#'
#' The `scale_factors` tibble can be extracted by `scale_factors <- attributes(mase_scaled_tbl)$scale_factors` where `mase_scaled_tbl` is the output of [scale_by_mase()].
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
#' new_tbl <- scale_by_mase(.tbl = group_ts_tbl, .value = value, id)
#'
#' glimpse(new_tbl)
#'
#' scale_factors <- attributes(new_tbl)$scale_factors
#'
#' orig_tbl <- descale_by_mase(new_tbl, value, scale_factors, id)
#'
#' head(orig_tbl)



descale_by_mase <- function(.tbl, .value, scale_factors, ...) {

  ### checks ###
  # making ... into obj that can be tested
  dots <- rlang::enquos(..., .named = TRUE)
  # group column(s) required
  chk::chk_not_empty(dots, x_name = "... (group columns)")

  # check types
  ts_value <- .tbl %>% dplyr::pull({{.value}})
  grps <- .tbl %>% dplyr::select(...)
  scale_grps <- scale_factors %>% dplyr::select(...)

  purrr::walk(grps, ~chk::chk_character_or_factor(.x, x_name = "... (group columns)"))
  purrr::walk(scale_grps, ~chk::chk_character_or_factor(.x, x_name = "... (group columns)"))
  chk::chk_is(.tbl, class = "tbl")
  chk::chk_is(scale_factors, class = "tbl")
  chk::chk_identical(names(grps), names(scale_grps), x_name = "grouping columns")
  chk::chk_numeric(ts_value, x_name = ".value")



  grp_tbl <- .tbl %>% dplyr::group_by(...)
  grp_names <- names(dplyr::group_keys(grp_tbl))

  # get MASE scale factors
  grp_scales <- scale_factors %>%
    dplyr::group_by(...) %>%
    dplyr::arrange(grp_names) %>%
    dplyr::group_split()
  # split up the tbl for purrr::map2 below
  split_grp_tbl <- grp_tbl %>%
    dplyr::arrange(grp_names) %>%
    dplyr::group_split()

  # scale each group ts by their mase scale factor
  scaled_tbl <- purrr::map2_dfr(split_grp_tbl, grp_scales,
                                function(grp, scale) {
                                  scale_value <- scale$scale[[1]]
                                  grp_scaled <- grp %>%
                                    dplyr::mutate("{{.value}}" := {{.value}} * scale_value)
                                })

}
