tar_global_text <- function() {
  path <- fs::path("~", stringr::str_c(".cache.", utils::packageName()))
  readLines(
    fs::path(
      fs::path_package(utils::packageName()),
      "templates",
      "tar_text",
      "global.R"
    )
  ) %>%
    stringr::str_c(collapse = "\n") %>%
    stringr::str_glue()
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
