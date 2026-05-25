# Format columns and optionally highlight values

Applies
[`smart_fmt_sci()`](https://ercbk.github.io/ebtools/reference/smart_fmt_sci.md)
to specified columns of a data frame for human-readable formatting, with
an optional step to highlight values meeting a condition using
[`emphatic::hl()`](https://coolbutuseless.github.io/package/emphatic/reference/hl.html).
This is particularly useful for variables with a wide range of small
values where some require scientific notation but others do not, such as
p-values. The defaults are designed for p-values.

## Usage

``` r
fmt_hl(.data, fmt_cols, emphatic = FALSE, hl_spec = NULL, elem = "text", ...)
```

## Arguments

- .data:

  [`data.frame()`](https://rdrr.io/r/base/data.frame.html) A data frame
  or tibble.

- fmt_cols:

  [`character()`](https://rdrr.io/r/base/character.html) Columns to
  apply
  [`smart_fmt_sci()`](https://ercbk.github.io/ebtools/reference/smart_fmt_sci.md)
  formatting to. This name can be quoted ("p_value") or unquoted
  (p_value) or a vector of quoted or unquoted names. Also, supports tidy
  selection (e.g. `dplyr::starts_with("p_")`).

- emphatic:

  `logical(1)` Whether to apply
  [`emphatic::hl()`](https://coolbutuseless.github.io/package/emphatic/reference/hl.html)
  highlighting. Defaults to `FALSE`.

- hl_spec:

  [`list()`](https://rdrr.io/r/base/list.html) or `NULL`. A list of
  lists where each list specifies the
  [`emphatic::hl()`](https://coolbutuseless.github.io/package/emphatic/reference/hl.html)
  highlighting parameters for one column. Each inner list must contain:

  `col`

  :   `character(1)` Name of the column to highlight.

  `palette`

  :   `character(1)` A string with the color name or a ggplot2
      *discrete* scale *class* object to use for highlighting. Can be a
      single color string (e.g. `"red"`), a vector of color strings, or
      a ggplot2 scale object (e.g.
      [`ggplot2::scale_color_viridis_d()`](https://ggplot2.tidyverse.org/reference/scale_viridis.html),
      `scico::scale_color_scico_d()`, etc.).

  `rows`

  :   `character(1)` A string logical expression evaluated against the
      data frame to select rows to highlight (e.g. `"p_value < 0.05"`).

  `elem`

  :   `character(1)` Whether to highlight `"fill"` (background) or
      `"text"`. Overrides the top-level `elem` argument for this column.

  If `NULL` (the default), a default spec is generated from `fmt_cols`
  using `palette = "red"`, `rows = "<col> < 0.05"`, and the top-level
  `elem`.

- elem:

  `character(1)` Default highlight element for all columns, either
  `"fill"` for background or `"text"` for text color. Can be overridden
  per column in `hl_spec`. Defaults to `"text"`.

- ...:

  Additional arguments passed to
  [`smart_fmt_sci()`](https://ercbk.github.io/ebtools/reference/smart_fmt_sci.md),
  such as `threshold`, `sci_digits`, and `num_digits`.

## Value

If `emphatic = FALSE`, the input data frame or tibble with the specified
columns formatted as
[`character()`](https://rdrr.io/r/base/character.html) via
[`smart_fmt_sci()`](https://ercbk.github.io/ebtools/reference/smart_fmt_sci.md)
is returned. If `emphatic = TRUE`, an `emphatic` object with formatting
and highlighting applied is returned — suitable for printing to the
console or rendering in a document.

## Details

This function is useful when working with variables that span a wide
range of small values, such as p-values, where some values require
scientific notation and others do not. Formatting with
[`smart_fmt_sci()`](https://ercbk.github.io/ebtools/reference/smart_fmt_sci.md)
ensures consistent, readable output. The optional
[`emphatic::hl()`](https://coolbutuseless.github.io/package/emphatic/reference/hl.html)
highlighting makes it easy to visually flag values meeting a condition,
such as p-values below 0.05.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- data.frame(
  type = letters[1:6],
  p_value = c(0.532, 0.00000012, 0.041, 0.00000000031, 0.078, 0.023),
  p_value_adj = c(0.532, 0.00000072, 0.123, 0.00000000186, 0.234, 0.138)
)

# Format only, no highlighting
df |> fmt_hl(fmt_cols = c(p_value, p_value_adj))
#>     type  p_value p_value_adj
#> 1      a    0.532       0.532
#> 2      b 1.20e-07    7.20e-07
#> 3      c    0.041       0.123
#> 4      d 3.10e-10    1.86e-09
#> 5      e    0.078       0.234
#> 6      f    0.023       0.138

# Format with default highlighting (red text where < 0.05)
# df |> fmt_hl(fmt_cols = c(p_value, p_value_adj), emphatic = TRUE)

# Format with custom hl_spec
df |>
  fmt_hl(
    fmt_cols = dplyr::starts_with("p_"),
    emphatic = TRUE,
    hl_spec = list(
      list(
        col = "p_value_adj",
        palette = ggplot2::scale_color_viridis_d(),
        rows = "p_value_adj < 0.05 & p_value_adj > 0",
        elem = "fill"
      ),
      list(
        col = "p_value",
        palette = "red",
        rows = "p_value < 0.05",
        elem = "text"
      )
    )
  )
#>     type  p_value p_value_adj
#> 1      a    0.532       0.532
#> 2      b 1.20e-07    7.20e-07
#> 3      c    0.041       0.123
#> 4      d 3.10e-10    1.86e-09
#> 5      e    0.078       0.234
#> 6      f    0.023       0.138
} # }
```
