tar_global_text <- function() {
  stringr::str_glue(
    "future::plan(future::multisession)",
    "games <- tarflow.iquizoo::search_games_mem(config::get(\"where\"))",
    .sep = "\n"
  )
}

tar_targets_text <- function(schema) {
  readLines(
    fs::path(
      fs::path_package(utils::packageName()),
      "templates",
      "tar_text",
      stringr::str_glue("targets_{schema}.R")
    )
  ) %>%
    stringr::str_c(collapse = "\n") %>%
    stringr::str_glue()
}
