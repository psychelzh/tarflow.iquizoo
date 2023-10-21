expect_targets_list <- function(targets) {
  act <- quasi_label(rlang::enquo(targets), arg = "targets")
  if (!is.list(act$val)) {
    fail(sprintf("%s should be a list, not a %s.", act$lab, typeof(act$val)))
  }
  if (!all(purrr::map_lgl(unlist(act$val), \(x) inherits(x, "tar_target")))) {
    fail(sprintf("All elements of %s should be valid target objects.", act$lab))
  }
  succeed()
  invisible(act$val)
}
