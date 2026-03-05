# Calculates bootstrapped confidence intervals for a statistic

`get_boot_ci()` wraps `boot` and `boot.ci` from the
[boot](https://cran.r-project.org/web/packages/boot/index.html) package,
uses some sensible argument values, and returns a dataframe with a
confidence interval(s) and the point estimate.

## Usage

``` r
get_boot_ci(
  data,
  stat_fun,
  conf = 0.95,
  type = "bca",
  R = 1000,
  parallel = "windows",
  add_boot = NULL,
  add_boot_ci = NULL,
  ...
)
```

## Arguments

- data:

  dataframe; Data with the variables required by the function that
  calculates the statistic of interest.

- stat_fun:

  function; A function that calculates the statistic of interest.

- conf:

  scalar or numeric vector; The confidence level(s) of the required
  interval(s).The default is 0.95.

- type:

  string or character vector; A vector of character strings representing
  the type of intervals required. The value should be any subset of the
  values c("norm","basic", "stud", "perc", "bca") or simply "all" which
  will compute all five types of intervals. Default is "bca".

- R:

  scalar; The number of bootstrap replicates on which the intervals are
  based. 1000 is the default.

- parallel:

  string; The value that's either "windows", "other", or "no". The type
  of operating system determines the method of parallelization.
  "windows" is the default and indicates Microsoft Windows. For Mac or
  Linux, "other" should be used. "no" indicates calculations should not
  be parallelized.

- add_boot:

  list; A list of additional argument and value pair(s) to be included
  in the `boot` set of arguments. See the
  [boot](https://cran.r-project.org/web/packages/boot/index.html)
  package documentation for details.

- add_boot_ci:

  list; A list of additional argument and value pair(s) to be included
  in the `boot.ci` set of arguments. See the
  [boot](https://cran.r-project.org/web/packages/boot/index.html)
  package documentation for details.

- ...:

  Arguments and values required by 'stat_fun'

## Value

A dataframe with the following columns:

- type: The type of confidence interval calculated

- conf: The confidence level of the calculated intervals

- .lower: The lower value of the confidence interval

- .upper: The upper value of the confidence interval

The point estimate of the statistic is included in the attributes of the
dataframe.

## Details

The `boot` and `boot.ci` functions from the boot package have a large
number of options (together), and it can be a bit overwhelming when you
just want some bootstrap CIs quickly. I've tried to simplify the choices
with this function while also maintaining flexibility to add options for
more complex cases.

The user must adapt the function they're using to calculate the
statistic of interest ('stat_fun') to include the necessary argument
according the chosen resampling option. The default resampling option is
"indices" ('stype = "i"'), and it's the only one I'm going to elaborate
on (See examples for "weights" option. See
[boot](https://cran.r-project.org/web/packages/boot/index.html) package
documentation for details on the "frequency" option). In order to use
this option, the user must:

1.  Include a index argument in their statistic function, and it must be
    the second argument (data argument is the first).

2.  Use that argument to either subset the rows of the data or
    variable(s) in the body of the function.

Examples below will illustrate this procedure.

## References

Canty A, Ripley BD (2022). boot: Bootstrap R (S-Plus) Functions. R
package version 1.3-28.1.

Davison AC, Hinkley DV (1997). Bootstrap Methods and Their Applications.
Cambridge University Press, Cambridge. ISBN 0-521-57391-2,
<http://statwww.epfl.ch/davison/BMA/>.

## Examples

``` r
# weights resampling option, d is the data, w is the weight
data(city, package = "boot")
ratio <- function(d, w) sum(d$x * w)/sum(d$u * w)
get_boot_ci(
  data = city,
  stat_fun = ratio,
  add_boot = list(stype = "w")
)
#>   type conf .lower .upper
#> 1  bca 0.95 1.2588 2.1934

# indices used on variable example, d is data, i is index
data(aircondit, package = "boot")
mean.fun <- function(d, i) {
  m <- mean(d$hours[i])
  n <- length(i)
  v <- (n-1)*var(d$hours[i])/n^2
  c(m, v)
}
get_boot_ci(
  data = aircondit,
  stat_fun = mean.fun,
)
#>   type conf  .lower  .upper
#> 1  bca 0.95 55.8018 222.526

# indices used on data object example
movie_dat <- dplyr::tibble(
  movie1 = c(9.00, 7.00, 8.00, 9.00, 8.00, 9.00, 9.00, 10.00, 9.00, 9.00),
  movie2 = c(9.00, 6.00, 7.00, 8.00, 7.00, 9.00, 8.00, 8.00, 8.00, 7.00)
)

movie_dat_long <- movie_dat |>
 tidyr::pivot_longer(cols = c(movie1, movie2),
                     names_to = "movies",
                     values_to ="ratings")

# "ind" is the index argument and is used to subset the data
cles_boot <- function(data, ind, variable, group, baseline) {

  dat <- data[ind, ]

  # Select the observations for group 1
  x <- dat[dat[[group]] == baseline, variable][[1]]

  # Select the observations for group 2
  y <- dat[dat[[group]] != baseline, variable][[1]]

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

results <-
   get_boot_ci(
     data = movie_dat_long,
     stat_fun = cles_boot,
     type = c("perc", "bca"),
     conf = c(0.80, 0.95),
     parallel = "no",
     variable = "ratings",
     group = "movies",
     baseline = "movie1"
   )
results
#>      type conf .lower .upper
#> 1 percent 0.80 0.6527 0.9083
#> 2 percent 0.95 0.5609 0.9605
#> 3     bca 0.80 0.6115 0.8879
#> 4     bca 0.95 0.5256 0.9330
attributes(results)$estimate
#> [1] 0.7870181
```
