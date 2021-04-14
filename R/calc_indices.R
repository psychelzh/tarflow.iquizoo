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
  #' @details
  #'
  #' These steps are performed in order:
  #'
  #' 1. Remove observations with invalid or empty (i.e., `"[]"`) json string
  #' data. If this step produces data with no observation, following steps are
  #' skipped and `NULL` is returned.
  data_valid <- dplyr::filter(
    data,
    purrr::map_lgl(
      .data[[name_data]],
      ~ jsonlite::validate(.x) &
        jsonlite::minify(.x) != "[]"
    )
  )
  if (nrow(data_valid) == 0) {
    return()
  }
  #' 1. Parse data stored in json string, convert the names to lower case and
  #' stack the parsed data. Stacking have better performances than
  #' [group_nest][dplyr::group_nest()]ing.
  data_parsed <- data_valid %>%
    dplyr::mutate(
      "{name_data}" := purrr::map(
        .data[[name_data]],
        ~ jsonlite::fromJSON(.x) %>%
          dplyr::rename_with(tolower)
      )
    ) %>%
    tidyr::unnest(.data[[name_data]])
  #' 1. Call [dataproc.iquizoo::preproc_data()] to pre-process on the parsed
  #' data, and the results are stacked into a long format. The longer format is
  #' used because each observation has its own creating time information.
  dataproc.iquizoo::preproc_data(
    data_parsed,
    deparse1(substitute(prep_fun)),
    vars_by,
    character.only = TRUE
  ) %>%
    tidyr::pivot_longer(
      !dplyr::all_of(vars_by),
      names_to = "index",
      values_to = "score"
    )
}
