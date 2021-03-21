#' Add specific targets to workflow
#'
#' Add some pre-defined targets to your workflow.
#'
#' @param schema The name of your jobs. 'indices' means calculate game indices
#'   from rawdata, mostly for scholar usage; 'scores' means extracting the
#'   scores directly from online database, mostly for norm calculation and
#'   report generation; 'original' fetches raw data only.
#' @param separate Separate main targets into branches or not. For `"indices"`
#'   and `"original"` schema, the default is set to `TRUE`. For `"scores"`
#'   schema, the default is set to `FALSE`. Note, when setting to `TRUE`,
#'   package "dataproc.iquizoo" is required and its version should be `"0.2.6"`
#'   or higher.
#' @author Liang Zhang
#' @export
use_targets <- function(schema = c("indices", "scores", "original"),
                        separate = NULL) {
  schema <- match.arg(schema)
  # set `separate` default to FALSE for a schema of "scores"
  if (is.null(separate)) {
    separate <- ifelse(schema == "scores", FALSE, TRUE)
  }
  stopifnot(rlang::is_scalar_logical(separate))
  # check package availability
  if (separate &
      !requireNamespace(
        "dataproc.iquizoo",
        versionCheck = list(op = ">=", version = "0.2.6"),
        quietly = TRUE
      ))
    stop("When setting 'separate' to `TRUE`. ",
         "Please make sure package 'dataproc.iquizoo' ",
         "of version 0.2.6 or higher is available.")
  # prepare names of templates to be used
  templates_query <- c(
    "sql/users.tmpl.sql",
    switch(
      schema,
      original = ,
      indices = "sql/data.tmpl.sql",
      scores = "sql/scores.tmpl.sql"
    ),
    if (separate) "sql/games.tmpl.sql"
  )
  template_targets <- file.path(
    "schemas", schema,
    ifelse(separate, file.path("separate", "_targets.R"), "_targets.R")
  )
  # trigger side effects
  # add required query files
  usethis::use_directory("sql")
  purrr::walk(
    templates_query,
    ~ usethis::use_template(.x, package = "tarflow.iquizoo")
  )
  usethis::ui_done("Added query files for fetching datasets.")
  # add configuration files
  if (!file.exists("config.yml")) {
    usethis::use_template("config.yml", package = "tarflow.iquizoo")
    usethis::ui_done("Added config file template.")
    usethis::ui_todo(
      paste("You probably need to edit the config file",
            "{usethis::ui_value('config.yml')}.")
    )
  }
  # add targets file
  usethis::use_template(
    template_targets,
    save_as = "_targets.R",
    package = "tarflow.iquizoo"
  )
  usethis::ui_done("Added {usethis::ui_value('_targets.R')}.")
  # ignore targets internal files
  usethis::use_git_ignore("_targets")
  usethis::ui_done(
    paste("All work done.",
          "Please run {usethis::ui_code('targets::tar_make()')}",
          "after editting {usethis::ui_value('config.yml')}.")
  )
}
