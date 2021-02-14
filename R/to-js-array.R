
#' Converts data columns to a js array
#'
#' @description
#' [to_js_array()] takes a tibble with a grouping column and columns that are to be combined into a js array.
#'
#' @param .data tibble; data with grouping column and columns to be used to create the js array column
#' @param .grp_var grouping column
#' @param ... columns in .data that are to be used to create the js array column
#' @param array_name string; name of the newly created js array column
#'
#' @return tibble with grouping column and js array column
#'
#' @details The js array column that's created is list column of form <array_name> = list(list(array_var1=var1val1, array_var2 = var2val1, ...), list(array_var1=var1val2, array_var2=var2val2, ...), ...) for each grouping variable category.
#' I like to use the [dataui package](https://timelyportfolio.github.io/dataui/articles/dataui_reactable.html) along with the [reactable package](https://glin.github.io/reactable/index.html). `dataui` is still in more of a developmental phase and requires the data to be in this js array like format.
#'
#' @export
#'
#' @examples
#'
#' head(indiana_pos_rate)
#'
#' pos_rate_array <- to_js_array(.data = indiana_pos_rate,
#'                               .grp_var = msa,
#'                               end_date, pos_rate,
#'                               array_name = "posList")
#'
#' head(pos_rate_array)



to_js_array <- function(.data, .grp_var, ..., array_name) {

  # check args
  chk::chk_character(array_name)
  # make sure .data is a tibble
  chk::chk_is(.data, class = "tbl")

  # quote array variables
  dots <- rlang::enquos(..., .named = TRUE)
  chk::chk_not_empty(dots, x_name = "... (array columns)")

  .data %>%
    dplyr::group_by({{ .grp_var }}) %>%
    dplyr::summarize({{ array_name }} := purrr::pmap(list(!!!dots), ~list(...)),
                     .groups = "keep") %>%
    tidyr::nest() %>%
    dplyr::mutate(data = purrr::map(data, ~as.list(.x))) %>%
    dplyr::rename({{ array_name }} := data) %>%
    dplyr::ungroup()

}


