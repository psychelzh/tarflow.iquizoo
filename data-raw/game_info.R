## code to prepare `gameinfo`(exported) and `gameconfig`(internal) datasets
game_info <- readr::read_csv(
  "data-raw/game_info.csv",
  col_types = readr::cols()
)
usethis::use_data(game_info, overwrite = TRUE)
