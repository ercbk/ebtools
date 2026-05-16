#' Estimate bufferNmax for spatio-temporal kriging neighborhood selection
#'
#' @description
#' Calculates an estimate for `bufferNmax` parameter used in
#' [gstat::krigeST()] local neighborhood selection. The estimate is based on
#' the average number of spatio-temporal observations within the effective range
#' of the joint variogram component, divided by `nmax`.
#'
#' All parameters must have the same distance and time units (e.g. kilometers, days) or have been generated using the same units. For example, `dist_spatial` and `dates` should have the same units as the units used to generate the `stani` value.
#'
#' Currently only generates `bufferNmax` estimates for spatio-temporal kriging models that utilize variogram models that contain a joint component.
#'
#' @param dates \[`Date`\] A vector of dates corresponding to the time dimension
#'   of the spatio-temporal data object.
#' @param coords \[`matrix`\] A numeric matrix of spatial coordinates with one
#'   row per location.
#' @param vario_mod \[`StVariogramModel`\] A fitted spatio-temporal variogram
#'   model of class `StVariogramModel` as returned by
#'   [gstat::fit.StVariogram()]. Must contain a `joint` component (i.e. a
#'   sum-metric or simple sum-metric model).
#' @param dist_spatial \[`matrix`\] A square numeric matrix of pairwise
#'   distances between all spatial locations.
#' @param nmax \[`numeric(1)`\] The maximum number of nearest neighbors used
#'   for kriging prediction. Must match the `nmax` value will be passed to
#'   [gstat::krigeST()] along with the `bufferNmax` estimate. See Details.
#' @param stani \[`numeric(1)`\] The spatio-temporal anisotropy parameter typically estimated using [gstat::estiStAni()].
#' @param samp_size \[`integer(1)`\] The number of spatio-temporal observation
#'   locations to sample when estimating the average neighborhood size.
#'   Larger values give more stable estimates at the cost of computation time.
#'   Default is `1000`.
#' @param seed \[`numeric(1)`\] Random seed for reproducibility of the
#'   sampling step. If `NULL` (the default), the seed is set to the current
#'   year derived from [Sys.Date()].
#' @param cor_level \[`numeric(1)`\] The correlation level at which the
#'   effective range of the joint variogram component is defined. Default is
#'   `0.01`, meaning the effective range is the distance at which the
#'   correlation drops to 0.01 (equivalently where the semivariance reaches
#'   99% of the sill). See Details.
#'
#' @return \[`numeric(1)`\] An estimate for `bufferNmax` to
#'   use as a starting point for grid search hyperparameter tuning of
#'   [gstat::krigeST()].
#'
#' @details
#' ## Why this function is useful
#'
#' [gstat::krigeST()] with local neighborhood selection requires two key
#' hyperparameters: `nmax` (the number of neighbors used for each prediction)
#' and `bufferNmax` (a multiplier controlling the size of the candidate pool
#' from which those neighbors are selected). While `nmax` can be chosen based
#' on domain knowledge and cross-validation without too much trouble, `bufferNmax` is harder to tune
#' because its role in algorithm is not obvious without understanding the
#' internal mechanics of [gstat::krigeST()]. Even then --- guessing an informative
#' range of values to start your search is nearly impossible unless you have extensive experience
#' with modeling data from that domain (k's upper bound is number of dates × number of locations).
#'
#' Internally, `krigeST.local` uses [FNN::get.knnx()] to find
#' `k = ceiling(bufferNmax * nmax)` nearest neighbors in the **combined**
#' spatio-temporal metric space (where time is rescaled by `stAni`). It then
#' evaluates the actual covariance between all `k` candidates and the
#' prediction location, keeping only the `nmax` with the strongest covariance.
#' If `bufferNmax` is too small, the candidate pool may not contain the truly
#' most correlated observations leading to suboptimal predictions.
#'
#' The `nmax` value should be obtained via cross-validation. Just use a 1, 2,
#' or 3 for `bufferNmax` and select the best `nmax` according to which model has
#' the lowest SSE. Then use that `nmax` value in this function.
#'
#' This function provides a principled estimate for `bufferNmax` so that an
#' empirical grid search can start from a informative value which allows for a
#' more efficient search.
#'
#' ## How the function works
#'
#' The function estimates `bufferNmax` in three steps:
#'
#' **Step 1: Compute the effective range of the joint variogram component.**
#' The effective range is defined as the distance at which the correlation of
#' the joint variogram component drops to `cor_level`. For a Matérn model this
#' is computed numerically using [stats::uniroot()] since there is no closed
#' form solution for all values of kappa. For a Spherical model the effective
#' range equals the range parameter exactly since the variogram reaches its
#' sill at that distance by definition. For an Exponential model the effective
#' range is also computed numerically. A `cor_level` of 0.01 (the default) is
#' used rather than the conventional 0.05 because `bufferNmax` needs to cast a
#' wide enough candidate net to capture all observations with any meaningful
#' covariance — not just those within the conventional effective range.
#'
#' **Step 2: Count spatio-temporal observations within the effective range.**
#' For a random sample of `samp_size` spatio-temporal observation locations,
#' the function computes the joint metric distance from each sampled location
#' to all other observations using:
#' \deqn{d_{ST} = \sqrt{d_S^2 + (d_T \times stAni)^2}}
#' where \eqn{d_S} is the spatial distance in kilometers and \eqn{d_T} is the
#' temporal distance in days scaled by `stAni` to convert to kilometers. The
#' number of observations within `joint_eff_range` is counted for each sampled
#' location and averaged across the sample.
#'
#' **Step 3: Derive `bufferNmax`.**
#' The average neighborhood size `k_est` is divided by `nmax` to give the
#' `bufferNmax` estimate. This result should be treated as a guess --- the true optimal
#' `bufferNmax` should be confirmed via a cross-validation grid search starting
#' with this estimate at the center of the grid.
#'
#' @seealso
#' * [gstat::krigeST()] for the kriging function this estimate is used with
#' * [gstat::fit.StVariogram()] for fitting spatio-temporal variogram models
#' * [gstat::estiStAni()] for estimating the spatio-temporal anisotropy
#'   parameter
#' * [Data Science Notebook >> Geospatial, Spatio-Temporal >> Kriging >> Interpolate](https://ercbk.github.io/Data-Science-Notebook/qmd/geospatial-spat-temp.html#sec-geo-sptemp-krig-inter) for details on `bufferNmax` and the rest of note for details on spatio-temporal kriging.
#'
#' @examples
#' \dontrun{
#' library(gstat)
#'
#' data(air, package = "spacetime")
#'
#' # get rural location time series from 2005 to 2010
#' rural_log <- spacetime::STFDF(
#'   sp = stations,
#'   time = dates,
#'   data = data.frame(PM10 = log(as.vector(air)))
#' )
#' rr <- rural_log[, "2005::2010"]
#'
#' # remove station ts w/all NAs
#' unsel <- which(apply(
#'   as(rr, "xts"),
#'   2,
#'   function(x) all(is.na(x)))
#' )
#' r5to10 <- rr[-unsel, ]
#'
#' coords_mat <- r5to10@sp@coords
#' all_dates <- as.Date(zoo::index(r5to10@time))
#'
#' # estimate stAni from marginal spatial variogram
#' space_vgm_mat <- vgm(
#'   model = "Mat",
#'   psill = 0.20,
#'   range = 110.83,
#'   nugget = 0.01,
#'   kappa = 0.40
#' )
#'
#' num_stani_mat <- estiStAni(
#'   empVgm = vario_emp, # computation not shown
#'   method = "metric",
#'   interval = c(1, 1000),
#'   spatialVgm = space_vgm_mat
#' )
#'
#' # compute pairwise spatial distance matrix in km
#' sf_locs <- sf::st_as_sf(r5to10@sp)
#' mat_dist_sf <- sf::st_distance(sf_locs)
#' dist_matrix <- mat_dist_sf |>
#'   units::set_units("km") |>
#'   units::drop_units() |>
#'   as.matrix()
#' rownames(dist_matrix) <- rownames(r5to10@sp@coords)
#' colnames(dist_matrix) <- rownames(r5to10@sp@coords)
#'
#' # estimate bufferNmax lower bound
#' est_buffernmax(
#'   dates = all_dates,
#'   coords = coords_mat,
#'   vario_mod = fit_vario_sm, # computation not shown
#'   dist_spatial = dist_matrix,
#'   nmax = 10,
#'   stani = num_stani_mat,
#'   samp_size = 1000,
#'   seed = NULL,
#'   cor_level = 0.01
#' )
#' }
#'
#' @export
est_buffernmax <- function(
    dates,
    coords,
    vario_mod,
    dist_spatial,
    nmax,
    stani,
    samp_size = 1000,
    seed = NULL,
    cor_level = 0.01
) {

  # --------- tests ---------

  chk::chk_date(dates)
  chk::chk_matrix(coords)
  chk::chk_numeric(coords)
  chk::chk_is(vario_mod, "StVariogramModel")
  chk::chk_matrix(dist_spatial)
  chk::chk_numeric(dist_spatial)
  chk::chk_number(nmax)
  chk::chk_whole_number(nmax)
  chk::chk_gt(nmax, 0)
  chk::chk_number(stani)
  chk::chk_gt(stani, 0)
  chk::chk_number(samp_size)
  chk::chk_whole_number(samp_size)
  chk::chk_gt(samp_size, 0)
  chk::chk_number(cor_level)
  chk::chk_range(cor_level, range = c(0, 1))
  if (!is.null(seed)) {
    chk::chk_number(seed)
    chk::chk_whole_number(seed)
  }
  chk::chk_true(nrow(dist_spatial) == nrow(coords))
  chk::chk_true(length(dates) == ncol(dist_spatial) || nrow(coords) == nrow(dist_spatial))

  vario_mod_comps <- names(vario_mod)
  if (!any("joint" %in% vario_mod_comps)) {
    stop("vario_mod does not contain a joint component")
  }
  if (nrow(dist_spatial) != ncol(dist_spatial)) {
    stop("dist_spatial must have the same number of rows and columns")
  }

  # -------------------------

  # calculate effective range from joint component of variogram model
  effective_range <- function(
    model,
    range_param,
    kappa = NULL,
    threshold = 0.99
  ) {
    vgm_obj <- if (model == "Mat") {
      gstat::vgm(psill = 1, model = model, range = range_param, kappa = kappa)
    } else {
      gstat::vgm(psill = 1, model = model, range = range_param)
    }

    sill <- sum(vgm_obj$psill)

    if (model == "Sph") {
      return(range_param)
    }

    # find distance where semivariance - threshold = 0
    # dividing by sill standardizes gamma to [0, 1] --- same as correlation
    eff_range <- stats::uniroot(
      f = \(d) {
        gstat::variogramLine(vgm_obj, dist_vector = d)$gamma / sill - threshold
      },
      interval = c(range_param * 0.001, range_param * 100)
    )$root

    return(eff_range)
  }

  joint_model_type <- as.character(vario_mod$joint$model[[2]])
  if (joint_model_type == "Mat") {
    joint_kappa <- vario_mod$joint$kappa[[2]]
  } else {
    joint_kappa <- NULL
  }
  joint_range <- vario_mod$joint$range[[2]]
  semi_var_threshold <- 1 - abs(cor_level)

  joint_eff_range <- effective_range(
    model = joint_model_type,
    range_param = joint_range,
    kappa = joint_kappa,
    threshold = semi_var_threshold
  )

  # calculate temporal "distance" matrix
  all_dates_numeric <- as.numeric(dates)
  dist_temporal <- abs(outer(all_dates_numeric, all_dates_numeric, "-"))
  dist_temporal_spatial <- dist_temporal * stani

  num_locs <- nrow(coords)
  num_dates <- length(all_dates_numeric)

  if (is.null(seed)) {
    date <- Sys.Date()
    seed <- as.integer(substr(date, start = 1, stop = 4))
  }
  set.seed(seed = seed)

  sample_obs <- sample(num_locs * num_dates, size = samp_size)
  sample_locations <- ((sample_obs - 1) %% num_locs) + 1
  sample_times <- ((sample_obs - 1) %/% num_locs) + 1

  # count number of spatio-temporal observations are within the joint effective range of each other
  # based on the observation's metric distance from other observations
  count_within_range <- purrr::map_dbl(
    seq_along(sample_obs),
    \(i) {
      s_dists <- dist_spatial[sample_locations[i], ]
      t_dists <- dist_temporal_spatial[sample_times[i], ]
      metric_dists <- sqrt(
        outer(s_dists^2, rep(1, num_dates)) +
          outer(rep(1, num_locs), t_dists^2)
      )
      sum(metric_dists <= joint_eff_range, na.rm = TRUE)
    }
  ) |>
    mean()

  k_est <- floor(count_within_range)
  bufferNmax_est <- k_est / nmax

  return(bufferNmax_est)
}
