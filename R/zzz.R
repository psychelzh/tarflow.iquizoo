#' @import rlang
NULL

# nocov start

.onLoad <- function(libname, pkgname) {
  # options
  op <- options()
  name_db_src_default <- "iquizoo-v3"
  if (requireNamespace("RMariaDB", quietly = TRUE)) {
    op_tarflow <- list(
      tarflow.driver = RMariaDB::MariaDB(),
      tarflow.group = name_db_src_default
    )
  } else if (requireNamespace("odbc", quietly = TRUE)) {
    op_tarflow <- list(
      tarflow.driver = odbc::odbc(),
      tarflow.dsn = name_db_src_default
    )
  } else {
    op_tarflow <- list()
  }

  toset <- !(names(op_tarflow) %in% names(op))
  if (any(toset)) options(op_tarflow[toset])

  if (!check_source()) {
    tryCatch(setup_option_file(quietly = TRUE), error = \(e) {})
  }

  invisible()
}

.onAttach <- function(libname, pkgname) {
  if (!requireNamespace("odbc", quietly = TRUE) &&
        !requireNamespace("RMariaDB", quietly = TRUE)) {
    packageStartupMessage(
      "Neither odbc nor RMariaDB is installed.",
      " For better support, it is recommended to install RMariaDB.",
      " Please install it with `install.packages('RMariaDB')`."
    )
  } else if (!check_source()) {
    packageStartupMessage(
      "The default database source is not working.",
      " Please check your database settings first.",
      " See `?setup_option_file` for more details."
    )
  }
}

# nocov end
