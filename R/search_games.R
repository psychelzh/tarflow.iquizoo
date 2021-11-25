#' Search and cache games used in analysis
#'
#' When separate analysis into branches, the games to be analyzed should be
#' known in advance. This function should be used with memoise package to reduce
#' executing time.
#'
#' The fetched will be joined with [`game_info`][data.iquizoo::game_info] data
#' from data.iquizoo package to expose the pre-processing function name.
#'
#' @param config_where Configuration of "where-clause".
#' @param known_only Logical value indicates whether to use games in
#'   [`game_info`][data.iquizoo::game_info] only (default) or not.
#' @param query_file An optional argument specifying the file storing query of
#'   games. If leave as `NULL`, default to "sql/games.sql", which is created by
#'   rmarkdown template.
#' @return A [tibble][tibble::tibble-package] contains all the games to be
#'   analyzed and its related information.
#' @export
search_games <- function(config_where, known_only = TRUE, query_file = NULL) {
  if (is.null(query_file)) query_file <- "sql/games.sql"
  if (!file.exists(query_file)) abort("Query file missing.", "query_file_miss")
  games <- tarflow.iquizoo::fetch(query_file, config_where)
  if (known_only) {
    games |>
      dplyr::inner_join(data.iquizoo::game_info, by = "game_id") |>
      dplyr::mutate(prep_fun = syms(.data[["prep_fun_name"]]))
  } else {
    games |>
      dplyr::left_join(data.iquizoo::game_info, by = "game_id")
  }
}

#' @describeIn search_games Cached version using `memoise::memoise`.
#' @export
search_games_mem <- memoise::memoise(
  search_games,
  cache = cachem::cache_disk("~/.cache.tarflow")
)
