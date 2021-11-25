#' Feed Raw Data to Pre-processing
#'
#' Integrate [dm][dm::dm()] object returned by [wrangle_data()] with
#' [preproc.iquizoo::preproc()] API.
#'
#' @param dm A [dm][dm::dm()] object typically from [wrangle_data()] contains
#'   two tables: `meta` and `data`.
#' @param ... Parameters passed to [preproc.iquizoo::preproc()].
#' @return A [dm][dm::dm()] object containing three tables: `meta`, `data` and
#'   `indices`.
#' @export
preproc_data <- function(dm, ...) {
  if (is_empty(dm)) {
    warn("Input `dm` is empty.", "data_empty")
    return()
  }
  .key <- dm::dm_get_all_pks(dm, "data") |>
    purrr::pluck("pk_col", 1)
  indices <- dm |>
    dm::pull_tbl(data) |>
    preproc.iquizoo::preproc(.by = .key, ...)
  if (is_empty(indices)) {
    warn("Pre-processing exception occured.", "indices_empty")
    return()
  }
  dm_indices <- dm::dm(indices) |>
    dm::dm_add_pk("indices", !!.key)
  dm |>
    dm::dm_select_tbl(-"data") |>
    dm::dm_bind(dm_indices) |>
    dm::dm_add_fk("meta", !!.key, "indices", !!.key)
}
