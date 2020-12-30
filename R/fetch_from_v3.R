#' Fetch original data from database
#'
#' Based on a template query file, original data based on given "where clause"
#' configuration (`where_config`) are extracted from IQUIZOO database. If
#' `where_config` is `NULL`, this will extract all data.
#'
#' @param query_file File name of `sql` query
#' @param config_where A `list` storing configuration of `where-clause`
#' @return A `tibble` of original data
#' @author Liang Zhang
#' @importFrom rlang .data
#' @export
fetch_from_v3 <- function(query_file, config_where = NULL) {
  enc <- ifelse(.Platform$OS.type == "windows", "gbk", "utf-8")
  # connect to given database which is pre-configured
  con <- DBI::dbConnect(odbc::odbc(), "iquizoo-v3", encoding = enc)
  on.exit(DBI::dbDisconnect(con))
  # `where_clause` is used in query template
  where_clause <- compose_where_clause(config_where)
  query <- query_file %>%
    readr::read_file() %>%
    stringr::str_glue()
  tibble::tibble(DBI::dbGetQuery(con, query))
}

compose_where_clause <- function(config_where) {
  if (is.null(config_where)) {
    return("")
  } else {
    where_base <- config_where %>%
      tibble::enframe(name = "table", value = "sel") %>%
      dplyr::mutate(
        sel = purrr::map(
          .data$sel,
          ~ enframe(.x, name = "column", value = "value")
        )
      ) %>%
      tidyr::unnest(.data$sel) %>%
      dplyr::mutate(
        op = dplyr::if_else(lengths(.data$value) == 1, "=", "IN"),
        value_str = purrr::map_chr(
          .data$value,
          ~ stringr::str_c("(", stringr::str_c("'", .x, "'", collapse = ", "), ")")
        )
      ) %>%
      stringr::str_glue_data("{table}.{column} {op} {value_str}") %>%
      stringr::str_c(collapse = " AND ")
    stringr::str_c("WHERE", where_base, sep = " ")
  }
}
