## code to prepare `gamenames`(exported) and `game_config`(internal) dataset goes here
config <- readr::read_csv("data-raw/config.csv", col_types = readr::cols())
gameinfo <- config %>%
  dplyr::select(game_id, dplyr::starts_with("game_name"))
gameconfig <- config %>%
  dplyr::select(game_id, game_name, game_name_abbr, prep_fun)
usethis::use_data(gameinfo, overwrite = TRUE)
usethis::use_data(gameconfig, overwrite = TRUE, internal = TRUE)
