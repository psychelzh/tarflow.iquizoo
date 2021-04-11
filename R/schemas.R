#' @keywords internal
schemas <- c(
  scores = "Download pre-calculated scores from database",
  original = "Download original data only",
  preproc = "Download original data and preprocess it"
)

#' @keywords internal
choose_schema <- function(choices, title) {
  choice <- utils::menu(choices, title = title)
  stopifnot(choice != 0)
  names(schemas)[[choice]]
}
