# nocov start

#' Create standard data fetching targets pipeline script
#'
#' This function creates a standard data fetching targets pipeline script
#' for you to fill in.
#'
#' @return NULL (invisible). This function is called for its side effects.
#' @export
use_targets_pipeline <- function() {
  script <- "_targets.R"
  if (file.exists(script)) {
    cli::cli_alert_info(
      sprintf("File {.file %s} exists. Stash and retry.", script)
    )
    return(invisible())
  }
  copy_success <- file.copy(
    system.file(
      "pipelines", "use_targets.R",
      package = "tarflow.iquizoo"
    ),
    script
  )
  if (!copy_success) {
    cli::cli_alert_danger("Sorry, copy template failed.")
    return(invisible())
  }
  cli::cli_alert_success(
    sprintf("File {.file %s} created successfully.", script)
  )
  return(invisible())
}

# nocov end
