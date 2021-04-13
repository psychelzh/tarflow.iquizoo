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
  codes <- rlang::exprs(
    tar_file(file_config, !!config_file),
    tar_target(
      !!rlang::sym(config_where),
      config::get("where", file = file_config)
    )
  )
  script$update("pipeline", codes)
}

#' @rdname steps
step_query <- function(schema, separate, script) {
  usethis::use_directory(query_dir)
  usethis::use_template(
    fs::path(query_dir, query_files[["users"]]),
    package = utils::packageName()
  )
  script$update("pipeline", .compose_query_target("users", fetch = TRUE))
  query_name_main <- switch(schema,
    scores = "scores",
    original = ,
    preproc = "data"
  )
  usethis::use_template(
    fs::path(query_dir, query_files[[query_name_main]]),
    package = utils::packageName()
  )
  script$update(
    "pipeline",
    .compose_query_target(query_name_main, fetch = !separate)
  )
  # when separate games should be searched before pipeline
  if (separate) {
    usethis::use_template(
      fs::path(query_dir, query_files[["games"]]),
      package = utils::packageName()
    )
    script$update(
      "pipeline",
      .compose_query_target("games", fetch = FALSE)
    )
  }
}

#' @rdname steps
step_pipeline <- function(schema, separate, script) {
  # tar_option_set()
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

.compose_query_target <- function(name_query, fetch) {
  tar_name_query <- rlang::sym(stringr::str_glue("query_tmpl_{name_query}"))
  c(
    rlang::exprs(
      tar_file(
        !!tar_name_query,
        fs::path(!!query_dir, !!query_files[[name_query]])
      )
    ),
    if (fetch) {
      rlang::exprs(
        tar_fst_tbl(
          !!rlang::sym(name_query),
          tarflow.iquizoo::fetch(
            !!tar_name_query,
            !!rlang::sym(config_where)
          )
        )
      )
    }
  )
}

build_separate_requirements <- function(schema, script) {
  path <- fs::path("~", stringr::str_c(".cache.", utils::packageName()))
  script$update("global", tar_global_text())
  script$update("targets", tar_targets_text(schema))
  script$update(
    "pipeline",
    switch(schema,
      scores = rlang::exprs(
        targets_scores,
        tar_combine(scores, targets_scores)
      ),
      original = rlang::exprs(
        targets_data,
        tar_combine(data, targets_data)
      ),
      preproc = rlang::exprs(
        targets_data,
        tar_combine(data, targets_data[[1]]),
        tar_combine(indices, targets_data[[2]])
      )
    )
  )
}
