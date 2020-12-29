## code to prepare `gameinfo`(exported) and `gameconfig`(internal) datasets
config <- readr::read_csv("data-raw/config.csv", col_types = readr::cols())
gameinfo <- dplyr::select(config, game_id, dplyr::starts_with("game_name"))
gameconfig <- dplyr::select(config, game_id, game_name, prep_fun)
usethis::use_data(gameinfo, overwrite = TRUE)
usethis::use_data(gameconfig, overwrite = TRUE, internal = TRUE)
