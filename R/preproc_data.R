#' Feed Raw Data to Pre-processing
#'
#' Integrate [dm][dm::dm()] object returned by [wrangle_data()] with functions
#' in preproc.iquizoo package.
#'
#' The calculated indices are stored in a [data.frame][data.frame()] of
#' [longer][tidyr::pivot_longer()] format with two columns named `"index_name"`
#' and `"score"` respectively and are wrapped into a [dm][dm::dm()] object. The
#' longer format is used to facilitate combining.
#'
#' @param dm A [dm][dm::dm()] object typically from [wrangle_data()] contains
#'   two tables: `meta` and `data`.
#' @param .fn This can be a function or formula. See [rlang::as_function()] for
#'   more details.
#' @param ... Additional arguments passed to `.fn`. Note `.by` argument is
#'   handled by current function itself, do not pass it.
#' @return A [dm][dm::dm()] object containing two tables: `meta` and `indices`.
#' @export
preproc_data <- function(dm, .fn, ...) {
  .fn <- as_function(.fn)
  .key <- dm::dm_get_all_pks(dm, "data") |>
    purrr::pluck("pk_col", 1)
  indices <- .fn(dm::pull_tbl(dm, "data"), .key, ...) |>
    tidyr::pivot_longer(
      -dplyr::any_of(.key),
      names_to = "index_name",
      values_to = "score"
    )
  dm |>
    dm::dm_select_tbl(-"data") |>
    dm::dm_add_tbl(indices) |>
    dm::dm_add_pk("indices", !!.key) |>
    dm::dm_add_fk("meta", !!.key, "indices", !!.key)
}
