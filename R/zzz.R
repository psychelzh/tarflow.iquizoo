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
    toset <- !(names(op_tarflow) %in% names(op))
    if (any(toset)) options(op_tarflow[toset])
  } else {
    stop("Neither odbc nor RMariaDB is installed. Please install one of them.")
  }

  invisible()
}
