#' @import rlang
#' @import tidyselect
NULL

# nocov start

.onLoad <- function(libname, pkgname) {
  # options
  op <- options()
  name_db_src_default <- "iquizoo-v3"
  if (requireNamespace("odbc", quietly = TRUE) &&
        name_db_src_default %in% odbc::odbcListDataSources()$name) {
    op_tarflow <- list(
      tarflow.driver = odbc::odbc(),
      tarflow.dsn = name_db_src_default
    )
  } else if (requireNamespace("RMariaDB", quietly = TRUE)) {
    op_tarflow <- list(
      tarflow.driver = RMariaDB::MariaDB(),
      tarflow.groups = name_db_src_default
    )
  } else {
    op_tarflow <- list()
  }

  toset <- !(names(op_tarflow) %in% names(op))
  if (any(toset)) options(op_tarflow[toset])

  # https://stackoverflow.com/a/67664852/5996475
  ns <- topenv()
  ns$fetch_batch_mem <- memoise::memoise(
    fetch_batch,
    cache = switch(Sys.getenv("TARFLOW_CACHE", "disk"),
      disk = memoise::cache_filesystem("~/.tarflow.cache"),
      memory = memoise::cache_memory()
    )
  )

  invisible()
}

.onAttach <- function(libname, pkgname) {
  if (!requireNamespace("odbc", quietly = TRUE) &&
        !requireNamespace("RMariaDB", quietly = TRUE)) {
    packageStartupMessage(
      "Neither odbc nor RMariaDB is installed.",
      " Please install one of them."
    )
  }
}

# nocov end
