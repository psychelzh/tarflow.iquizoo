#' Add specific targets to workflow
#'
#' Add some pre-defined targets to your workflow.
#'
#' @param schema The name of your jobs. 'indices' means calculate game idices
#'   from rawdata, mostly for scholar usage; and 'scores' means extracting the
#'   scores directly from online database, mostly for norm calculation and
#'   report generation.
#' @author Liang Zhang
#' @export
use_targets <- function(schema = c("indices", "scores")) {
  schema <- match.arg(schema)
  if ("indices" == schema) {
    # add required query files
    usethis::use_directory("sql")
    usethis::use_template("sql/data.tmpl.sql", package = "tarflow.iquizoo")
    usethis::use_template("sql/users.tmpl.sql", package = "tarflow.iquizoo")
    usethis::ui_done("Added query files for raw data and users fetching.")
    # add configuration files
    usethis::use_template("config.yml", package = "tarflow.iquizoo")
    usethis::ui_done("Added basic config file.")
    usethis::ui_todo("You probably need to edit the config file {usethis::ui_value('config.yml')}.")
    # add targets file
    usethis::use_template("_targets_indices.R", save_as = "_targets.R", package = "tarflow.iquizoo")
    # ignore targets internal files
    usethis::use_git_ignore("_targets")
  }
  if ("scores" == schema) {
    # add required query files
    usethis::use_directory("sql")
    usethis::use_template("sql/scores.tmpl.sql", package = "tarflow.iquizoo")
    usethis::use_template("sql/users.tmpl.sql", package = "tarflow.iquizoo")
    usethis::ui_done("Added query files for scores and users fetching.")
    # add configuration files
    usethis::use_template("config.yml", package = "tarflow.iquizoo")
    usethis::ui_done("Added basic config file.")
    usethis::ui_todo("You probably need to edit the config file {usethis::ui_value('config.yml')}.")
    # add targets file
    usethis::use_template("_targets_scores.R", save_as = "_targets.R", package = "tarflow.iquizoo")
    # ignore targets internal files
    usethis::use_git_ignore("_targets")
  }
}
