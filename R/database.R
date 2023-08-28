#' Fetch data from iQuizoo database
#'
#' @param project_id The project id.
#' @param game_id The game id.
#' @param course_date The course date.
#' @param ... Leave for future usage. Should be empty.
#' @param what What to fetch. Can be either "raw_data" or "scores".
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_data <- function(project_id, game_id, course_date, ...,
                       what = c("raw_data", "scores")) {
  check_dots_empty()
  what <- match.arg(what)
  prefix <- switch(what,
    raw_data = "content_orginal_data_",
    scores = "content_ability_score_"
  )
  # name injection in the query
  tbl_data <- paste0(prefix, format(course_date, "%Y"), "0101")
  sql_file <- switch(what,
    raw_data = "fetch_raw_data_glue.sql",
    scores = "fetch_scores_glue.sql"
  )
  query <- read_sql_file(sql_file) |>
    stringr::str_glue(.envir = env(tbl_data = tbl_data))
  fetch_parameterized(query, list(project_id, game_id))
}

#' Fetch configuration table from iQuizoo database
#'
#' @param params The parameters to be bound to the query. Must be a list of
#'   length 2, containing course name and course period, in that order.
#' @return A [data.frame] contains the fetched data.
#' @keywords internal
fetch_config_tbl <- function(params) {
  stopifnot("Must specify only course name and course period, in that order." =
              length(params) == 2)
  query <- read_sql_file("course_contents.sql")
  fetch_parameterized(query, params)
}

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
                                dsn = "iquizoo-v3",
                                groups = "iquizoo-v3",
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

read_sql_file <- function(file) {
  system.file(
    "sql", file,
    package = "tarflow.iquizoo"
  ) |>
    readLines() |>
    paste0(collapse = "\n")
}
