#' Scale a group time series by using a factor derived from the MASE error function
#'
#' @description [scale_by_mase()] scales a group time series by using a factor derived from the MASE error function.
#'
#' @param .tbl tibble; data with a value (class: numeric) column and group (class: character) column(s)
#' @param .value numeric; unquoted name of the column that contains the numeric values
#' @param ... character; one or more unquoted grouping columns
#'
#' @return The original tibble with the `.value` column back-transformed to the orginal scale.
#'
#' @details Scaling a grouped time series can be helpful for global forecasting methods when using machine learning and deep learning algorithms. Scaling by MASE and using MASE as the error function is equivalent to to minimizing the MAE in the preprocessed time series.
#'
#' For each series, a MASE scale factor is calculated using the denominator of the MASE scaled error equation. Then, the series is divided by this factor.
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
#' head(new_tbl)
#'
#' attributes(new_tbl)$scale_factors



scale_by_mase <- function(.tbl, .value, ...) {

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


  # calculate scale factor
  calc_mase_scal = function(grp_val) {

    x <- dplyr::select(grp_val,{{.value}}) %>% pull(1)
    frq = floor(stats::frequency(x))

    if (length(x) < frq) {
      warning("MASE calc: Series shorter than its period, period will be set to 1 for MASE calculations")
      frq = 1
    }

    # part of the denominator of scaled error equation in MASE
    tibble::tibble(scale = mean(abs(utils::head(as.vector(x), -frq) - utils::tail(as.vector(x), -frq))))

  }


  grp_tbl <- .tbl %>% dplyr::group_by(...)
  grp_names <- names(dplyr::group_keys(grp_tbl))

  # get MASE scale factors
  grp_scales <- grp_tbl %>%
    dplyr::arrange(grp_names) %>%
    dplyr::group_map(~calc_mase_scal(.x))
  # split up the tbl for purrr::map2 below
  split_grp_tbl <- grp_tbl %>%
    dplyr::arrange(grp_names) %>%
    dplyr::group_split()


  ### Check whether any group's MASE scale factor is too low ###
  low_scale_grps <- grp_scales %>%
    # list of tibbles to tibble
    dplyr::bind_rows() %>%
    # add group names back
    dplyr::bind_cols(dplyr::arrange(dplyr::group_keys(grp_tbl))) %>%
    dplyr::filter(scale < 0.0001) %>%
    dplyr::select(dplyr::all_of(grp_names))

  if (length(low_scale_grps > 0)) {
    msg <- "These groups have MASE scale factors that are below 0.0001 and shouldn't be MASE-scaled. They need to be removed or another scaling method should be used."
    print(low_scale_grps)
    stop(msg)
  }

  # scale each group ts by their mase scale factor
  scaled_tbl <- purrr::map2_dfr(split_grp_tbl, grp_scales,
                                function(grp, scale) {
                                  scale_value <- scale[[1]]
                                  grp_scaled <- grp %>%
                                    dplyr::mutate({{.value}} := {{.value}} / scale_value)
                                })

  # add scale factors tbl as an attribute
  # needed to descale forecasts
  attr(scaled_tbl, "scale_factors") <- grp_scales %>%
    # list of tibbles to tibble
    dplyr::bind_rows() %>%
    # add group names back
    dplyr::bind_cols(dplyr::arrange(dplyr::group_keys(grp_tbl))) %>%
    dplyr::relocate(dplyr::all_of(grp_names), dplyr::everything())

  return(scaled_tbl)

}

