#' Supported schemas
#'
#' Character vector. Name is used as a short memo. Developers should describe it
#' in detail in the value because it is displayed in the wizard.
#'
#' @keywords internal
schemas <- c(
  scores = "Download pre-calculated scores from database",
  original = "Download original data only",
  preproc = "Download original data and preprocess it"
)

#' Configuration file
#'
#' @keywords internal
config_file <- "config.yml"

#' Query files used
#'
#' Character vector. Name should be used as the name of the fetched object.
#'
#' @keywords internal
query_files <- c(
  users = "users.tmpl.sql",
  scores = "scores.tmpl.sql",
  data = "data.tmpl.sql",
  games = "games.tmpl.sql" # typically not in pipeline
)

#' Query directory name
#'
#' @keywords internal
query_dir <- "sql"
