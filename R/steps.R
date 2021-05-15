#' Basic Steps
#'
#' [step_config()] checks if "config.yml" file exists, and create it if not
#' found. [step_pipeline()] match pipeline file (i.e., "_targets.R") and add it.
#' [step_query()] adds the required `SQL` query template files.
#' [step_gitignore()] adds `_targets` to .gitignore file if found.
#'
#' @name steps
#' @keywords internal
NULL

#' @rdname steps
step_config <- function(script) {
  if (fs::file_exists(config_file)) {
    cli::cli_alert_info("{.file {config_file}} exists and skipped.")
  } else {
    usethis::use_template(config_file, package = utils::packageName())
  }
  script$update(
    "pipeline",
    c(
      call2("tar_file", sym("file_config"), config_file),
      call2(
        "tar_target", sym("config_where"),
        call2(quote(config::get), "where", file = sym("file_config"))
      )
    )
  )
}

#' @rdname steps
step_query <- function(schema, separate, script) {
  usethis::use_directory(query_dir)
  names_query <- c(
    "users",
    switch(
      schema,
      scores = c("scores", "abilities"),
      original = ,
      preproc = "data"
    ),
    if (separate) "games"
  )
  do_fetch <- ifelse(
    names_query == "abilities",
    TRUE, names_query != "games" & !separate
  )
  purrr::walk2(names_query, do_fetch, .do_step_query, script = script)
}

#' @rdname steps
step_pipeline <- function(schema, separate, script) {
  # targets options
  if (schema == "preproc") {
    script$update(
      "option",
      list(package = c("tidyverse", "dataproc.iquizoo"))
    )
    script$update(
      "option",
      list(imports = "dataproc.iquizoo")
    )
  } else {
    script$update("option", list(package = "tidyverse"))
  }
  # some special parts used when separating
  if (separate) {
    build_separate_requirements(schema, script)
  }
  script$build()
}

#' @rdname steps
step_gitignore <- function() {
  if (fs::file_exists(".gitignore")) {
    usethis::use_git_ignore("_targets")
  }
}

.do_step_query <- function(name_query, fetch, script) {
  usethis::use_template(
    fs::path(query_dir, query_files[[name_query]]),
    package = utils::packageName()
  )
  script$update("pipeline", .compose_query_target(name_query, fetch))
}

.compose_query_target <- function(name_query, fetch) {
  tar_name_query <- sym(stringr::str_glue("query_tmpl_{name_query}"))
  c(
    call2(
      "tar_file", tar_name_query,
      call2(quote(fs::path), query_dir, query_files[[name_query]])
    ),
    if (fetch) {
      call2(
        "tar_target", sym(name_query),
        call2(
          quote(tarflow.iquizoo::fetch),
          tar_name_query, sym("config_where")
        )
      )
    }
  )
}

build_separate_requirements <- function(schema, script) {
  script$update("global", tar_global_text())
  script$update("targets", tar_targets_text(schema))
  script$update(
    "pipeline",
    switch(
      schema,
      scores = c(
        sym("targets_scores"),
        call2("tar_combine", sym("scores"), sym("targets_scores"))
      ),
      # do not combine these data on default
      original = sym("targets_data"),
      preproc = c(
        call2("key", ".id"),
        sym("targets_data")
      )
    )
  )
}

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
