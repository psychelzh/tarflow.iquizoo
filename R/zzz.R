#' @import rlang
#' @import tidyselect
NULL

.onLoad <- function(libname, pkgname) {
  op <- options()
  if (requireNamespace("odbc", quietly = TRUE)) {
    op_tarflow <- list(
      tarflow.driver = odbc::odbc()
    )
  } else if (requireNamespace("RMariaDB", quietly = TRUE)) {
    op_tarflow <- list(
      tarflow.driver = RMariaDB::MariaDB()
    )
  } else {
    op_tarflow <- list()
  }

  toset <- !(names(op_tarflow) %in% names(op))
  if (any(toset)) options(op_tarflow[toset])

  invisible()
}

.onAttach <- function(libname, pkgname) {
  if (!requireNamespace("odbc", quietly = TRUE) &&
      !requireNamespace("RMariaDB", quietly = TRUE)) {
    packageStartupMessage("Neither odbc nor RMariaDB is installed.",
                          " Please install one of them.")
  }
}
