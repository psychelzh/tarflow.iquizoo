#' Set up templates used to fetch data
#'
#' If you want to extract data based on your own parameters, you should use this
#' function to set up your own SQL templates. Note that the SQL queries should
#' be parameterized.
#'
#' @param contents The SQL template file used to fetch contents. At least
#'   `project_id` and `game_id` columns should be included in the fetched data
#'   based on the template. `project_id` will be used as the only parameter in
#'   `users` and `project` templates, while all three will be used in `raw_data`
#'   and `scores` templates.
#' @param users The SQL template file used to fetch users. Usually you don't
#'   need to change this.
#' @param raw_data The SQL template file used to fetch raw data. See
#'   [fetch_data()] for details. Usually you don't need to change this.
#' @param scores The SQL template file used to fetch scores. See [fetch_data()]
#'   for details. Usually you don't need to change this.
#' @param progress_hash The SQL template file used to fetch progress hash.
#'   Usually you don't need to change this.
#' @return A S3 object of class `tarflow.template` with the options.
#' @export
setup_templates <- function(contents = NULL,
                            users = NULL,
                            raw_data = NULL,
                            scores = NULL,
                            progress_hash = NULL) {
  structure(
    list(
      contents = contents %||% package_file("sql", "contents.sql"),
      users = users %||% package_file("sql", "users.sql"),
      raw_data = raw_data %||% package_file("sql", "raw_data.sql"),
      scores = scores %||% package_file("sql", "scores.sql"),
      progress_hash = progress_hash %||%
        package_file("sql", "progress_hash.sql")
    ),
    class = "tarflow.template"
  )
}

#' Check if the database based on the given data source is ready
#'
#' @param group Section identifier in the `default.file`. See
#'   [RMariaDB::MariaDB()] for more information.
#' @return TRUE if the database is ready, FALSE otherwise.
#' @export
check_source <- function(group = getOption("tarflow.group")) {
  return(DBI::dbCanConnect(RMariaDB::MariaDB(), group = group))
}

# nocov start

#' Setup MySQL database connection option file
#'
#' This function will create a MySQL option file at the given path. To ensure it
#' works, set these environment variables before calling this function:
#' - `MYSQL_HOST`: The host name of the MySQL server.
#' - `MYSQL_USER`: The user name of the MySQL server.
#' - `MYSQL_PASSWORD`: The password of the MySQL server.
#'
#' @param path The path to the option file. Default location is operating system
#'   dependent. On Windows, it is `C:/my.cnf`. On other systems, it is
#'   `~/.my.cnf`.
#' @param overwrite Whether to overwrite the existing option file.
#' @param quietly A logical indicates whether message should be suppressed.
#' @return NULL (invisible).
#' @export
setup_option_file <- function(path = NULL, overwrite = FALSE, quietly = FALSE) {
  my_cnf_tmpl <- read_file(package_file("database", "my.cnf.tmpl"))
  path <- path %||% default_file()
  if (file.exists(path) && !overwrite) {
    if (!quietly) {
      cli::cli_alert_warning(
        "Option file already exists. Use {.arg overwrite = TRUE} to overwrite.",
        class = "tarflow_option_file_exists"
      )
    }
    return(invisible())
  }
  writeLines(glue::glue(my_cnf_tmpl), path)
}

# helper functions
default_file <- function() {
  if (Sys.info()["sysname"] == "Windows") {
    return("C:/my.cnf")
  } else {
    return("~/.my.cnf")
  }
}

# nocov end

check_templates <- function(templates) {
  if (!inherits(templates, "tarflow.template")) {
    cli::cli_abort(
      "{.arg templates} must be created by {.fun setup_templates}.",
      class = "tarflow_bad_templates"
    )
  }
}
