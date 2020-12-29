#' Build core targets for "indices" schema
#'
#' Take advantage of the [targets::tar_target_raw()] function, and looping over
#' all the preprocessing functions.
#'
#' @return All the targets required, containing dynamic patterns.
#' @importFrom rlang .data
#' @export
build_targets_indices <- function() {
  gameconfig %>%
    dplyr::filter(.data$game_name %in% get_game_names()) %>%
    dplyr::pull("prep_fun") %>%
    unique() %>%
    purrr::map(
      ~ targets::tar_target_raw(
        stringr::str_c("indices", .x, sep = "_"),
        rlang::call2(
          "calc_indices",
          data = rlang::expr(data),
          prep_fun = rlang::sym(.x)
        ),
        pattern = rlang::expr(map(data))
      )
    )
}

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
  tryCatch(
    purrr::chuck(config::get("where"), "content", "Name"),
    error = function(err) {
      if (stringr::str_detect(err$message, "config.yml")) {
        warning(err$message)
      }
      if (use_db) warning("`use_db` is not implemented yet.")
      return(NULL)
    }
  ) %||%
    dplyr::pull(gameconfig, "game_name")
}
