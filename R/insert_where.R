#' Insert where configurations
#'
#' Insert new where configurations into the existed one. This can be useful in
#' many projects doing minor changes to current where configurations.
#'
#' This function is intended to modify an existed where configuration. To create
#' a completely new one, please specify it by using [tibble::tribble()] instead.
#'
#' @param old The old where configuration.
#' @param element The new where element. Can be a `list` or `data.frame`. `NULL`
#'   is accepted so that returns an unchanged version of the old config.
#' @param ... Other argument kept for future use. Currently, they are silently
#'   ignored.
#' @param replace Replace the element with the same `table` value or not.
#'   Default is set to replace, set `FALSE` to add it anyway (not recommended,
#'   might cause error in further analysis).
#' @return A where configuration of the same format with the old one.
#' @author Liang Zhang
#' @rdname insert_where
#' @export
insert_where <- function(old, ...) {
  UseMethod("insert_where")
}

#' @rdname insert_where
#' @exportS3Method insert_where
insert_where.NULL <- function(old, ...) {
  NULL
}

#' @rdname insert_where
#' @exportS3Method insert_where
insert_where.list <- function(old, element, ..., replace = TRUE) {
  if (is.null(element)) {
    return(old)
  }
  element <- as.list(unlist(element))
  if (replace) {
    old[purrr::map_lgl(old, ~ .x[["table"]] == element[["table"]])] <- NULL
  }
  return(c(old, list(element)))
}

#' @rdname insert_where
#' @exportS3Method insert_where
insert_where.data.frame <- function(old, element, ..., replace = TRUE) {
  if (is.null(element)) {
    return(old)
  }
  old <- as.list(old) %>% purrr::transpose()
  insert_where(old, element, ..., replace = replace) %>%
    purrr::transpose() %>%
    tibble::as_tibble() %>%
    tidyr::unnest(-.data[["values"]])
}
