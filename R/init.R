#' Setup Workflow
#'
#' `r lifecycle::badge("experimental")` Create a basic infrastructure for
#' iquizoo data analysis.
#'
#' @param wizard A logical value indicating whether to use interactive
#'   operations. If `TRUE`, menus will be shown interactively.
#' @param schema The name of workflow to be used. Different name means different
#'   targets pipelines.
#' @param separate Should the database downloading be separated into branches
#'   based on games?
#' @return `NULL` (invisibly). This function is called for its side-effect.
#' @export
init <- function(wizard = interactive(), schema = "scores", separate = NULL) {
  cli::cli_alert("Welcome to {.pkg {utils::packageName()}}")
  script <- TarScript$new()
  if (wizard) {
    cli::cli_text("Some questions will be asked in advance, please take care.")
    schema <- .choose_schema(schemas)
    separate <- usethis::ui_yeah("Do you prefer to separate into branches?")
  } else {
    schema <- match.arg(schema, c("scores", "original", "preproc"))
    separate <- ifelse(schema == "scores", FALSE, TRUE)
  }
  #' @details
  #'
  #' These steps are done in order:
  #'
  #' 1. Prepare configuration file if not found. Configuration file is named as
  #' "config.yml", which is basically used to set the `where-clause` for
  #' database queries (`SQL`).
  cli::cli_rule("Prepare configuration file")
  step_config(script)
  cli::cli_alert_success("Done")
  #' 1. Prepare database query files (`SQL`). The major part of the whole work
  #' is just to download data from database, so for now, up to four query files
  #' are used. Note they are all *"templates"* only, cannot be used directly.
  cli::cli_rule("Prepare query files")
  step_query(schema, separate, script)
  cli::cli_alert_success("Done")
  #' 1. Prepare "_targets.R". Package targets parses commands from this R
  #' script, which plays a role as a workflow blueprint. In this step, users
  #' will be asked to choose which "schema" to use if `wizard` is `TRUE`,
  #' typically when in interactive mode.
  cli::cli_rule("Prepare pipeline file {.file _targets.R}")
  step_pipeline(schema, separate, script)
  cli::cli_alert_success("Done")
  #' 1. Add "_targets" to file .gitignore
  #' if found.
  cli::cli_rule("Update .gitignore")
  step_gitignore()
  cli::cli_alert_success("Done")
  #' 1. Manually check configuration file "config.yml".
  cli::cli_rule("Your turn")
  cli::cli_ul(
    c(
      "You'd better manually check {.file config.yml} using {.fn edit_config}.",
      paste(
        "After checking, please run {.fn targets::tar_make}",
        "or {.code targets::tar_make_future(works = <numeric>)} (for parallel)",
        "to start your analysis."
      )
    )
  )
  cli::cli_alert_success("All Done.")
  if (interactive()) {
    edit_config()
  }
  invisible()
}

.choose_schema <- function(choices, title) {
  choice <- utils::menu(
    choices,
    title = "Which action do you want to perform?"
  )
  stopifnot(choice != 0)
  names(schemas)[[choice]]
}
