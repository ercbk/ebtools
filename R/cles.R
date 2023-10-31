#' Calculates the Common Language Effect Size (CLES)
#'
#' @description
#' Calculates the Common Language Effect Size (CLES) for two variables. The CLES function converts the effect size to a probability that a unit/subject will have a larger measurement than another unit/subject. See [notebook](https://ercbk.github.io/Data-Science-Notebook/qmd/post-hoc-analysis-multilevel.html#common-language-effect-size) for further details.
#'
#' @param data dataframe; Data should be in wide format
#' @param group_variables character vector or list with quoted names of the variables to be compared.
#' @param paired boolean; Indicates whether variables are correlated as in a repeated measures design. Default is FALSE.
#' @param ci boolean; Indicates whether bootstrap confidence intervals should be calculated. Default is FALSE.
#' @param ... Additional arguments that should be passed to [get_boot_ci]
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
#' Between-Subjects Formula:
#' \deqn{\tilde d = \frac{|M_1 - M_2|}{\sqrt{p_1\text{SD}_1^2 + p_2\text{SD}_2^2}}\\ Z = \frac{\tilde d}{\sqrt{2}}}
#'
#'    - \eqn{M_i}: The mean of the i<sup>th</sup> group
#'    - \eqn{p_i}: The proportion of the sample size of the i<sup>th</sup> group
#'    - \eqn{Z}: The z-score which is in turn used to produce the probability.
#'
#' Within-Subjects Formula:
#' \deqn{Z = \frac{|M_1 - M_2|}{sqrt{\operatorname{SD}_1^2 + \operatorname{SD}_2^2 - 2 \times r \times \operatorname{SD}_1 \times \operatorname{SD}_2}}}
#'
#'    - \eqn{M_i}: The mean of the i<sup>th</sup> group
#'    - \eqn{r}: Pearson correlation between the two variables
#'    - \eqn{Z}: The z-score which is in turn used to produce the probability.
#'
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
#' # between-subjects design
#' cles(data = movie_dat,
#'     group_variables = list("movie1", "movie2"))
#'
#' # within-subjects design and bootstrap CIs
#' cles(data = movie_dat,
#'      group_variables = list("movie1", "movie2"),
#'      paired = TRUE,
#'      ci = TRUE,
#'      R = 10000,
#'      type = c("bca", "perc"))




cles <- function(data,
                 group_variables,
                 paired = FALSE,
                 ci = FALSE,
                 ...) {

  # If bootstrap cis are wanted, call get_boot_ci
  if (ci == TRUE) {
    # Check if dots used. if so, include them in get_boot_ci args.
    if (chk::vld_used(...)) {
      dots <- list(...)
      init_boot_args <-
        list(data = data,
             stat_fun = cles_boot, # internal function
             group_variables = group_variables,
             paired = paired)
      get_boot_args <-
        append(init_boot_args,
               dots)
    } else {
      get_boot_args <-
        list(data = data,
             stat_fun = cles_boot,
             group_variables = group_variables,
             paired = paired)
    }

    cles_booted <-
      do.call(
        get_boot_ci,
        get_boot_args
      )
    # Create a df with CIs and estimate; rename and reorder columns
    cles_df <- data.frame(
      .estimate = rep(attributes(cles_booted)$estimate, nrow(cles_booted))
    )
    cles_df <- cbind(cles_df, cles_booted)
    cles_df <- cles_df[, c(2,3,4,1,5)]
    names(cles_df)[1] <- "ci_type"
    return(cles_df)
  }

  group1 <- group_variables[[1]]
  group2 <- group_variables[[2]]

  # Select the observations for group 1
  x <- data[[group1]]
  # Select the observations for group 2
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
