#' Wrangle Raw Data
#'
#' Parse raw json string data as [data.frame()] and store them in a list column.
#'
#' @param data The raw data.
#' @param name_raw_json The column name in which stores user's raw data in
#'   format of json string.
#' @param name_raw_parsed The name used to store parsed data.
#' @return A [data.frame] contains the parsed data.
#' @export
wrangle_data <- function(data,
                         name_raw_json = "game_data",
                         name_raw_parsed = "raw_parsed") {
  data[[name_raw_parsed]] <- purrr::map(
    data[[name_raw_json]],
    parse_raw_json
  )
  select(data, !all_of(name_raw_json))
}

#' Feed Raw Data to Pre-processing
#'
#' Calculate indices using data typically returned by [wrangle_data()].
#'
#' @details
#'
#' Observations with empty raw data (empty vector, e.g. `NULL`, in
#' `name_raw_parsed` column) are removed before calculating indices. If no
#' observations left after removing, a warning is signaled and `NULL` is
#' returned.
#'
#' @param data A [data.frame] contains raw data.
#' @param fn This can be a function or formula. See [rlang::as_function()] for
#'   more details.
#' @param ... Additional arguments passed to `fn`.
#' @param name_raw_parsed The column name in which stores user's raw data in
#'   format of a list of [data.frame]s.
#' @param pivot_results Whether to pivot the calculated indices. If `TRUE`, the
#'   calculated indices are pivoted into long format, with each index name
#'   stored in the column of `pivot_names_to`, and each index value stored in
#'   the column of `pivot_values_to`. If `FALSE`, the calculated indices are
#'   stored in the same format as returned by `fn`.
#' @param pivot_names_to,pivot_values_to The column names used to store index
#'   names and values if `pivot_results` is `TRUE`. See [tidyr::pivot_longer()]
#'   for more details.
#' @return A [data.frame] contains the calculated indices.
#' @export
preproc_data <- function(data, fn, ...,
                         name_raw_parsed = "raw_parsed",
                         pivot_results = TRUE,
                         pivot_names_to = "index_name",
                         pivot_values_to = "score") {
  data <- filter(data, !purrr::map_lgl(.data[[name_raw_parsed]], is_empty))
  if (nrow(data) == 0) {
    warn("No non-empty data found.")
    return()
  }
  fn <- as_function(fn)
  results <- data |>
    mutate(
      calc_indices(.data[[name_raw_parsed]], fn, ...),
      .keep = "unused"
    )
  if (pivot_results) {
    results <- results |>
      pivot_longer(
        cols = !any_of(names(data)),
        names_to = pivot_names_to,
        values_to = pivot_values_to
      ) |>
      vctrs::vec_restore(data)
  }
  results
}

# helper functions
parse_raw_json <- function(jstr) {
  parsed <- tryCatch(
    jsonlite::fromJSON(jstr),
    error = function(cnd) {
      warn(
        c(
          "Failed to parse json string with the following error:",
          conditionMessage(cnd),
          i = "Will parse it as `NULL` instead."
        )
      )
      return()
    }
  )
  if (is_empty(parsed)) {
    return()
  }
  parsed |>
    rename_with(tolower) |>
    mutate(across(where(is.character), tolower))
}

calc_indices <- function(l, fn, ...) {
  # used as a temporary id for each element
  name_id <- ".id"
  tryCatch(
    bind_rows(l, .id = name_id),
    error = function(cnd) {
      warn(
        c(
          "Failed to bind raw data with the following error:",
          conditionMessage(cnd),
          i = "Will try using tidytable package."
        )
      )
      check_installed(
        "tidytable",
        "because tidyr package fails to bind raw data."
      )
      tidytable::bind_rows(l, .id = name_id) |>
        utils::type.convert(as.is = TRUE)
    }
  ) |>
    fn(.by = name_id, ...) |>
    select(!all_of(name_id))
}
