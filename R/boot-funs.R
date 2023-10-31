#' Statistical Functions for Bootstrapping
#' Typically, the only change is the data <- data[ind, ] line and ind arg
#' @noRd

#' @param data Dataframe in wide format
#' @param ind Index used by {boot.ci}
#' @param group_variables List or character vector with names of the variables of interest
#' @param paired boolean; Indicates whether variables are repeated observations (i.e. within subject design)

cles_boot <- function(data, ind, group_variables, paired = FALSE) {

  data <- data[ind, ]

  group1 <- group_variables[[1]]
  group2 <- group_variables[[2]]
  # Select the observations for group 1
  # x <- data[data[[group]] == baseline, variable][[1]]
  x <- data[[group1]]
  # Select the observations for group 2
  # y <- data[data[[group]] != baseline, variable][[1]]
  y <- data[[group2]]

  # Variances will be weighted by each group's proportion of the sample size
  p1 <- length(x)/(length(x) + length(y))
  p2 <- length(y)/(length(x) + length(y))

  # Mean difference between x and y
  diff <- abs(mean(x) - mean(y))

  # Standard deviation of difference
  standardizer <- sqrt((p1*sd(x)^2 + p2*sd(y)^2))

  if (paired == FALSE) {
    z_score <- (diff/standardizer)/sqrt(2)
  } else {
    r <- cor(movie_dat)[[1,2]]
    s_diff <- sqrt((sd(x)^2 + sd(y)^2)-(2 * r * sd(x) * sd(y)))
    z_score <- diff/s_diff
  }

  # Probability derived from normal distribution
  # that random x is higher than random y -
  # or in other words, that diff is larger than 0.
  prob_norm <- pnorm(z_score)

  # Return result
  return(prob_norm)

}
