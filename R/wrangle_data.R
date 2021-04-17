#' Wrangle Raw Data
#'
#' Data wrangling is the first step for data analysis. In this function, raw
#' data fetched from database.
#'
#' @param data The raw data.
#' @param name_data The column name in the `data` that stores original data. It
#'   is typically of a vector containing `JSON` string.
#' @return A [tibble][tibble::tibble-package] with two pieces of meta data:
#'   `info` and `name_key`. They stores other metadata from input rawdata other
#'   than game data from `name_data`.
#' @export
wrangle_data <- function(data, name_data) {
  # starts with "." to prevent name conflicts (to some extent)
  name_key <- ".id"
  #' @details
  #'
  #' These steps are performed in order:
  #'
  #' 1. Remove observations with invalid or empty (i.e., `"[]"` or `"{}"`) json
  #' string data. If this step produces data with no observation, following
  #' steps are skipped and `NULL` is returned.
  data_valid <- data %>%
    dplyr::filter(
      purrr::map_lgl(.data[[name_data]], jsonlite::validate),
      !stringr::str_detect(.data[[name_data]], r"(^\s*(\[\s*\]|\{\s*\})\s*$)")
    ) %>%
    dplyr::mutate("{name_key}" := seq_len(dplyr::n()), .before = 1)
  if (nrow(data_valid) == 0) {
    return()
  }
  #' 1. Parse data stored in json string, convert the names to lower case and
  #' stack the parsed data. Stacking have better performances than
  #' [group_nest][dplyr::group_nest()]ing.
  meta <- dplyr::select(data_valid, -.data[[name_data]])
  data_parsed <- data_valid %>%
    dplyr::select(.data[[name_key]], .data[[name_data]]) %>%
    dplyr::mutate(
      "{name_data}" := purrr::map(
        .data[[name_data]],
        ~ jsonlite::fromJSON(.x) %>%
          dplyr::rename_with(tolower)
      )
    ) %>%
    tidyr::unnest(.data[[name_data]])
  structure(
    data_parsed,
    class = c("tbl_meta", class(data_parsed)),
    meta = meta,
    name_key = name_key
  )
}

#' @export
print.tbl_meta <- function(x) {
  NextMethod()
  cat("* Name of key: '", attr(x, "name_key"), "'\n", sep = "")
  meta <- attr(x, "meta")
  cat("* Meta of", nrow(meta), "obs and", ncol(meta), "vars")
  invisible(x)
}
