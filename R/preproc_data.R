#' Feed Raw Data to Pre-processing
#'
#' Integrate data returned by [wrangle_data()] with functions in preproc.iquizoo
#' package.
#'
#' The calculated indices are stored in a [data.frame][data.frame()] of
#' [longer][tidyr::pivot_longer()] format with two columns named `"index_name"`
#' and `"score"` (both could be configured) respectively and are nested into a
#' [tibble][tibble::tibble-package] object. The longer format is used to
#' facilitate combining.
#'
#' @param data A [tibble][tibble::tibble-package] contains raw data.
#' @param fn This can be a function or formula. See [rlang::as_function()] for
#'   more details.
#' @param name_raw_parsed The column name in which stores user's raw data in
#'   format of a list of [data.frame][data.frame()]s.
#' @param out_name_index The column name used in output storing the name of each
#'   calculated index.
#' @param out_name_score The column name used in output storing the value of
#'   each calculated index.
#' @param ... Additional arguments passed to `fn`.
#' @return A [tibble][tibble::tibble-package] contains the calculated indices.
#'   The index names are stored in the column of `out_name_index`, and index
#'   values are stored in the column of `out_name_score`.
#' @export
preproc_data <- function(data, fn,
                         name_raw_parsed = "raw_parsed",
                         out_name_index = "index_name",
                         out_name_score = "score",
                         ...) {
  # do not add `possibly()` for early error is needed to check configurations
  fn <- as_function(fn)
  group_vars <- setdiff(names(data), name_raw_parsed)
  data |>
    # `NULL`s in raw parsed will be removed implicitly
    tidyr::unnest(.data[[name_raw_parsed]]) |>
    fn(.by = group_vars, ...) |>
    tidyr::pivot_longer(
      cols = -dplyr::any_of(group_vars),
      names_to = out_name_index,
      values_to = out_name_score
    )
}
