#' Feed Raw Data to Pre-processing
#'
#' Integrate [dm][dm::dm()] object returned by [wrangle_data()] with functions
#' in preproc.iquizoo package.
#'
#' @param dm A [dm][dm::dm()] object typically from [wrangle_data()] contains
#'   two tables: `meta` and `data`.
#' @param .fn This can be a function or formula. See [rlang::as_function()] for
#'   more details.
#' @param ... Additional arguments passed to `.fn`. Note `.by` argument is
#'   handled by current function itself, do not pass it.
#' @return A [tibble][tibble::tibble-package] of calculated indices.
#' @export
preproc_data <- function(dm, .fn, ...) {
  .fn <- as_function(.fn)
  .key <- dm::dm_get_all_pks(dm, "data") |>
    purrr::pluck("pk_col", 1)
  dm::reunite_parent_child(
    dm::pull_tbl(dm, "meta"),
    .fn(dm::pull_tbl(dm, "data"), .key, ...),
    id_column = !!.key
  )
}
