# Skim an Arrow Dataset

Provides a {skimr}-style summary of an Arrow Dataset with statistics
organized by variable type. Computes summary statistics efficiently
using Arrow's query engine without loading the full dataset into memory.

## Usage

``` r
skim_arrow(ds)
```

## Arguments

- ds:

  An Arrow Dataset object created with `arrow::open_dataset()`. This
  would probably work on any {arrow} data object with a schema.

## Value

A list of class "skim_arrow" containing:

- overview:

  A tibble with dataset dimensions and column type counts

- numeric:

  A tibble with statistics for numeric columns (missing_pct, mean, sd,
  min, max)

- character:

  A tibble with statistics for character columns (missing_pct, n_unique)

- timestamp:

  A tibble with statistics for timestamp columns (missing_pct, min, max)

## Details

The function classifies columns by type and computes appropriate summary
statistics for each:

- Numeric columns: missing percentage, mean, standard deviation, min,
  max

- Character columns: missing percentage, number of unique values

- Timestamp columns: missing percentage, min, max (as POSIXct objects)

All computations are performed using Arrow's query engine, making this
function efficient even for very large datasets stored in Parquet files.

## See also

`open_dataset`, `skim`

## Examples

``` r
if (FALSE) { # \dontrun{
# Open a directory of Parquet files
ds <- arrow::open_dataset("path/to/parquet/files")

# Get summary statistics
summary <- skim_arrow(ds)

# View all sections
summary

# Access specific sections
summary$numeric
summary$character
summary$timestamp
} # }
```
