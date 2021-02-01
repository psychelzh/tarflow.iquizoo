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
    config_where_tbl <- tibble::tibble(where = config_where) %>%
      tidyr::unnest_wider("where")
    if (!rlang::has_name(config_where_tbl, "operator")) {
      config_where_tbl$operator <- NA_character_
    }
    where_base <- config_where_tbl %>%
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
    stringr::str_c("WHERE", where_base, sep = " ")
  }
}
