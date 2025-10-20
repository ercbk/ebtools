#' Skim an Arrow Dataset
#'
#' @description
#' Provides a \{skimr\}-style summary of an Arrow Dataset with statistics
#' organized by variable type. Computes summary statistics efficiently using
#' Arrow's query engine without loading the full dataset into memory.
#'
#' @param ds An Arrow Dataset object created with `arrow::open_dataset()`. This would probably work on any \{arrow\} data object with a schema.
#'
#' @return A list of class "skim_arrow" containing:
#'   \item{overview}{A tibble with dataset dimensions and column type counts}
#'   \item{numeric}{A tibble with statistics for numeric columns (missing_pct, mean, sd, min, max)}
#'   \item{character}{A tibble with statistics for character columns (missing_pct, n_unique)}
#'   \item{timestamp}{A tibble with statistics for timestamp columns (missing_pct, min, max)}
#'
#' @details
#' The function classifies columns by type and computes appropriate summary
#' statistics for each:
#' \itemize{
#'   \item Numeric columns: missing percentage, mean, standard deviation, min, max
#'   \item Character columns: missing percentage, number of unique values
#'   \item Timestamp columns: missing percentage, min, max (as POSIXct objects)
#' }
#'
#' All computations are performed using Arrow's query engine, making this
#' function efficient even for very large datasets stored in Parquet files.
#'
#' @examples
#' \dontrun{
#' # Open a directory of Parquet files
#' ds <- arrow::open_dataset("path/to/parquet/files")
#'
#' # Get summary statistics
#' summary <- skim_arrow(ds)
#'
#' # View all sections
#' summary
#'
#' # Access specific sections
#' summary$numeric
#' summary$character
#' summary$timestamp
#' }
#'
#' @seealso \code{\link[arrow]{open_dataset}}, \code{\link[skimr]{skim}}
#'
#' @export
skim_arrow <- function(ds) {

  # Get schema to identify column types
  schema <- ds$schema
  col_names <- names(schema)

  # Classify columns by type
  numeric_cols <- col_names[sapply(schema, function(field) {
    type_name <- field$type$ToString()
    grepl("int|float|double|decimal", type_name, ignore.case = TRUE)
  })]

  character_cols <- col_names[sapply(schema, function(field) {
    type_name <- field$type$ToString()
    grepl("string|utf8", type_name, ignore.case = TRUE)
  })]

  timestamp_cols <- col_names[sapply(schema, function(field) {
    type_name <- field$type$ToString()
    grepl("timestamp", type_name, ignore.case = TRUE)
  })]

  # Build the summary query
  result <- ds |>
    dplyr::summarize(
      # Missingness for ALL columns
      dplyr::across(
        dplyr::everything(),
        ~mean(is.na(.)) * 100,
        .names = "{.col}_missing_pct"
      ),

      # Numeric column stats
      dplyr::across(
        dplyr::all_of(numeric_cols),
        list(
          min = ~min(., na.rm = TRUE),
          max = ~max(., na.rm = TRUE),
          mean = ~mean(., na.rm = TRUE),
          sd = ~sd(., na.rm = TRUE)
        ),
        .names = "{.col}_{.fn}"
      ),

      # Character column stats
      dplyr::across(
        dplyr::all_of(character_cols),
        ~dplyr::n_distinct(., na.rm = TRUE),
        .names = "{.col}_n_unique"
      ),

      # Timestamp column stats (min/max only)
      dplyr::across(
        dplyr::all_of(timestamp_cols),
        list(
          min = ~min(., na.rm = TRUE),
          max = ~max(., na.rm = TRUE)
        ),
        .names = "{.col}_{.fn}"
      )
    ) |>
    dplyr::collect()

  # Create separate tables for each variable type
  output <- list()

  # Overview table
  output$overview <- dplyr::tibble(
    n_rows = nrow(ds),
    n_cols = length(col_names),
    n_numeric = length(numeric_cols),
    n_character = length(character_cols),
    n_timestamp = length(timestamp_cols)
  )

  # Numeric variables table
  if (length(numeric_cols) > 0) {
    numeric_data <- result |>
      dplyr::select(dplyr::ends_with("_missing_pct"), dplyr::ends_with(c("_min", "_max", "_mean", "_sd"))) |>
      dplyr::select(dplyr::matches(paste0("^(", paste(numeric_cols, collapse = "|"), ")_")))

    output$numeric <- dplyr::tibble(
      variable = numeric_cols,
      missing_pct = as.numeric(numeric_data[1, paste0(numeric_cols, "_missing_pct")]),
      mean = as.numeric(numeric_data[1, paste0(numeric_cols, "_mean")]),
      sd = as.numeric(numeric_data[1, paste0(numeric_cols, "_sd")]),
      min = as.numeric(numeric_data[1, paste0(numeric_cols, "_min")]),
      max = as.numeric(numeric_data[1, paste0(numeric_cols, "_max")])
    )
  }

  # Character variables table
  if (length(character_cols) > 0) {
    char_data <- result |>
      dplyr::select(dplyr::matches(paste0("^(", paste(character_cols, collapse = "|"), ")_(missing_pct|n_unique)")))

    output$character <- dplyr::tibble(
      variable = character_cols,
      missing_pct = as.numeric(char_data[1, paste0(character_cols, "_missing_pct")]),
      n_unique = as.numeric(char_data[1, paste0(character_cols, "_n_unique")])
    )
  }

  # Timestamp variables table
  if (length(timestamp_cols) > 0) {
    ts_data <- result |>
      dplyr::select(dplyr::matches(paste0("^(", paste(timestamp_cols, collapse = "|"), ")_(missing_pct|min|max)")))

    output$timestamp <- dplyr::tibble(
      variable = timestamp_cols,
      missing_pct = as.numeric(ts_data[1, paste0(timestamp_cols, "_missing_pct")]),
      min = as.POSIXct(unlist(ts_data[1, paste0(timestamp_cols, "_min")]), origin = "1970-01-01", tz = "UTC"),
      max = as.POSIXct(unlist(ts_data[1, paste0(timestamp_cols, "_max")]), origin = "1970-01-01", tz = "UTC")
    )
  }

  # Set class for custom print method
  class(output) <- c("skim_arrow", "list")

  return(output)
}

#' Print Method for skim_arrow Objects
#'
#' Provides formatted output for skim_arrow results, displaying summary
#' statistics organized by variable type in a `skimr`-style format.
#'
#' @param x A skim_arrow object (output from `skim_arrow()`)
#' @param ... Additional arguments passed to print methods (currently unused)
#'
#' @return Invisibly returns the input object `x`
#' @keywords internal
#' @export
print.skim_arrow <- function(x, ...) {
  cat("\u2500\u2500 Data Summary \u2500\u2500\n\n")
  print(x$overview)

  if (!is.null(x$numeric)) {
    cat("\n\u2500\u2500 Numeric Variables \u2500\u2500\n\n")
    print(x$numeric, n = Inf)
  }

  if (!is.null(x$character)) {
    cat("\n\u2500\u2500 Character Variables \u2500\u2500\n\n")
    print(x$character, n = Inf)
  }

  if (!is.null(x$timestamp)) {
    cat("\n\u2500\u2500 Timestamp Variables \u2500\u2500\n\n")
    print(x$timestamp, n = Inf)
  }

  invisible(x)
}
