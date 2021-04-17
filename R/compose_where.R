#' Compose where clause for database query
#'
#' Here we just compose "where-clause" according to tables in the database.
#'
#' In reality, this is mostly combined with a `yaml` configurations whose
#' template lives in this package, which forms an input of `list` data type. But
#' it can also handle situations with `character` and `data.frame` input.
#'
#' @param config_where Configuration of "where-clause".
#' @return A "where-clause" character which is directly used in database query.
#' @author Liang Zhang
#' @keywords internal
compose_where <- function(config_where) {
  UseMethod("compose_where")
}

#' @rdname compose_where
compose_where.default <- function(config_where) {
  config_where
}

#' @rdname compose_where
compose_where.NULL <- function(config_where) {
  compose_where.default("")
}

#' @rdname compose_where
compose_where.character <- function(config_where) {
  compose_where.default(config_where)
}

#' @rdname compose_where
compose_where.list <- function(config_where) {
  config_where_tbl <- tibble::tibble(where = config_where) %>%
    tidyr::unnest_wider("where")
  compose_where(config_where_tbl)
}

#' @rdname compose_where
compose_where.data.frame <- function(config_where) {
  if (!has_name(config_where, "operator")) {
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
  compose_where.default(stringr::str_c("WHERE", where_base, sep = " "))
}
