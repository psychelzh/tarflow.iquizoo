#' Feed Raw Data to Pre-processing
#'
#' Calculate indices using data returned by [wrangle_data()].
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
  groups <- dplyr::select(data_with_id, -all_of(name_raw_parsed))
  raw_data <- dplyr::select(data_with_id, all_of(c(".id", name_raw_parsed)))
  data_unnested <- try_fetch(
    tidyr::unnest(raw_data, all_of(name_raw_parsed)),
    error = function(cnd) {
      pattern <- r"(Can't combine `.+\$.+` <.+> and `.+\$.+` <.+>)"
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
        tidyr::unnest(all_of(name_raw_parsed)) |>
        utils::type.convert(as.is = TRUE) |>
        vctrs::vec_restore(raw_data)
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
        cols = -all_of(".id"),
        names_to = out_name_index,
        values_to = out_name_score
      ),
    by = ".id"
  ) |>
    dplyr::select(-all_of(".id"))
}
