#' Wrangle Raw Data
#'
#' Data wrangling is the first step for data analysis.
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
    # make it error-proof to avoid trivial errors
    purrr::possibly(parse_raw_json)
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
#'   format of a list of [data.frame][data.frame()]s.
#' @param out_name_index The column name used in output storing the name of each
#'   calculated index.
#' @param out_name_score The column name used in output storing the value of
#'   each calculated index.
#' @return A [data.frame] contains the calculated indices. The index names are
#'   stored in the column of `out_name_index`, and index values are stored in
#'   the column of `out_name_score`.
#' @export
preproc_data <- function(data, fn, ...,
                         name_raw_parsed = "raw_parsed",
                         out_name_index = "index_name",
                         out_name_score = "score") {
  data <- filter(data, !purrr::map_lgl(.data[[name_raw_parsed]], is_empty))
  if (nrow(data) == 0) {
    warn("No non-empty data found.")
    return()
  }
  fn <- as_function(fn)
  data |>
    mutate(
      calc_indices(.data[[name_raw_parsed]], fn, ...),
      .keep = "unused"
    ) |>
    pivot_longer(
      cols = !any_of(names(data)),
      names_to = out_name_index,
      values_to = out_name_score
    ) |>
    vctrs::vec_restore(data)
}

# helper functions
parse_raw_json <- function(jstr) {
  jsonlite::fromJSON(jstr) |>
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
          "Failed to bind raw data with the following error: ",
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
