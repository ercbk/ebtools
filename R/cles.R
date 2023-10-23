#' Calculates the Common Language Effect Size (CLES)
#'
#' @description
#' Calculates the Common Language Effect Size (CLES) for two variables. The CLES function converts the effect size to a probability that a unit/subject will have a larger measurement than another unit/subject. See [notebook](https://ercbk.github.io/Data-Science-Notebook/qmd/post-hoc-analysis-multilevel.html#common-language-effect-size) for further details.
#'
#' @param data dataframe; Data should be in long format
#' @param variable numeric vector; Variable of interest
#' @param group string; The name of group variable
#' @param baseline string; The name of the category of the group variable that's the control group or baseline in a repeated measure scenario.
#'
#' @return
#' The function returns a scalar value.
#'
#' @details
#' This measure is also referred to as the _Probability of Superiority_. The conversion of effect size to a probability or percentage is supposed to be easier for the laymen to interpret.
#' Interpretation:
#'    - Between-Subjects: The probability that a randomly sampled person from one group will have a higher observed measurement than a randomly sampled person from the other group.
#'    - Within-Subjects: The probability that an individual has a higher value on one measurement than the other.
#'
#' Formula:
#' \deqn{\tilde d = \frac{|M_1 - M_2|}{\sqrt{p_1\text{SD}_1^2 + p_2\text{SD}_2^2}}\\ Z = \frac{\tilde d}{\sqrt{2}}}
#'
#'    - \eqn{M_i}: The mean of the i<sup>th</sup> group
#'    - \eqn{p_i}: The proportion of the sample size of the i<sup>th</sup> group
#'    - \eqn{Z}: The z-score which is in turn used to produce the probability.
#'    - Same formula is used for both within and between designs
#' @references
#' McGraw, K. O., & Wong, S. P. (1992). A common language effect size statistic. Psychological Bulletin, 111(2), 361–365. <https://doi.org/10.1037/0033-2909.111.2.361>
#'
#' @export
#'
#' @examples
#'
#' movie_dat <- dplyr::tibble(
#'    movie1 = c(9.00, 7.00, 8.00, 9.00, 8.00, 9.00, 9.00, 10.00, 9.00, 9.00),
#'    movie2 = c(9.00, 6.00, 7.00, 8.00, 7.00, 9.00, 8.00, 8.00, 8.00, 7.00)
#' )
#'
#' movie_dat |>
#'  tidyr::pivot_longer(cols = c(movie1, movie2),
#'                      names_to = "movies",
#'                      values_to ="ratings") |>
#'  cles("ratings", "movies", "movie1")




cles <- function(data, variable, group, baseline) {

  # Select the observations for group 1
  x <- data[data[[group]] == baseline, variable][[1]]

  # Select the observations for group 2
  y <- data[data[[group]] != baseline, variable][[1]]

  # Variances will be weighted by each group's proportion of the sample size
  p1 <- length(x)/(length(x) + length(y))
  p2 <- length(y)/(length(x) + length(y))

  # Mean difference between x and y
  diff <- abs(mean(x) - mean(y))

  # Standard deviation of difference
  standardizer <- sqrt((p1*sd(x)^2 + p2*sd(y)^2))

  z_score <- (diff/standardizer)/sqrt(2)

  # Probability derived from normal distribution
  # that random x is higher than random y -
  # or in other words, that diff is larger than 0.
  prob_norm <- pnorm(z_score)

  # Return result
  return(prob_norm)

}
