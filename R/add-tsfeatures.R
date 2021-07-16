#' Add time series features calculated by the tsfeatures package
#'
#' @description [add_tsfeatures()] adds a set of calculated features from the [tsfeatures](https://pkg.robjhyndman.com/tsfeatures/) package for each time series in the group. These features provide information about various characteristics of the time series.
#'
#' @param .tbl tibble; data with date (class: Date), value (class: numeric), and group (class: character) columns
#' @param ... character; one or more unquoted grouping columns
#' @param standardize logical; If TRUE (default), the function with standardize each feature.
#' @param parallel logical; If TRUE, features will be calculated in parallel. Default is FALSE.
#'
#' @return The original tibble with 20 additional feature columns.
#'
#' @details Function can be used with a global forecasting method or for EDA. See the [tsfeatures](https://pkg.robjhyndman.com/tsfeatures/) website for more details on these features.
#'
#' @seealso [tsfeatures::tsfeatures()]
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
#' new_tbl <- add_tsfeatures(group_ts_tbl, id)
#'
#' head(new_tbl)



add_tsfeatures <- function(.tbl, ..., standardize = TRUE, parallel = FALSE) {

  grp_tbl <- .tbl %>% dplyr::group_by(...)

  grp_names <- names(dplyr::group_keys(grp_tbl))

  feats <- grp_tbl %>%
    # convert obj to a list of ts class items
    dplyr::group_map(~tsbox::ts_ts(.x)) %>%
    # calc feats for each ts
    tsfeatures::tsfeatures(parallel = parallel)

  if (standardize) {
    feats <- feats %>%
      # standardize but if result is NA, revert to original value
      purrr::map_dfr(function(vec) {
        # note: if vec is all the same value, result of standardization is NA
        vec_std <- as.numeric(scale(vec))
        vec_fin <- ifelse(is.na(vec_std), vec, vec_std)
        return(vec_fin)
      })
  } else {
    # convert list back into a tbl
    feats <- feats %>%
      dplyr::bind_rows()
  }

  feats_fin <- feats %>%
    # add group names back
    dplyr::bind_cols(dplyr::group_keys(grp_tbl)) %>%
    dplyr::relocate(dplyr::all_of(grp_names), dplyr::everything())

  # join new features back to original tbl
  ts_feats_tbl <- grp_tbl %>%
    dplyr::left_join(feats_fin, by = grp_names) %>%
    dplyr::ungroup()

}

