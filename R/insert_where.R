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
insert_where.NULL <- function(old, ...) {
  stop(
    "You are trying to create new where configuration.",
    "Please use `tibble::tribble()` instead."
  )
}

#' @rdname insert_where
insert_where.list <- function(old, ..., replace = TRUE) {
  if (length(old) == 0) insert_where.NULL(old, ...)
  new <- purrr::map(list(...), ~ as.list(unlist(.x)))
  if (!all(purrr::map_lgl(new, ~ rlang::has_name(.x, "table")))) {
    stop("At least one of the new element has no name of 'table'.")
  }
  if (replace) {
    new_tables <- purrr::map_chr(new, ~ .x[["table"]])
    old[purrr::map_lgl(old, ~ .x[["table"]] %in% new_tables)] <- NULL
  }
  return(c(old, new))
}

#' @rdname insert_where
insert_where.data.frame <- function(old, ..., replace = TRUE) {
  if (nrow(old) == 0) insert_where.NULL(old, ...)
  old <- purrr::transpose(as.list(old))
  insert_where(old, ..., replace = replace) %>%
    purrr::transpose() %>%
    tibble::as_tibble() %>%
    tidyr::unnest(-.data[["values"]])
}
