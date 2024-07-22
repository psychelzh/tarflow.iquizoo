expect_targets_list <- function(targets) {
  act <- testthat::quasi_label(rlang::enquo(targets), arg = "targets")
  if (!is.list(act$val)) {
    testthat::fail(
      sprintf("%s should be a list, not a %s.", act$lab, typeof(act$val))
    )
  }
  for (val in unlist(act$val)) {
    if (!inherits(val, "tar_target")) {
      testthat::fail(
        sprintf("All elements of %s should be valid target objects.", act$lab)
      )
    }
  }
  testthat::succeed()
  invisible(act$val)
}
