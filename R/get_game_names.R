#' Find out the names of games to be processed
#'
#' The game names are mainly extracted from the `config.yml` file. Future work
#' might be extracted those games from given courses.
#'
#' @param use_db Use online database to get a better guess.
#' @return The Chinese names of found games
#' @importFrom rlang %||%
#' @export
get_game_names <- function(use_db = FALSE) {
  config_where <- config::get("where")
  tryCatch(
    purrr::chuck(config_where, "content", "Name"),
    error = function(err) {
      if (use_db) warning("`use_db` is not implemented yet.")
      return(NULL)
    }
  ) %||%
    dplyr::pull(readr::read_csv("settings/game_info.csv"), "game_name")
}
