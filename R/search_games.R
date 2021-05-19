#' Search and cache games used in analysis
#'
#' When separate analysis into branches, the games to be analyzed should be
#' known in advance. This function should be used with memoise package to reduce
#' executing time.
#'
#' The fetched will be joined with [`game_info`][dataproc.iquizoo::game_info]
#' data from dataproc.iquizoo package to expose the pre-processing function
#' name.
#'
#' @usage
#' search_games(config_where)
#' # cached version using `memoise::memoise()`
#' search_games_mem(config_where)
#'
#' @param config_where Configuration of "where-clause".
#' @return A [tibble][tibble::tibble-package] contains all the games to be
#'   analyzed and its related information.
#' @export
search_games <- function(config_where) {
  query_path <- fs::path(query_dir, query_files[["games"]])
  stopifnot(fs::file_exists(query_path))
  tarflow.iquizoo::fetch(query_path, config_where) |>
    dplyr::left_join(dataproc.iquizoo::game_info, by = "game_id") |>
    dplyr::mutate(prep_fun = syms(.data[["prep_fun_name"]]))
}

#' @rdname search_games
#' @usage NULL
#' @export
search_games_mem <- memoise::memoise(
  search_games,
  cache = cachem::cache_disk("~/.cache.tarflow")
)
