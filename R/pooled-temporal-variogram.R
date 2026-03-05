#' Pooled Temporal Variogram
#'
#' Computes a pooled temporal variogram by holding space fixed and
#' pooling squared temporal differences across spatial locations.
#' Each row of `Y` is a spatial location and each column is a time point.
#'
#' @param Y A numeric space-time matrix. Rows are locations and columns are time points
#' The column names must either be character strings of dates (YYYY-MM-DD) or datetimes (YYYY-MM-DD hh-mm-ss)
#' @param max_lag Maximum index-based lag (regular time grid case).
#' @param max_time_diff Maximum time difference (irregular time grid case).
#' @param lag_unit is "secs", "mins", "hours", "days", or "weeks". If the time points are dates, then the default is "days". If the time points are datetimes (w/datetime = TRUE), then the default is "secs".
#' @param bin_width Width of temporal bins expressed in the same time units as lag_unit.
#' @param datetime is TRUE or FALSE (Default), It indicates whether the column names are dates (default) or datetimes.
#'
#' @details
#'
#' Let:
#' \eqn{Y_{s,t}} denote the observation at location \eqn{s = 1,\dots,S}
#' and time \eqn{t = 1,\dots,T}.
#'
#' For lag \eqn{u}, the unweighted pooled estimator (no missing values)
#' is:
#'
#' \deqn{
#' \hat{\gamma}(u)
#' =
#' \frac{1}{2 S (T-u)}
#' \sum_{s=1}^{S}
#' \sum_{t=1}^{T-u}
#' \left( Y_{s,t} - Y_{s,t+u} \right)^2
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{S} is number of spatial locations
#'   \item \eqn{T} is number of time points
#'   \item \eqn{u} is temporal separation
#' }
#'
#'
#' @return An object of class `StVariogram` and `data.frame`,
#'   compatible with `gstat::fit.variogram()`.
#'
#' @export
#'
#' @examples
#' Y <- matrix(
#'   c(
#'     10, 11, 15, 14, 13,   # location 1
#'     8,  9, 12, 11, 10,    # location 2
#'     5,  6,  8,  7,  9     # location 3
#'   ),
#'   nrow = 3,
#'   byrow = TRUE
#' )
#'
#' rownames(Y) <- c("loc1", "loc2", "loc3")
#'
#' # dates as column names
#' colnames(Y) <- as.character(seq.Date(
#'   as.Date("2023-01-01"),
#'   as.Date("2023-05-01"),
#'   by = "month"
#' ))
#'
#' Y
#'
#' pooled_temporal_variogram(
#'   Y = Y,
#'   max_time_diff = 100, # days
#'   bin_width = 30,      # days
#' )
#'
#'
#'
#' # datetimes as column names
#' colnames(Y) <- as.character(seq(
#'   as.POSIXct("2023-01-15 12:00:00"),
#'   by = "30 min",
#'   length.out = 5
#' ))
#'
#' pooled_temporal_variogram(
#'   Y = Y,
#'   max_time_diff = 500,  # minutes
#'   bin_width = 60,       # minutes
#'   lag_unit = "mins",
#'   datetime = TRUE
#' )




pooled_temporal_variogram <- function(
    Y,
    max_lag = NULL,
    max_time_diff = NULL,
    bin_width = 7,
    lag_unit = NULL,
    datetime = FALSE
) {

  # checks
  chk::chk_matrix(Y)
  chk::chk_numeric(bin_width)
  chk::chk_gt(bin_width, 0)

  if (is.null(colnames(Y)))
    stop("Column names must be dates or datetimes.")

  unk_time <- colnames(Y)

  # date or datetime
  if (datetime) {
    time_index <- as.POSIXct(unk_time, tz = "UTC")
    if (any(is.na(time_index)))
      stop("All column names must be valid POSIXct datetimes when datetime = TRUE.")
    if (is.null(lag_unit))
      lag_unit <- "secs"
  } else {
    time_index <- as.Date(unk_time)
    if (any(is.na(time_index)))
      stop("All column names must be valid Date values when datetime = FALSE.")
    if (is.null(lag_unit))
      lag_unit <- "days"
  }

  # order columns chronologically
  ord <- order(time_index)
  Y <- Y[, ord, drop = FALSE]
  time_index <- time_index[ord]

  # compute combinations
  combs <- utils::combn(ncol(Y), 2)
  i <- combs[1, ]
  j <- combs[2, ]

  time_diff <- as.numeric(
    difftime(time_index[j], time_index[i], units = lag_unit)
  )

  # apply lag constraints
  if (!is.null(max_lag)) {
    idx_lag <- (j - i) <= max_lag
  } else {
    idx_lag <- rep(TRUE, length(i))
  }

  if (!is.null(max_time_diff)) {
    idx_time <- time_diff <= max_time_diff
  } else {
    idx_time <- rep(TRUE, length(i))
  }

  keep <- idx_lag & idx_time

  i <- i[keep]
  j <- j[keep]
  time_diff <- time_diff[keep]

  if (length(i) == 0)
    stop("No valid time pairs under constraints.\nCheck the compatibility between units of max_time_diff and lag_unit")

  # bins
  breaks <- seq(0, max(time_diff) + bin_width, by = bin_width)
  bins <- cut(time_diff, breaks = breaks, include.lowest = TRUE, right = FALSE)

  # squared time diffs
  sqdiff <- (Y[, i, drop = FALSE] - Y[, j, drop = FALSE])^2

  # valid counts
  valid <- !is.na(sqdiff)
  n_pairs <- colSums(valid)
  sqdiff[!valid] <- 0

  # time difference pair-level summary
  pair_level_summary <- tibble::tibble(
    bin = bins,
    sqsum = colSums(sqdiff),
    np = n_pairs,
    time_diff = time_diff
  )

  # aggregate by bin (pooling by time)
  bin_level_summary <- pair_level_summary |>
    dplyr::filter(np > 0) |>
    dplyr::group_by(bin) |>
    dplyr::summarize(
      sqsum = sum(sqsum),
      np = sum(np),
      avgDist = mean(time_diff),
      .groups = "drop"
    )

  # all bin centers
  centers_all <- (breaks[-length(breaks)] + breaks[-1]) / 2

  out <- tibble::tibble(
    np = bin_level_summary$np,
    dist = centers_all[match(bin_level_summary$bin, levels(bins))],
    gamma = 0.5 * bin_level_summary$sqsum / bin_level_summary$np,
    id = "lag0",
    timelag = as.difftime(dist, units = lag_unit),
    spacelag = 0,
    avgDist = bin_level_summary$avgDist
  )

  class(out) <- c("StVariogram", "data.frame")
  attr(out, "boundaries") <- breaks

  return(out)
}
