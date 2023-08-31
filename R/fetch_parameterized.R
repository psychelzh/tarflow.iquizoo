#' Fetch data from iQuizoo database based on a parameterized query
#'
#' @param query The query to be executed.
#' @param params The parameters to be bound to the query.
#' @param ... Further arguments passed to [DBI::dbConnect()][DBI::dbConnect].
#' @param dsn The data source name of an **ODBC** database connector. See
#'   [odbc::dbConnect()] for more information. Used when `drv` is set as
#'   [odbc::odbc()].
#' @param groups Section identifier in the `default.file`. See
#'   [RMariaDB::MariaDB()] for more information. Used when `drv` is set as
#'   [RMariaDB::MariaDB()].
#' @param drv The driver used. Set as an option of `"tarflow.driver"` and the
#'   default is currently `odbc::odbc()`. Options are [odbc::odbc()] and
#'   [RMariaDB::MariaDB()], both of which need pre-configurations.
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_parameterized <- function(query, params, ...,
                                dsn = getOption("tarflow.dsn"),
                                groups = getOption("tarflow.groups"),
                                drv = getOption("tarflow.driver")) {
  check_dots_used()
  # connect to given database which is pre-configured
  if (!inherits_any(drv, c("OdbcDriver", "MariaDBDriver"))) {
    stop("Driver must be either OdbcDriver or MariaDBDriver.")
  }
  if (inherits(drv, "OdbcDriver")) {
    con <- DBI::dbConnect(drv, dsn = dsn, ...)
  }
  if (inherits(drv, "MariaDBDriver")) {
    con <- DBI::dbConnect(drv, groups = groups, ...)
  }
  on.exit(DBI::dbDisconnect(con))
  result <- DBI::dbSendQuery(con, query)
  on.exit(DBI::dbClearResult(result))
  DBI::dbBind(result, params)
  DBI::dbFetch(result)
}
