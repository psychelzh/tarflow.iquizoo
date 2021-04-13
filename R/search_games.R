#' Search games used in analysis
#'
#' When separate analysis into branches, the games to be analyzed should be
#' known in advance. This function should be used with memoise package to reduce
#' executing time.
#'
#' The fetched will be joined with `dataproc.iquizoo::game_info` to expose the
#' pre-processing function name.
#'
#' @examples
#' \dontrun{
#' # use it with memoise
#' search_games_mem <- memoise::memoise(search_games)
#' games <- search_games_mem(config::get("where"))
#' }
#'
#' @param config_where Configuration of "where-clause".
#' @return A [tibble][tibble::tibble-package] contains all the games to be
#'   analyzed and its related information.
#' @export
search_games <- function(config_where) {
  stopifnot(fs::file_exists(query_files[["games"]]))
  tarflow.iquizoo::fetch(query_files[["games"]], config_where) %>%
    dplyr::left_join(dataproc.iquizoo::game_info, by = "game_id") %>%
    dplyr::mutate(prep_fun = rlang::syms(.data[["prep_fun_name"]]))
}
