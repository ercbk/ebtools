#' Format numbers using smart scientific notation
#'
#' @description
#' Formats numeric values by applying scientific notation only when values fall
#' below a specified threshold, and fixed notation otherwise. This is useful for
#' variables with a wide range of small values where some require scientific
#' notation but others do not, such as p-values. The defaults are designed for
#' p-values.
#'
#' @param x `numeric()` A numeric vector to format.
#' @param threshold `numeric(1)` Values with absolute value below this threshold
#'   are formatted in scientific notation. Defaults to `0.0001`.
#' @param sci_digits `integer(1)` Number of significant digits for values
#'   formatted in scientific notation. Defaults to `2`.
#' @param num_digits `integer(1)` Number of significant digits for values
#'   formatted in fixed notation. Defaults to `4`.
#'
#' @return `character()` A character vector of formatted numbers.
#'
#' @details
#' Uses [formatC()] internally with `format = "e"` for scientific notation and
#' `format = "fg"` for fixed notation. The `"fg"` format uses significant digits
#' rather than decimal places, giving consistent precision across values of
#' different magnitudes.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' x <- c(0.5, 0.0000001, 0.00032, 0.000000000123)
#'
#' smart_fmt_sci(x)
#' #> [1] "0.5"      "1.00e-07" "0.00032"  "1.23e-10"
#'
#' smart_fmt_sci(x, threshold = 0.001, sci_digits = 3, num_digits = 6)
#' #> [1] "0.5"       "1.000e-07" "3.200e-04" "1.230e-10"
#' }


smart_fmt_sci <- function(
    x,
    threshold = 0.0001,
    sci_digits = 2,
    num_digits = 4
) {

  # -------------- tests --------------

  chk::chk_numeric(x)
  chk::chk_number(threshold)
  chk::chk_number(sci_digits)
  chk::chk_number(num_digits)

  # -----------------------------------

  ifelse(
    abs(x) < threshold & x != 0,
    formatC(
      x,
      format = "e",
      digits = sci_digits
    ),
    formatC(
      x,
      format = "fg",
      digits = num_digits
    )
  ) |>
    trimws(which = "both")
}


#' Format columns and optionally highlight values
#'
#' @description
#' Applies [smart_fmt_sci()] to specified columns of a data frame for
#' human-readable formatting, with an optional step to highlight values meeting
#' a condition using [emphatic::hl()]. This is particularly useful for variables
#' with a wide range of small values where some require scientific notation but
#' others do not, such as p-values. The defaults are designed for p-values.
#'
#' @param .data `data.frame()` A data frame or tibble.
#' @param fmt_cols `character()` Columns to apply [smart_fmt_sci()] formatting
#'   to. This name can be quoted ("p_value") or unquoted (p_value) or a vector of quoted
#'   or unquoted names. Also, supports tidy selection (e.g. `dplyr::starts_with("p_")`).
#' @param emphatic `logical(1)` Whether to apply [emphatic::hl()] highlighting.
#'   Defaults to `FALSE`.
#' @param hl_spec `list()` or `NULL`. A list of lists where each list specifies
#'   the [emphatic::hl()] highlighting parameters for one column. Each inner list must contain:
#'   \describe{
#'     \item{`col`}{`character(1)` Name of the column to highlight.}
#'     \item{`palette`}{`character(1)` A string with the color name or a ggplot2 *discrete* scale *class* object to use
#'       for highlighting. Can be a single color string (e.g. `"red"`), a
#'       vector of color strings, or a ggplot2 scale object (e.g.
#'       `ggplot2::scale_color_viridis_d()`, `scico::scale_color_scico_d()`, etc.).}
#'     \item{`rows`}{`character(1)` A string logical expression evaluated against the
#'       data frame to select rows to highlight (e.g. `"p_value < 0.05"`).}
#'     \item{`elem`}{`character(1)` Whether to highlight `"fill"` (background)
#'       or `"text"`. Overrides the top-level `elem` argument for this column.}
#'   }
#'   If `NULL` (the default), a default spec is generated from `fmt_cols` using
#'   `palette = "red"`, `rows = "<col> < 0.05"`, and the top-level `elem`.
#' @param elem `character(1)` Default highlight element for all columns, either
#'   `"fill"` for background or `"text"` for text color. Can be overridden
#'   per column in `hl_spec`. Defaults to `"text"`.
#' @param ... Additional arguments passed to [smart_fmt_sci()], such as
#'   `threshold`, `sci_digits`, and `num_digits`.
#'
#' @details
#' This function is useful when working with variables that span a wide range of
#' small values, such as p-values, where some values require scientific notation
#' and others do not. Formatting with [smart_fmt_sci()] ensures consistent,
#' readable output. The optional [emphatic::hl()] highlighting makes it easy to
#' visually flag values meeting a condition, such as p-values below 0.05.
#'
#' @return If `emphatic = FALSE`, the input data frame or tibble with
#'   the specified columns formatted as `character()` via [smart_fmt_sci()] is returned.
#'   If `emphatic = TRUE`, an `emphatic` object with formatting and
#'   highlighting applied is returned --- suitable for printing to the console or rendering in
#'   a document.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   type = letters[1:6],
#'   p_value = c(0.532, 0.00000012, 0.041, 0.00000000031, 0.078, 0.023),
#'   p_value_adj = c(0.532, 0.00000072, 0.123, 0.00000000186, 0.234, 0.138)
#' )
#'
#' # Format only, no highlighting
#' df |> fmt_hl(fmt_cols = c(p_value, p_value_adj))
#' #>     type  p_value p_value_adj
#' #> 1      a    0.532       0.532
#' #> 2      b 1.20e-07    7.20e-07
#' #> 3      c    0.041       0.123
#' #> 4      d 3.10e-10    1.86e-09
#' #> 5      e    0.078       0.234
#' #> 6      f    0.023       0.138
#'
#' # Format with default highlighting (red text where < 0.05)
#' # df |> fmt_hl(fmt_cols = c(p_value, p_value_adj), emphatic = TRUE)
#'
#' # Format with custom hl_spec
#' df |>
#'   fmt_hl(
#'     fmt_cols = dplyr::starts_with("p_"),
#'     emphatic = TRUE,
#'     hl_spec = list(
#'       list(
#'         col = "p_value_adj",
#'         palette = ggplot2::scale_color_viridis_d(),
#'         rows = "p_value_adj < 0.05 & p_value_adj > 0",
#'         elem = "fill"
#'       ),
#'       list(
#'         col = "p_value",
#'         palette = "red",
#'         rows = "p_value < 0.05",
#'         elem = "text"
#'       )
#'     )
#'   )
#' #>     type  p_value p_value_adj
#' #> 1      a    0.532       0.532
#' #> 2      b 1.20e-07    7.20e-07
#' #> 3      c    0.041       0.123
#' #> 4      d 3.10e-10    1.86e-09
#' #> 5      e    0.078       0.234
#' #> 6      f    0.023       0.138
#' }


fmt_hl <- function(
    .data,
    fmt_cols,
    emphatic = FALSE,
    hl_spec = NULL,
    elem = "text",
    ...
) {

  # -------------- tests --------------

  chk::chk_data(.data)
  chk::chk_flag(emphatic)
  chk::chk_string(elem)
  chk::chk_subset(elem, c("fill", "text"))

  if (!is.null(hl_spec)) {
    chk::chk_list(hl_spec)
    purrr::walk(hl_spec, function(spec) {
      chk::chk_list(spec)
      chk::chk_subset(c("col", "palette", "rows", "elem"), names(spec))
      chk::chk_string(spec$col)
      chk::chk_string(spec$rows)
      chk::chk_string(spec$elem)
      chk::chk_subset(spec$elem, c("fill", "text"))
      if (!is.character(spec$palette) && !inherits(spec$palette, "ScaleDiscrete")) {
        stop("palette parameter must either be a string with the color's name or a discrete ggplot2 scale object, i.e. class ScaleDiscrete. See docs for examples.")
      }
    })
  }

  # -----------------------------------

  col_names <- .data |>
    dplyr::select({{ fmt_cols }}) |>
    names()

  .data <- dplyr::mutate(.data, dplyr::across({{ fmt_cols }}, \(x) smart_fmt_sci(x, ...)))

  if (!emphatic) return(.data)

  if (is.null(hl_spec)) {
    hl_spec <- purrr::map(col_names, \(col) list(
      col = col,
      palette = "red",
      rows = paste(col, "< 0.05"),
      elem = elem
    ))
  }

  purrr::reduce(hl_spec, function(dat, spec) {
    eval_env <- dplyr::mutate(dat, dplyr::across(where(is.character), as.numeric)) |>
      suppressWarnings()
    rows_evaluated <- eval(parse(text = spec$rows), envir = eval_env)

    do.call(emphatic::hl, list(
      .data = dat,
      palette = spec$palette,
      cols = as.name(spec$col),
      rows = rows_evaluated,
      elem = spec$elem %||% elem
    ))
  }, .init = .data)
}
