#' Create a parameter grid list for `dtwclust` and `dtw` distance functions
#'
#' @description
#' [create_dtw_grids()] creates a nested, parameter grid list for dtwclust and dtw distance functions to be used in [dtw_dist_gridsearch()].
#'
#' @param params A named list of parameter name-value pairs. The names should be the names of the distance functions that correspond to the parameter name-value pairs.
#'
#' @return Named, nested list where each element is a list of elements that represent each possible configuration for the parameters of that distance function.
#'
#' @export
#'
#' @examples
#'
#' params_ls_lg <- list(dtw_basic = list(window.size = 5:10,
#'                                       norm = c("L1", "L2"),
#'                                       step.pattern = list(dtw::symmetric1, dtw::symmetric2)),
#'                      dtw2 = list(step.pattern = list(dtw::symmetric1, dtw::symmetric2),
#'                                  window.size = 5:10),
#'                      dtw_lb = list(window.size = 5:10,
#'                                    norm = c("L1", "L2"),
#'                                    dtw.func = "dtw_basic",
#'                                    step.pattern = list(dtw::symmetric2)),
#'                      sbd = list(znorm = TRUE, return.shifted = FALSE),
#'                      gak = list(normalize = TRUE, window.size = 5:10))
#'
#' dtw_grids_lg <- create_dtw_grids(params_ls_lg)
#' str(dtw_grids_lg$dtw_basic[1:4])
#'
#'
#' # Can still be ran with a minimal "grid"
#' params_ls_sm <- list(dtw2 = list(step.pattern = list(dtw::symmetric1)))
#'
#' dtw_grids_sm <- create_dtw_grids(params_ls_sm)
#' head(dtw_grids_sm)



create_dtw_grids <- function(params) {

  # argument checks
  chk::chk_list(params)

  # check if distance algorithms supported
  alg_names <- match.arg(names(params),
                         choices = c("dtw_basic",
                                     "dtw2",
                                     "dtw_lb",
                                     "sbd",
                                     "SBD",
                                     "gak",
                                     "GAK"),
                         several.ok = TRUE)


  build_grid <- function(dist_alg){

    grid_initial <- purrr::cross(params[[dist_alg]])

    # Add names of step patterns to the grids
    # Have to do it this way as long as cross_df doesn't work with pattern objs (otherwis could just mutate)
    # Currently there isn't an easier way to match the pattern obj to its name
    if ("step.pattern" %in% names(params[[dist_alg]])) {

      grid_final <- purrr::modify(grid_initial, .f = function(x) {

        # coerce step pattern obj to a numeric vector to determine which step pattern it is
        step_test <- as.numeric(x$step.pattern)
        step_sym1 <- as.numeric(dtw::symmetric1)
        step_sym2 <- as.numeric(dtw::symmetric2)
        # compare patterns' numeric vectors then add step.pattern label to grid
        if (all(step_test == step_sym1)) {
          param_ls <- append(x, c(step_pattern_id = "symmetric1"))
        } else if (all(step_test == step_sym2)) {
          param_ls <- append(x, c(step_pattern_id = "symmetric2"))
        } else {
          param_ls <- append(x, c(step_pattern_id = NA))
        }

        return(param_ls)
      })
    } else {
      grid_final <- grid_initial
    }
  }


  grid_list <- purrr::map(alg_names, ~build_grid(.x)) %>%
    purrr::set_names(alg_names)

  return(grid_list)
}




