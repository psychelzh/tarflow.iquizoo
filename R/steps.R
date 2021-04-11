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
step_config <- function(file = "config.yml") {
  if (fs::file_exists(file)) {
    cli::cli_alert_info("{.file {file}} exists and skipped.")
  } else {
    usethis::use_template(file, package = utils::packageName())
  }
}

#' @rdname steps
step_pipeline <- function(schema, separate) {
  template_targets <- fs::path(
    "schemas",
    schema,
    ifelse(
      separate,
      fs::path("separate", "_targets.R"),
      "_targets.R"
    )
  )
  usethis::use_template(
    template_targets,
    save_as = "_targets.R",
    package = utils::packageName()
  )
}

#' @rdname steps
step_query <- function(schema, separate, dir) {
  usethis::use_directory(dir)
  templates_queries <- c(
    "users.tmpl.sql",
    switch(
      schema,
      original = ,
      indices = "data.tmpl.sql",
      scores = "scores.tmpl.sql"
    ),
    if (separate) "games.tmpl.sql"
  )
  purrr::walk(
    templates_queries,
    ~ usethis::use_template(
      fs::path(dir, .x),
      package = utils::packageName()
    )
  )
}

#' @rdname steps
step_gitignore <- function() {
  if (fs::file_exists(".gitignore")) {
    usethis::use_git_ignore("_targets")
  }
}
