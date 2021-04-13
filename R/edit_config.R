#' Edit configuration file
#'
#' Open file "config.yml" to make it proper for your analysis. If not found,
#' this function will create one.
#'
#' @return `NULL` (invisibly). This function is called for its side effect.
#' @export
edit_config <- function() {
  if (!fs::file_exists(config_file)) {
    usethis::use_template(config_file, package = utils::packageName())
  }
  usethis::edit_file(config_file)
}
