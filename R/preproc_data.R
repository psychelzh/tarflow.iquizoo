#' Feed Raw Data to Pre-processing
#'
#' Integrate data returned by [wrangle_data()] with functions in preproc.iquizoo
#' package.
#'
#' The calculated indices are stored in a [data.frame][data.frame()] of
#' [longer][tidyr::pivot_longer()] format with two columns named `"index_name"`
#' and `"score"` respectively and are nested into a
#' [tibble][tibble::tibble-package] object. The longer format is used to
#' facilitate combining.
#'
#' @param data A [tibble][tibble::tibble-package] contains raw data.
#' @param fn This can be a function or formula. See [rlang::as_function()] for
#'   more details.
#' @param name_raw_parsed The column name in which stores user's raw data in
#'   format of a list of [data.frame][data.frame()]s.
#' @param ... Additional arguments passed to `fn`.
#' @return A [tibble][tibble::tibble-package] contains the calculated indices.
#' @export
preproc_data <- function(data, fn, name_raw_parsed = "raw_parsed", ...) {
  fn <- as_function(fn)
  data |>
    dplyr::mutate(
      indices = purrr::map(
        .data[[name_raw_parsed]],
        fn,
        ...
      ),
      .keep = "unused"
    )
}
