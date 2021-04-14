#' Calculate Indices
#'
#' Get raw data prepared and calculate indices.
#'
#' @param data The raw data.
#' @param prep_fun The name (symbol) of the calculation function
#' @param name_data The column name in the `data` that stores original data. It
#'   is typically of a vector containing `JSON` string.
#' @return A `tibble` with the calculated indices.
#' @author Liang Zhang
#' @export
calc_indices <- function(data, prep_fun, name_data = "game_data") {
  vars_by <- setdiff(names(data), name_data)
  data_parsed <- data %>%
    dplyr::mutate(
      "{name_data}" := purrr::map(
        .data[[name_data]],
        ~ jsonlite::fromJSON(.x) %>%
          dplyr::rename_with(tolower)
      )
    ) %>%
    tidyr::unnest(.data[[name_data]])
  dataproc.iquizoo::preproc_data(
    data_parsed,
    deparse1(substitute(prep_fun)),
    vars_by,
    character.only = TRUE
  ) %>%
    # results must be stacked for there might be game time
    tidyr::pivot_longer(
      !dplyr::all_of(vars_by),
      names_to = "index",
      values_to = "score"
    )
}
