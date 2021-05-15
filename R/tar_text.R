tar_global_text <- function() {
  stringr::str_glue(
    "future::plan(future::multisession)",
    "games <- tarflow.iquizoo::search_games_mem(config::get(\"where\"))",
    .sep = "\n"
  )
}

tar_targets_text <- function(schema) {
  keyword <- switch(
    schema,
    scores = "scores",
    original = ,
    preproc = "data"
  )
  targets_name <- stringr::str_glue("targets_{keyword}")
  targets_body <- stringr::str_c(
    "tar_map(",
    stringr::str_c(
      "values = games",
      "names = game_name_abbr",
      stringr::str_glue(
        "tar_target({keyword}, ",
        "tarflow.iquizoo::fetch_single_game(",
        "query_tmpl_{keyword}, config_where, game_id))",
        .sep = "\n"
      ),
      if (schema == "preproc") {
        "tar_target(data_parsed, wrangle_data(data, by = key))"
      },
      if (schema == "preproc") {
        "tar_target(indices, preproc_data(data_parsed, prep_fun, by = key))"
      },
      sep = ",\n"
    ),
    ")",
    sep = "\n"
  )
  stringr::str_c(targets_name, "<-", targets_body)
}
