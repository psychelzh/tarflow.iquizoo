#' Fetch data from iQuizoo database based on a parameterized query
#'
#' @param query The query to be executed.
#' @param params The parameters to be bound to the query.
#' @param ... Further arguments passed to [DBI::dbConnect()][DBI::dbConnect].
#' @param source The data source from which data is fetched. See [set_source()]
#'   for details.
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_parameterized <- function(query, params, ...,
                                source = set_source()) {
  check_dots_used()
  if (!inherits(source, "tarflow.source")) {
    cli::cli_abort("{.arg source} must be created by {.fun set_source}.")
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
  result <- DBI::dbSendQuery(con, query)
  on.exit(DBI::dbClearResult(result))
  DBI::dbBind(result, params)
  DBI::dbFetch(result)
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
set_source <- function(driver = getOption("tarflow.driver"),
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
