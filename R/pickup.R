#' Download (pick up) datasets from given database
#'
#' Based on a template query file and "where clause" configuration, datasets are
#' extracted from a given database.
#'
#' @param query_file File name of `sql` query. Literal query is acceptable, and
#'   to be recognized as literal query, the input must be a string containing at
#'   least one new line.
#' @param config_where Configuration of "where-clause" of the `sql` query. Can
#'   be a `list` (mostly from the `config.yml` file) or `data.frame`.
#' @param dsn The data source name of an **ODBC** database connector. See
#'   [odbc::dbConnect()] for more information. Used when `drv` is set as
#'   [odbc::odbc()].
#' @param groups Section identifier in the `default.file`. See
#'   [RMariaDB::MariaDB()] for more information. Used when `drv` is set as
#'   [odbc::odbc()].
#' @param drv The driver used. Set as an option of `"tarflow.driver"` and the
#'   default is currently `odbc::odbc()`. Options are [odbc::odbc()] and
#'   [RMariaDB::MariaDB()], both of which need pre-configurations.
#' @param encoding Encoding to be assumed for input strings. Default to "UTF-8".
#' @return A [tibble][tibble::tibble-package] of the downloaded data.
#' @author Liang Zhang
#' @export
pickup <- function(query_file,
                   config_where = NULL,
                   dsn = "iquizoo-v3",
                   groups = "iquizoo-v3",
                   drv = getOption("tarflow.driver"),
                   encoding = "utf-8") {
  # connect to given database which is pre-configured
  con <- connect_to_db(drv, dsn = dsn, groups = groups)
  on.exit(DBI::dbDisconnect(con))
  query <- ifelse(
    stringr::str_detect(query_file, "\\n"),
    query_file,
    readLines(query_file, encoding = encoding) |>
      stringr::str_c(collapse = "\n")
  ) |>
    stringr::str_glue(
      .envir = env(
        where_clause = compose_where(config_where)
      )
    )
  tibble::tibble(DBI::dbGetQuery(con, query))
}

connect_to_db <- function(drv, ...) {
  check_dots_used()
  if (!inherits_any(drv, c("OdbcDriver", "MariaDBDriver"))) {
    stop("Driver must be either OdbcDriver or MariaDBDriver.")
  }
  dots <- list2(...)
  if (inherits(drv, "OdbcDriver")) {
    dsn <- dots$dsn %||% "iquizoo-v3"
    return(DBI::dbConnect(drv, dsn = dsn))
  }
  if (inherits(drv, "MariaDBDriver")) {
    groups <- dots$groups %||% "iquizoo-v3"
    return(DBI::dbConnect(drv, groups = groups))
  }
}
