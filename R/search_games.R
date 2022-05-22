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
#'   games. If leave as `NULL`, default to "sql/games.tmpl.sql", which is
#'   created by rmarkdown template.
#' @param file_cache The file used to store caches of results which is passed to
#'   [cachem::cache_disk()].
#' @param ... Arguments passed to [search_games()].
#' @return A [tibble][tibble::tibble-package] contains all the games to be
#'   analyzed and its related information.
#' @export
search_games <- function(config_where, known_only = TRUE, query_file = NULL) {
  if (is.null(query_file)) query_file <- "sql/games.tmpl.sql"
  if (!file.exists(query_file)) abort("Query file missing.", "query_file_miss")
  games <- pickup(query_file, config_where)
  join_method <- if (known_only) dplyr::inner_join else dplyr::left_join
  games |>
    join_method(data.iquizoo::game_info, by = names(games)) |>
    dplyr::mutate(
      # https://github.com/ropensci/tarchetypes/issues/94
      game_id = bit64::as.character.integer64(game_id),
      prep_fun = purrr::map(
        .data[["prep_fun_name"]],
        purrr::possibly(sym, NA)
      ),
      dplyr::across(
        dplyr::all_of(c("input", "extra")),
        parse_exprs
      )
    )
}

#' @describeIn search_games Cached version using
#'   [memoise()][memoise::memoise()].
#' @export
search_games_mem <- function(file_cache = "~/.cache.tarflow", ...) {
  memoise::memoise(
    search_games,
    cache = cachem::cache_disk(file_cache)
  )(...)
}
