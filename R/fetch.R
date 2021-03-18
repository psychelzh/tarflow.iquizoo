#' Fetch datasets from given database
#'
#' Based on a template query file and "where clause" configuration, datasets are
#' extracted from a given database.
#'
#' @param query_file File name of `sql` query
#' @param config_where Configuration of "where-clause" of the `sql` query. Can
#'   be a `list` (mostly from the `config.yml` file) or `data.frame`.
#' @param dsn Data source name of an `odbc` database connector.
#' @return A `tibble` of original data
#' @author Liang Zhang
#' @importFrom rlang .data
#' @export
fetch <- function(query_file, config_where = NULL, dsn = "iquizoo-v3") {
  enc <- ifelse(.Platform$OS.type == "windows", "gbk", "utf-8")
  # connect to given database which is pre-configured
  con <- DBI::dbConnect(odbc::odbc(), dsn, encoding = enc)
  on.exit(DBI::dbDisconnect(con))
  # `where_clause` is used in query template
  where_clause <- compose_where(config_where)
  query <- query_file %>%
    readr::read_file() %>%
    stringr::str_glue()
  tibble::tibble(DBI::dbGetQuery(con, query))
}
