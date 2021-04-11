#' Edit configuration file
#'
#' Open file "config.yml" to make it proper for your analysis. If not found,
#' this function will create one.
#'
#' @param file The configuration file name.
#' @return `NULL` (invisibly). This function is called for its side effect.
#' @export
edit_config <- function(file = "config.yml") {
  if (!fs::file_exists(file)) {
    usethis::use_template(file, package = utils::packageName())
  }
  usethis::edit_file(file)
}
