#' Grid Search dtw distance functions
#'
#' @description
#' [dtw_dist_gridsearch()] performs a gridsearch using a list of parameter grids and a list of distance functions from the dtwclust package.
#'
#' @param query_tbl Data.frame or tibble containing columns of numeric vectors for each query time series that are to compared to the reference time series.
#' @param ref_series Numeric vector; the reference time series which is the series that all query series will compared to.
#' @param dtw_funs Named list of dtwclust distance functions. Names need to match those in dtw_grids
#' @param dtw_grids Object created by [create_dtw_grids()] or named nested list of parameter name-value pairs that correspond to the distance functions. Names need to match those in dtw_funs.
#' @param num_best Integer or "all"; if an integer, then that number of query series with the lowest distance values for each parameter configuration will be returned; if "all", then all results will be returned. Default is "all".
#'
#' @details The distance algorithms currently supported are:
#'
#' - dynamic time warping (`dtw_basic`)
#' - dynamic time warping with an additional L2 Norm (`dtw2`)
#' - dynamic time warping with lower bound (`dtw_lb`)
#' - Triangular Global Alignment Kernel (`gak`)
#' - Slope Based Distance (`sbd`)
#'
#'
#' @return A tibble with columns for the names of the query series, names of the distance functions, parameter values, and calculated distances.
#' @seealso [create_dtw_grids()] [dtwclust::dtw_basic()], [dtwclust::dtw2()], [dtwclust::dtw_lb()], [dtwclust::gak()], [dtwclust::sbd()]
#'
#'
#'
#' @export
#'
#' @examples
#'
#' library(dtwclust)
#'
#' head(ohio_covid)[,1:6]
#'
#' ref_series <- ohio_covid[["cases"]]
#' query_tbl <- dplyr::select(ohio_covid, -cases, -date)
#'
#'
#' params_ls_lg <- list(dtw_basic = list(window.size = 5:10,
#'                                       norm = c("L1", "L2"),
#'                                       step.pattern = list(symmetric1, symmetric2)),
#'                      dtw2 = list(step.pattern = list(symmetric1, symmetric2),
#'                                  window.size = 5:10),
#'                      dtw_lb = list(window.size = 5:10,
#'                                    norm = c("L1", "L2"),
#'                                    dtw.func = "dtw_basic",
#'                                    step.pattern = list(symmetric2)),
#'                      sbd = list(znorm = TRUE, return.shifted = FALSE),
#'                      gak = list(normalize = TRUE, window.size = 5:10))
#'
#' dtw_grids_lg <- create_dtw_grids(params_ls_lg)
#'
#' dtw_funs_lg <- list(dtw_basic = dtw_basic,
#'                     dtw2 = dtw2,
#'                     dtw_lb = dtw_lb,
#'                     sbd = sbd,
#'                     gak = gak)
#'
#' search_res_lg <- dtw_dist_gridsearch(query_tbl = query_tbl,
#'                                      ref_series = ref_series,
#'                                      dtw_funs = dtw_funs_lg,
#'                                      dtw_grids = dtw_grids_lg,
#'                                      num_best = 2)
#'
#' head(search_res_lg)
#'
#'
#' # Can still be ran with a minimal "grid"
#' params_ls_sm <- list(dtw2 = list(step.pattern = list(symmetric1)))
#'
#' dtw_grids_sm <- create_dtw_grids(params_ls_sm)
#'
#' dtw_funs_sm <- list(dtw2 = dtw2)
#'
#' search_res_sm <- dtw_dist_gridsearch(query_tbl = query_tbl,
#'                                      ref_series = ref_series,
#'                                      dtw_funs = dtw_funs_sm,
#'                                      dtw_grids = dtw_grids_sm,
#'                                      num_best = "all")
#'
#' head(search_res_sm)
#'



dtw_dist_gridsearch <- function(query_tbl, ref_series, dtw_funs, dtw_grids, num_best = "all") {

  # argument checks
  if (!tibble::is_tibble(query_tbl) | !is.data.frame(query_tbl)) {
    stop("query_tbl needs to be a data.frame or tibble")
  }

  if (any(sort(names(dtw_funs)) != sort(names(dtw_grids)))) {
    stop("The distance algorithms used in dtw_funs don't match the distance algorithms used in dtw_grids")
  }

  # if (!is.numeric(num_best) | num_best != "all") {
  #   stop("num_best should be an integer or 'all'")
  # }

  chk::chk_numeric(ref_series)


  dtw_grids <- dtw_grids[sort(names(dtw_grids))]
  dtw_funs <- dtw_funs[sort(names(dtw_funs))]


  # calculates distance using a dtw distance function from supplied list
  calc_dist <- function(dist_fun, params, query, ref, algorithm) {

    # add both series to parameter list
    args <- append(params, list(x = query, y = ref))
    # calc distance
    dist <- do.call(dist_fun, args)

    # dtw2 normally returns more stuff other than distance
    if (algorithm == "dtw2") {
      dist <- dist$distance
    }
    # dtw_lb returns matrix-like crossdist obj
    if (algorithm == "dtw_lb") {
      dist <- as.numeric(dist)
    }

    dist_ls <- append(params, c(distance = dist)) %>%
      # step.pattern obj causes error when creating results tibble so removing it
      purrr::list_modify(step.pattern = NULL)

    # contains query name, distance algorithm, distance, and params
    results <- do.call(dplyr::tibble, dist_ls) %>%
      dplyr::mutate(algorithm = algorithm)

    return(results)

  }

  # map each query series
  distances_tbl <- purrr::map_dfr(query_tbl, function(query) {

    # map each grid obj (1 for each distance function)
    query_res <- purrr::map2_dfr(dtw_grids, names(dtw_grids), function(grid, alg){

      # subset the dist function that goes with the grid being mapped
      dist_fun <- dtw_funs[[alg]]
      # map through each parameter configuration calculating the distance
      dist_tbl <- purrr::map_dfr(grid,
                                 ~purrr::exec("calc_dist", .x,
                                              dist_fun = dist_fun, query = query,
                                              ref = ref_series, algorithm = alg))

      return(dist_tbl)
    })
  }, .id = "query") %>%
    dplyr::relocate(algorithm, distance, .after = query)

  # get parameter names for the group_by below
  param_names <- names(distances_tbl)
  param_names <- param_names[!param_names %in% c("query", "distance")]

  # if specified, will filter top n results for each parameter configuration, otherwise returns complete results
  if (num_best != "all") {

    distances_tbl_final <- distances_tbl %>%
      dplyr::group_by_at(param_names) %>%
      dplyr::slice_min(distance, n = num_best) %>%
      dplyr::ungroup()

  } else {

    distances_tbl_final <- distances_tbl

  }

  return(distances_tbl_final)

}





