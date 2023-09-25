#' Fetch data from iQuizoo database based on a parameterized query
#'
#' @param query A character string containing SQL.
#' @param params The parameters to be bound to the query. This parameter could
#'   be safely omitted if `query` does not contain any parameters.
#' @param ... Further arguments passed to [DBI::dbConnect()][DBI::dbConnect].
#' @param source The data source from which data is fetched. See
#'   [setup_source()] for details.
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_query <- function(query, params, ...,
                        source = setup_source()) {
  check_dots_used()
  if (missing(params)) {
    params <- list()
  }
  if (!inherits(source, "tarflow.source")) {
    cli::cli_abort("{.arg source} must be created by {.fun setup_source}.")
  }
  # connect to given database which is pre-configured
  if (!inherits_any(source$driver, c("OdbcDriver", "MariaDBDriver"))) {
    stop("Driver must be either OdbcDriver or MariaDBDriver.")
  }
  if (inherits(source$driver, "OdbcDriver")) {
    con <- DBI::dbConnect(source$driver, dsn = source$dsn, ...)
  }
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
#' @param course_date The course date. This parameter is used to determine the
#'    table name, not to be bound to the query.
#' @param ... Further arguments passed to [fetch_query()].
#' @param what What to fetch. Can be either "raw_data" or "scores".
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_data <- function(query, project_id, game_id, course_date, ...,
                       what = c("raw_data", "scores")) {
  check_dots_used()
  what <- match.arg(what)
  fetch_query(
    stringr::str_glue(
      query,
      .envir = env(
        table_name = paste0(
          switch(what,
            raw_data = "content_orginal_data_",
            scores = "content_ability_score_"
          ),
          format(as.POSIXct(course_date), "%Y0101")
        )
      )
    ),
    list(project_id, game_id),
    ...
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
