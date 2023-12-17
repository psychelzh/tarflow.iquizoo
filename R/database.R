#' Fetch result of query from iQuizoo database
#'
#' @param query A character string containing SQL.
#' @param ... Further arguments passed to [DBI::dbConnect()].
#' @param params The parameters to be bound to the query. Default to `NULL`, see
#'   [DBI::dbGetQuery()] for more details.
#' @param source The data source from which data is fetched. See
#'   [setup_source()] for details.
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_iquizoo <- function(query, ...,
                          params = NULL,
                          source = setup_source()) {
  check_dots_used()
  if (!inherits(source, "tarflow.source")) {
    cli::cli_abort(
      "{.arg source} must be created by {.fun setup_source}.",
      class = "tarflow_bad_source"
    )
  }
  # connect to given database which is pre-configured
  if (!inherits_any(source$driver, c("OdbcDriver", "MariaDBDriver"))) {
    cli::cli_abort(
      "Driver must be either OdbcDriver or MariaDBDriver.",
      class = "tarflow_bad_driver"
    )
  }
  # nocov start
  if (inherits(source$driver, "OdbcDriver")) {
    con <- DBI::dbConnect(source$driver, dsn = source$dsn, ...)
  }
  # nocov end
  if (inherits(source$driver, "MariaDBDriver")) {
    con <- DBI::dbConnect(source$driver, groups = source$groups, ...)
  }
  on.exit(DBI::dbDisconnect(con))
  DBI::dbGetQuery(con, query, params = params)
}

#' Fetch data from iQuizoo database
#'
#' @param query A parameterized SQL query. Note the query should also contain
#'   a `glue` expression to inject the table name, i.e., `"{ table_name }"`.
#' @param project_id The project id to be bound to the query.
#' @param game_id The game id to be bound to the query.
#' @param ... Further arguments passed to [fetch_iquizoo()].
#' @param what What to fetch. Can be either "raw_data" or "scores".
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_data <- function(query, project_id, game_id, ...,
                       what = c("raw_data", "scores")) {
  check_dots_used()
  what <- match.arg(what)
  # the database stores data from each year into a separate table with the
  # suffix of course date with the format "<year>0101"
  suffix <- package_file("sql", "project_date.sql") |>
    read_file() |>
    fetch_iquizoo(params = project_id) |>
    .subset2("project_date") |>
    format("%Y0101")
  table_name <- paste0(
    switch(what,
      raw_data = "content_orginal_data_",
      scores = "content_ability_score_"
    ),
    suffix
  )
  fetch_iquizoo(
    stringr::str_glue(
      query,
      .envir = env(table_name = table_name)
    ),
    ...,
    params = list(project_id, game_id)
  )
}

#' Set data source
#'
#' @param driver The driver used. Set as an option of `"tarflow.driver"`.
#'   Options are [odbc::odbc()] and [RMariaDB::MariaDB()], both of which need
#'   pre-configurations. Default to first available one.
#' @param dsn The data source name of an **ODBC** database connector. See
#'   [odbc::dbConnect()] for more information. Used when `driver` is set as
#'   [odbc::odbc()].
#' @param groups Section identifier in the `default.file`. See
#'   [RMariaDB::MariaDB()] for more information. Used when `driver` is set as
#'   [RMariaDB::MariaDB()].
#' @return An S3 class of `tarflow.source` with the options.
#' @export
setup_source <- function(driver = getOption("tarflow.driver"),
                         dsn = getOption("tarflow.dsn"),
                         groups = getOption("tarflow.groups")) {
  structure(
    list(
      driver = driver,
      dsn = dsn,
      groups = groups
    ),
    class = "tarflow.source"
  )
}

#' Check if the database based on the given data source is ready
#'
#' @param source The data source from which data is fetched. See
#'    [setup_source()] for details.
#' @return TRUE if the database is ready, FALSE otherwise.
#' @export
check_source <- function(source = setup_source()) {
  if (!inherits(source, "tarflow.source")) {
    cli::cli_abort(
      "{.arg source} must be created by {.fun setup_source}.",
      class = "tarflow_bad_source"
    )
  }
  # nocov start
  if (inherits(source$driver, "OdbcDriver")) {
    return(DBI::dbCanConnect(source$driver, dsn = source$dsn))
  }
  # nocov end
  if (inherits(source$driver, "MariaDBDriver")) {
    return(DBI::dbCanConnect(source$driver, groups = source$groups))
  }
  return(FALSE)
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
  writeLines(stringr::str_glue(my_cnf_tmpl), path)
}

#' @describeIn fetch_iquizoo The same as [fetch_iquizoo()] except that the
#'   result is cached.
#' @export
fetch_iquizoo_mem <- memoise::memoise(
  fetch_iquizoo,
  cache = switch(Sys.getenv("TARFLOW_CACHE", "disk"),
    disk = memoise::cache_filesystem("~/.tarflow.cache"),
    memory = memoise::cache_memory()
  )
)

# helper functions
default_file <- function() {
  if (Sys.info()["sysname"] == "Windows") {
    return("C:/my.cnf")
  } else {
    return("~/.my.cnf")
  }
}

# nocov end
