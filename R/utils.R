#' Get the names of the user properties.
#'
#' @return A character vector of the names.
#' @export
get_users_props_names <- function() {
  users_props$alias # nolint nocov
}

package_file <- function(type, file) {
  system.file(
    type, file,
    package = "tarflow.iquizoo"
  )
}

read_file <- function(file) {
  paste0(readLines(file), collapse = "\n")
}
