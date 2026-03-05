# Calculates the Common Language Effect Size (CLES)

Calculates the Common Language Effect Size (CLES) for two variables. The
CLES function converts the effect size to a probability that a
unit/subject will have a larger measurement than another unit/subject.
See my [Post-Hoc Analysis,
Multilevel](https://ercbk.github.io/Data-Science-Notebook/qmd/post-hoc-analysis-multilevel.html#common-language-effect-size)
note in my Data Science notebook for further details.

## Usage

``` r
cles(data, group_variables, paired = FALSE, ci = FALSE, ...)
```

## Arguments

- data:

  dataframe; Data should be in wide format

- group_variables:

  character vector or list with quoted names of the variables to be
  compared.

- paired:

  boolean; Indicates whether variables are correlated as in a repeated
  measures design. Default is FALSE.

- ci:

  boolean; Indicates whether bootstrap confidence intervals should be
  calculated. Default is FALSE.

- ...:

  Additional arguments that should be passed to
  [`get_boot_ci()`](https://ercbk.github.io/ebtools/reference/get_boot_ci.md)

## Value

When 'ci = FALSE', this function returns a scalar value estimate of the
CLES. When 'ci = TRUE', this function returns a dataframe with the
following columns:

- ci_type: The method of calculating the bootstrap confidence intervals.

- conf: The confidence level for the bootstrap confidence intervals,

- .lower: The lower value of the bootstrap confidence interval.

- .estimate: The CLES point estimate.

- .upper: The upper value of the bootstrap confidence interval.

## Details

This measure is also referred to as the *Probability of Superiority*.
The conversion of effect size to a probability or percentage is supposed
to be easier for the laymen to interpret. Interpretation:

- Between-Subjects: The probability that a randomly sampled person from
  one group will have a higher observed measurement than a randomly
  sampled person from the other group.

- Within-Subjects: The probability that an individual has a higher value
  on one measurement than the other.

Between-Subjects Formula: \$\$\tilde d = \frac{\|M_1 -
M_2\|}{\sqrt{p_1\text{SD}\_1^2 + p_2\text{SD}\_2^2}}\\ Z = \frac{\tilde
d}{\sqrt{2}}\$\$

- \\M_i\\: The mean of the i^(th) group

- \\p_i\\: The proportion of the sample size of the i^(th) group

- \\Z\\: The z-score which is in turn used to produce the probability.

Within-Subjects Formula: \$\$Z = \frac{\|M_1 -
M_2\|}{\sqrt{\operatorname{SD}\_1^2 + \operatorname{SD}\_2^2 - 2 \times
r \times \operatorname{SD}\_1 \times \operatorname{SD}\_2}}\$\$

- \\M_i\\: The mean of the i^(th) group

- \\r\\: Pearson correlation between the two variables

- \\Z\\: The z-score which is in turn used to produce the probability.

## References

McGraw, K. O., & Wong, S. P. (1992). A common language effect size
statistic. Psychological Bulletin, 111(2), 361–365.
<https://doi.org/10.1037/0033-2909.111.2.361>

## Examples

``` r
movie_dat <- dplyr::tibble(
   movie1 = c(9.00, 7.00, 8.00, 9.00, 8.00, 9.00, 9.00, 10.00, 9.00, 9.00),
   movie2 = c(9.00, 6.00, 7.00, 8.00, 7.00, 9.00, 8.00, 8.00, 8.00, 7.00)
)

# between-subjects design
cles(data = movie_dat,
     group_variables = list("movie1", "movie2"))
#> [1] 0.7870181

# within-subjects design and bootstrap CIs
cles(data = movie_dat,
     group_variables = list("movie1", "movie2"),
     paired = TRUE,
     ci = TRUE,
     R = 10000,
     type = c("bca", "perc"))
#>   ci_type conf .lower .estimate .upper
#> 1 percent 0.95 0.8080 0.9331928 0.9997
#> 2     bca 0.95 0.7602 0.9331928 0.9964
```
