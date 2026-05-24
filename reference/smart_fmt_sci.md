# Format numbers using smart scientific notation

Formats numeric values by applying scientific notation only when values
fall below a specified threshold, and fixed notation otherwise. This is
useful for variables with a wide range of small values where some
require scientific notation but others do not, such as p-values. The
defaults are designed for p-values.

## Usage

``` r
smart_fmt_sci(x, threshold = 1e-04, sci_digits = 2, num_digits = 4)
```

## Arguments

- x:

  [`numeric()`](https://rdrr.io/r/base/numeric.html) A numeric vector to
  format.

- threshold:

  `numeric(1)` Values with absolute value below this threshold are
  formatted in scientific notation. Defaults to `0.0001`.

- sci_digits:

  `integer(1)` Number of significant digits for values formatted in
  scientific notation. Defaults to `2`.

- num_digits:

  `integer(1)` Number of significant digits for values formatted in
  fixed notation. Defaults to `4`.

## Value

[`character()`](https://rdrr.io/r/base/character.html) A character
vector of formatted numbers.

## Details

Uses [`formatC()`](https://rdrr.io/r/base/formatc.html) internally with
`format = "e"` for scientific notation and `format = "fg"` for fixed
notation. The `"fg"` format uses significant digits rather than decimal
places, giving consistent precision across values of different
magnitudes.

## Examples

``` r
if (FALSE) { # \dontrun{
x <- c(0.5, 0.0000001, 0.00032, 0.000000000123)

smart_fmt_sci(x)
#> [1] "0.5"      "1.00e-07" "0.00032"  "1.23e-10"

smart_fmt_sci(x, threshold = 0.001, sci_digits = 3, num_digits = 6)
#> [1] "0.5"       "1.000e-07" "3.200e-04" "1.230e-10"
} # }
```
