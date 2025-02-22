#' Add Spatial Lags of a Variable to a Dataset
#'
#' @description
#' Computes spatial lags for a given numeric variable in a dataset using
#' a neighborhood list from the [spdep](https://r-spatial.github.io/spdep/) package. It supports inverse distance weighting, exponential, and double power decay weighting methods along with various normalization procedures.
#'
#' @param nblist An object of class "nb" from the spdep package which represents the neighborhood structure.
#' @param y A character string indicating the name of the numeric variable in `.data`
#'   for which spatial lags will be computed.
#' @param .data A data frame of class "sf" containing the variable specified by `y`.
#' @param lags A numeric value specifying the number of spatial lags to compute.
#' @param type A character string indicating the type of spatial weights to use.
#'   Accepted values are `"idw"` (inverse distance weighting), `"exp"` (exponential),
#'   `"dpd"` (double power decay), or `NULL` (default), which applies standard
#'   adjacency-based weighting.
#' @param parallel (default: FALSE) Logical indicating whether to use parallel processing.
#'   Requires having purrr (>= 1.0.4.9000) installed, [mirai (>= 2.1.0.9000)](https://shikokuchuo.net/mirai/) package installed and loaded, and setting `mirai::daemons()` to the number of desired processes. (See Examples)
#' @param ... Additional arguments passed to `spdep::nb2listw()` or `spdep::nb2listwdist()`,
#'   such as the `style` argument specifying the normalization method or `zero-policy` which indicates whether or not to permit the weights list to be formed with zero-length weights vectors.
#'
#' @return A tibble containing the original dataset with additional columns for each
#'   computed spatial lag. The spatial lag columns are named `"spatlag_<lag>_<y>"`.
#'   The output also includes weight summary attributes named `"summ_wgts_spatlag_<lag>"`.
#'
#' @details
#' To obtain a neighborhood list of class "nb," first, a neighborhood algorithm is fit to the geometry of sf dataset. Then, that object is coerced into a neighborhood list. For a workflow, see the Misc section in the [Geospatial, Spatial Weights](https://ercbk.github.io/Data-Science-Notebook/qmd/geospatial-spatial-weights.html#sec-geo-swgt-misc) note of my Data Science notebook.
#' - Valid Types: (`"idw"`, `"exp"`, `"dpd"`).
#' - Valid Styles: (`"W"`, `"B"`, `"C"`, `"S"`, `"U"`, `"minmax"`, `"raw"`).
#' - See the Spatial Weights section in the [Geospatial, Spatial Weights](https://ercbk.github.io/Data-Science-Notebook/qmd/geospatial-spatial-weights.html#sec-geo-swgt-swts) note of my Data Science notebook for details
#'
#' The spatial weights summary is extracted from the output of printing the `spdep::nb2listw` or `spdep::nb2listwdist` object. It contains characteristics such as the number of regions, number of nonzero links, percentage of nonzero weights, average number of links.
#' - n: This refers to the number of regions (or spatial units) in your dataset.
#' - nn: This refers to the total number of possible pairwise relationships between the regions. It is calculated as n × n. This represents the total number of possible links if every region were connected to every other region, including itself.
#' - S0: This is the sum of all weights.
#' - S1: This is related to the sum of the squares of the weights.
#' - S2: This is related to the sum of the products of the weights for each pair of neighbors.
#' - S0, S1, S2 are constants used in inference for global spatial autocorrelation statistics
#'
#' @importFrom chk chk_s3_class chk_character chk_subset chk_numeric
#' @importFrom spdep nb2listw nb2listwdist nblag lag.listw
#' @importFrom tibble tibble
#' @importFrom purrr map2 map list_cbind list_flatten reduce2
#' @importFrom dplyr bind_cols relocate
#' @importFrom rlang list2
#'
#' @export
#'
#' @examples
#'
#' library(spdep, quietly = TRUE)
#'
#' ny8_sf <-
#'   st_read(system.file(
#'     "shapes/NY8_bna_utm18.gpkg",
#'     package = "spData"),
#'     quiet = TRUE)
#'
#' dplyr::glimpse(ny8_sf)
#'
#' ny8_ct_sf <-
#'   st_centroid(st_geometry(ny8_sf),
#'               of_largest_polygon = TRUE)
#'
#'
#' ny88_nb_sf <-
#'   knn2nb(knearneigh(ny8_ct_sf,
#'                     k = 4))
#'
#' # Compute spatial lags
#' tib_spat_lags <-
#'   add_spatial_lags(
#'     nblist = ny88_nb_sf,
#'     y = "PCTOWNHOME",
#'     .data = ny8_sf,
#'     lags = 2,
#'     type = "dpd",
#'     dmax = 25000,
#'     style = "W",
#'     zero.policy = TRUE
#'   )
#'
#' tib_spat_lags |>
#'   dplyr::select(PCTOWNHOME,
#'                 spatlag_1_PCTOWNHOME,
#'                 spatlag_2_PCTOWNHOME) |>
#'   dplyr::glimpse()
#'
#' cat(attributes(tib_spat_lags)$summ_wgts_spatlag_1, sep = "\n")
#'
#' rlang::check_installed(
#'   "mirai (>= 2.1.0.9000)",
#'   action = function(...) {
#'     remotes::install_version('mirai',
#'                              version = ">= 2.1.0.9000",
#'                              repos = c('https://shikokuchuo.r-universe.dev',
#'                                        'https://cloud.r-project.org'))
#'   }
#' )
#'
#' library(mirai)
#'
#' daemons(2)
#'
#' tib_spat_lags_para <-
#'   add_spatial_lags(
#'     nblist = ny88_nb_sf,
#'     y = "PCTOWNHOME",
#'     .data = ny8_sf,
#'     lags = 2,
#'     type = "exp",
#'     zero.policy = TRUE,
#'     parallel = TRUE
#'   )
#'
#' daemons(0)


add_spatial_lags <- function(nblist,
                             y,
                             .data,
                             lags,
                             type = NULL,
                             parallel = FALSE,
                             ...) {

  # ---------------- tests ------------------
  # Check if nblist is of class "nb"
  chk::chk_s3_class(nblist, "nb")

  # Check if y is a character
  chk::chk_character(y)
  accepted_y <- colnames(.data)
  # Check that y is in the data
  chk::chk_subset(y, accepted_y, x_name = "y")
  # Check if y in .data and lags is numeric
  chk::chk_numeric(.data[[y]])
  chk::chk_numeric(lags)

  # Define accepted values for type and style
  accepted_types <- c("idw", "exp", "dpd")
  accepted_styles <- c("W", "B", "C", "S", "U", "minmax", "raw")
  # Check if type is not NULL, then validate
  if (!is.null(type)) {
    chk::chk_subset(type, accepted_types, x_name = "type")
  }
  # Extract ... arguments as a list
  dots <- list(...)
  # Check if "style" is provided in ... and validate
  if ("style" %in% names(dots)) {
    chk::chk_subset(dots$style, accepted_styles, x_name = "style")
  }
  # -----------------------------------------

  get_vec_lags <- function(lag_nb, vec_num, .data, lag, type, ...) {

    # add weights to nb list
    if (is.null(type)) {
      ls_wts <-
        spdep::nb2listw(lag_nb, ...)
    } else {
      ls_wts <-
        spdep::nb2listwdist(lag_nb, .data, type, ...)
    }

    # get weights summary
    summ_wts <- utils::capture.output(spdep:::print.listw(ls_wts))

    # create spatial lag of vector
    vec_lag <-
      spdep::lag.listw(ls_wts, vec_num)
    tib_lag <-
      tibble::tibble("spatlag_{lag}_{y}" := vec_lag)

    # list names
    name_ls_summ <- paste("summ_wgts_spatlag", lag, sep = "_")
    name_tib_lag <- paste("tib_lag", lag, sep = "_")

    # purrr::list_cbind doesn't retain tibble attributes so
    # applying wgt summary attributes to tib later
    ls_res <- rlang::list2(
      !!name_ls_summ := summ_wts,
      !!name_tib_lag := tib_lag
    )

    return(ls_res)

  }

  # subset variable
  vec_num <- .data[[y]]
  # neighbor lags
  lags_nb <- spdep::nblag(nblist, maxlag = lags)

  # get spatial lags and weight summaries
  if (parallel == TRUE) {

    dots <- list(...)

    ls_lags_summ <-
      purrr::map2(
        lags_nb,
        1:lags,
        carrier::crate(
          \(x1, x2) {
            get_vec_lags(
              x1,
              !!vec_num,
              !!.data,
              x2,
              !!type,
              !!!dots
            )
          },
          get_vec_lags = get_vec_lags
        ),
        .parallel = TRUE
      )

  } else {

    ls_lags_summ <-
      purrr::map2(
        lags_nb,
        1:lags,
        \(x1, x2) {
          get_vec_lags(
            x1,
            vec_num,
            .data,
            x2,
            type,
            ...
          )
        }
      )

  }

  # pull spatial lags and bind to data
  tib_lags <-
    purrr::map(ls_lags_summ, \(x) purrr::pluck(x, 2)) |>
    purrr::list_cbind() |>
    dplyr::bind_cols(.data) |>
    dplyr::relocate({{y}})

  # pull weight summaries
  ls_summ_wgts <-
    purrr::map(ls_lags_summ, \(x) x[1]) |>
    purrr::list_flatten()

  # add weight summaries as attributes
  tib_lags <- purrr::reduce2(
    names(ls_summ_wgts),
    ls_summ_wgts,
    .init = tib_lags,
    .f = function(obj, name, value) {
      attr(obj, name) <- value
      obj
    }
  )

  return(tib_lags)
}
