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
  data_with_id <- dplyr::mutate(data, .id = seq_len(dplyr::n()))
  groups <- dplyr::select(data_with_id, -.data[[name_raw_parsed]])
  raw_data <- dplyr::select(data_with_id, .data$.id, .data[[name_raw_parsed]])
  data_unnested <- try_fetch(
    tidyr::unnest(raw_data, .data[[name_raw_parsed]]),
    error = function(cnd) {
      pattern <- r"(Can't combine `\.\.1\$\w+` <.+> and `\.\.2\$\w+` <.+>)"
      if (!grepl(pattern, conditionMessage(cnd))) {
        abort(
          "Don't know how to handle this error.",
          class = "tarflow/unnest_incompatible",
          parent = cnd
        )
      }
      raw_data |>
        dplyr::mutate(
          "{name_raw_parsed}" := purrr::map(
            .data[[name_raw_parsed]],
            ~ dplyr::mutate(., dplyr::across(.fns = as.character))
          )
        ) |>
        tidyr::unnest(.data[[name_raw_parsed]]) |>
        dplyr::mutate(
          dplyr::across(
            -.data$.id,
            utils::type.convert,
            as.is = TRUE
          )
        )
    }
  )
  if (nrow(data_unnested) == 0) {
    return()
  }
  dplyr::inner_join(
    groups,
    data_unnested |>
      fn(.by = ".id", ...) |>
      tidyr::pivot_longer(
        cols = -.data$.id,
        names_to = out_name_index,
        values_to = out_name_score
      ),
    by = ".id"
  ) |>
    dplyr::select(-.data$.id)
}
