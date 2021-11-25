#' Wrangle Raw Data
#'
#' Data wrangling is the first step for data analysis.
#'
#' @param data The raw data.
#' @param .key The key name used to match meta data. Should be a scalar
#'   character. Default is `".id"`, which is appropriate for most cases.
#' @return A [dm][dm::dm()] object containing two tables: `meta` and `data`.
#' @export
wrangle_data <- function(data, .key = ".id") {
  keys <- c(
    raw_data = "game_data",
    user_id = "user_id"
  )
  #' @details
  #'
  #' These steps are performed in order:
  #'
  #' 1. Data clean. Remove observations with invalid or empty (i.e., `"[]"` or
  #' `"{}"`) json string data and then remove duplicates from data. If this step
  #' produces data with no observation, following steps are skipped and `NULL`
  #' is returned.
  data_valid <- data |>
    dplyr::filter(
      purrr::map_lgl(.data[[keys[["raw_data"]]]], jsonlite::validate),
      !stringr::str_detect(
        .data[[keys[["raw_data"]]]],
        r"(^\s*(\[\s*\]|\{\s*\})\s*$)"
      )
    ) |>
    dplyr::group_by(.data[[keys[["user_id"]]]], .data[[keys[["raw_data"]]]]) |>
    dplyr::filter(dplyr::row_number() == 1) |>
    dplyr::ungroup()
  if (nrow(data_valid) == 0) {
    return()
  }
  #' 1. Data parse. Parse data stored in json string, convert the names to lower
  #' case and stack the parsed data. Stacking have better performances than
  #' [group_nest][group_nest()]ing.
  data_decomposed <- dm::decompose_table(
    data_valid, -keys[["raw_data"]],
    new_id_column = !!.key
  )
  meta <- data_decomposed$parent_table
  data <- data_decomposed$child_table |>
    dplyr::group_by(.data[[.key]]) |>
    dplyr::summarise(
      purrr::map_df(
        .data[[keys[["raw_data"]]]],
        ~ jsonlite::fromJSON(.x) |>
          dplyr::rename_with(tolower)
      ),
      .groups = "drop"
    )
  dm::dm(meta, data) |>
    dm::dm_add_pk(meta, !!.key) |>
    dm::dm_add_pk(data, !!.key) |>
    dm::dm_add_fk(meta, !!.key, data, !!.key)
}
