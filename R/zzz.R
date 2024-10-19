# nocov start

.onLoad <- function(libname, pkgname) {
  # setup options
  op <- options()
  op_tarflow <- list(tarflow.group = "iquizoo-v3")
  toset <- !(names(op_tarflow) %in% names(op))
  if (any(toset)) options(op_tarflow[toset])

  # try setting up option file if source not working
  if (!check_source()) {
    tryCatch(setup_option_file(quietly = TRUE), error = \(e) {})
  }

  invisible()
}

.onAttach <- function(libname, pkgname) {
  if (!check_source()) {
    packageStartupMessage(
      "The default database source is not working.",
      " Please check your database settings first.",
      " See `?setup_option_file` for more details."
    )
  }
}

# nocov end
