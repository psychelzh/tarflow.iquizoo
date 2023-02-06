#' Insert where configurations
#'
#' Insert new where configurations into the existed one. This can be useful in
#' many projects doing minor changes to current where configurations.
#'
#' @details
#'
#' This function is intended to modify an existed where configuration. If the
#' existed one [is_empty()][rlang::is_empty()], the added will be returned as a
#' [list()].
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
#' @export
insert_where <- function(old, ...) {
  UseMethod("insert_where")
}

#' @rdname insert_where
#' @export
insert_where.NULL <- function(old, ...) {
  return(parse_where(...))
}

#' @rdname insert_where
#' @export
insert_where.character <- function(old, ...) {
  new <- compose_where(parse_where(...), add_keyword = FALSE)
  paste(old, new, sep = " AND ")
}

#' @rdname insert_where
#' @export
insert_where.list <- function(old, ..., replace = TRUE) {
  if (is_empty(old)) {
    return(insert_where.NULL(old, ...))
  }
  new <- parse_where(...)
  if (replace) {
    new_tables <- purrr::map_chr(new, ~ .x[["table"]]) # nolint
    old[purrr::map_lgl(old, ~ .x[["table"]] %in% new_tables)] <- NULL
  }
  return(c(old, new))
}

#' @rdname insert_where
#' @export
insert_where.data.frame <- function(old, ..., replace = TRUE) {
  if (is_empty(old)) {
    new <- insert_where.NULL(old, ...)
  } else {
    new <- purrr::map_df(parse_where(...), as.data.frame)
    if (replace) {
      new <- dplyr::anti_join(new, old, by = "table")
    }
  }
  dplyr::bind_rows(old, new)
}

#' @describeIn insert_where Limit old where config to one single game.
#' @param game_id The identifier of the game to set the limitation.
#' @export
insert_where_single_game <- function(old, game_id) {
  insert_where(
    old,
    list(
      table = "content",
      field = "Id",
      values = game_id
    )
  )
}

parse_where <- function(...) {
  # TODO: known issue, do not support nested values
  where <- purrr::map(list(...), ~ as.list(unlist(.x)))
  if (!all(purrr::map_lgl(where, ~ has_name(.x, "table")))) {
    abort(
      "At least one of the new element has no name of 'table'.",
      "where_invalid"
    )
  }
  where
}
