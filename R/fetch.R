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
#' @param encoding Encoding to be assumed for input strings. Default to "UTF-8".
#' @return A [tibble][tibble::tibble-package] of the fetched data.
#' @author Liang Zhang
NULL

#' @describeIn fetch Default usage of fetch.
#' @export
fetch <- function(query_file,
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
  query <- readLines(query_file, encoding = encoding) |>
    stringr::str_c(collapse = "\n") |>
    stringr::str_glue(
      .envir = env(
        where_clause = compose_where(config_where)
      )
    )
  tibble::tibble(DBI::dbGetQuery(con, query))
}

#' @describeIn fetch A special case to fetch datasets from a single game.
#' @param game_id The identifier of the game to fetch datasets from.
#' @param ... Other arguments passed to [fetch()].
#' @export
fetch_single_game <- function(query_file, game_id,
                              config_where = NULL, ...) {
  fetch(
    query_file,
    insert_where(
      config_where,
      list(
        table = "content",
        field = "Id",
        values = game_id
      )
    ),
    ...
  )
}

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
#' @export
compose_where.default <- function(config_where) {
  config_where
}

#' @rdname compose_where
#' @export
compose_where.NULL <- function(config_where) {
  compose_where.default("")
}

#' @rdname compose_where
#' @export
compose_where.character <- function(config_where) {
  compose_where.default(config_where)
}

#' @rdname compose_where
#' @export
compose_where.list <- function(config_where) {
  config_where_tbl <- tibble::tibble(where = config_where) |>
    tidyr::unnest_wider("where")
  compose_where(config_where_tbl)
}

#' @rdname compose_where
#' @export
compose_where.data.frame <- function(config_where) {
  if (!has_name(config_where, "operator")) {
    config_where$operator <- NA_character_
  }
  where_base <- config_where |>
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
    ) |>
    stringr::str_glue_data("{table}.{field} {operator} {value_str}") |>
    stringr::str_c(collapse = " AND ")
  compose_where.default(stringr::str_c("WHERE", where_base, sep = " "))
}

#' Insert where configurations
#'
#' Insert new where configurations into the existed one. This can be useful in
#' many projects doing minor changes to current where configurations.
#'
#' @details
#'
#' This function is intended to modify an existed where configuration. To create
#' a completely new one, please specify it by using [tibble::tribble()] instead.
#'
#' If you insisted on calling [insert_where()] with empty where configration, it
#' will signal an error.
#'
#' @param old The old where configuration.
#' @param ... The new where element. Can be of `list` or `data.frame` class.
#'   Note they must have name of `"table"`. What's more, to make it work
#'   properly in the whole project, the names should be no other than
#'   `c("table", "field", "operator", "values")`.
#' @param replace Replace the element with the same `table` value or not.
#'   Default is set to replace, set `FALSE` to add it anyway (not recommended,
#'   might cause error in further analysis).
#' @return A where configuration of the same format with the old one.
#' @author Liang Zhang
#' @keywords internal
insert_where <- function(old, ...) {
  UseMethod("insert_where")
}

#' @rdname insert_where
#' @export
insert_where.NULL <- function(old, ...) {
  stop(
    "You are trying to create new where configuration.",
    "Please use `tibble::tribble()` instead."
  )
}

#' @rdname insert_where
#' @export
insert_where.list <- function(old, ..., replace = TRUE) {
  if (length(old) == 0) insert_where.NULL(old, ...)
  new <- purrr::map(list(...), ~ as.list(unlist(.x)))
  if (!all(purrr::map_lgl(new, ~ has_name(.x, "table")))) {
    stop("At least one of the new element has no name of 'table'.")
  }
  if (replace) {
    new_tables <- purrr::map_chr(new, ~ .x[["table"]])
    old[purrr::map_lgl(old, ~ .x[["table"]] %in% new_tables)] <- NULL
  }
  return(c(old, new))
}

#' @rdname insert_where
#' @export
insert_where.data.frame <- function(old, ..., replace = TRUE) {
  if (nrow(old) == 0) insert_where.NULL(old, ...)
  old <- purrr::transpose(as.list(old))
  insert_where(old, ..., replace = replace) |>
    purrr::transpose() |>
    tibble::as_tibble() |>
    tidyr::unnest(-.data[["values"]])
}
