#' Fetch original data from database
#'
#' Based on a template query file, original data based on given "where clause"
#' configuration (`where_config`) are extracted from IQUIZOO database. If
#' `where_config` is `NULL`, this will extract all data.
#'
#' @param query_file File name of `sql` query
#' @param config_where Configuration of "where-clause" of the `sql` query. Can
#'   be a `list` (mostly from the `config.yml` file) or `data.frame`.
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
  UseMethod("compose_where_clause")
}
compose_where_clause.default <- function(config_where) {
  config_where
}
compose_where_clause.NULL <- function(config_where) {
  compose_where_clause.default("")
}
compose_where_clause.character <- function(config_where) {
  compose_where_clause.default(config_where)
}
compose_where_clause.list <- function(config_where) {
  config_where_tbl <- tibble::tibble(where = config_where) %>%
    tidyr::unnest_wider("where")
  compose_where_clause(config_where_tbl)
}
compose_where_clause.data.frame <- function(config_where) {
  if (!rlang::has_name(config_where, "operator")) {
    config_where$operator <- NA_character_
  }
  where_base <- config_where %>%
    dplyr::mutate(
      operator = dplyr::case_when(
        is.na(.data$operator) & lengths(.data$values) == 1 ~ "=",
        is.na(.data$operator) & lengths(.data$values) > 1 ~ "IN",
        TRUE ~ .data$operator
      ),
      value_str = purrr::map_chr(
        .data$values,
        ~ if (length(.x) == 1) {
          stringr::str_c("'", .x, "'")
        } else {
          stringr::str_c(
            "(", stringr::str_c("'", .x, "'", collapse = ", "), ")"
          )
        }
      )
    ) %>%
    stringr::str_glue_data("{table}.{field} {operator} {value_str}") %>%
    stringr::str_c(collapse = " AND ")
  compose_where_clause.default(stringr::str_c("WHERE", where_base, sep = " "))
}
