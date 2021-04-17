#' Fetch datasets from given database
#'
#' Based on a template query file and "where clause" configuration, datasets are
#' extracted from a given database.
#'
#' @name fetch
#' @param query_file File name of `sql` query
#' @param config_where Configuration of "where-clause" of the `sql` query. Can
#'   be a `list` (mostly from the `config.yml` file) or `data.frame`.
#' @param dsn The data source name of an **ODBC** database connector. See
#'   [odbc::dbConnect()] for more information.
#' @return A [tibble][tibble::tibble-package] of the fetched data.
#' @author Liang Zhang
NULL

#' @describeIn fetch Default usage of fetch.
#' @export
fetch <- function(query_file, config_where = NULL, dsn = "iquizoo-v3") {
  enc <- ifelse(.Platform$OS.type == "windows", "gbk", "utf-8")
  # connect to given database which is pre-configured
  con <- DBI::dbConnect(odbc::odbc(), dsn, encoding = enc)
  on.exit(DBI::dbDisconnect(con))
  query <- readLines(query_file) %>%
    stringr::str_c(collapse = "\n") %>%
    stringr::str_glue(
      .envir = env(
        where_clause = compose_where(config_where)
      )
    )
  tibble::tibble(DBI::dbGetQuery(con, query))
}

#' @describeIn fetch A special case to fetch datasets from a single game.
#' @param game_id The identifier of the game to fetch datasets from.
#' @export
fetch_single_game <- function(query_file,
                              config_where = NULL,
                              game_id,
                              dsn = "iquizoo-v3") {
  fetch(
    query_file,
    insert_where(
      config_where,
      list(
        table = "content",
        field = "Id",
        values = game_id
      )
    )
  )
}
