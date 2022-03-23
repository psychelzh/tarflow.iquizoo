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
#'   [odbc::dbConnect()] for more information.
#' @param encoding Encoding to be assumed for input strings. Default to "UTF-8".
#' @return A [tibble][tibble::tibble-package] of the downloaded data.
#' @author Liang Zhang
#' @export
pickup <- function(query_file,
                   config_where = NULL,
                   dsn = "iquizoo-v3",
                   encoding = "utf-8") {
  # connect to given database which is pre-configured
  con <- DBI::dbConnect(
    odbc::odbc(), dsn,
    encoding = ifelse(
      .Platform$OS.type == "windows",
      "gbk", "utf-8"
    )
  )
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
