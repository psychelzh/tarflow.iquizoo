#' Create standard data fetching targets pipeline script
#'
#' This function creates a standard data fetching targets pipeline script
#' for you to fill in.
#'
#' @return NULL (invisible). This function is called for its side effects.
#' @export
use_targets <- function() {
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
    sprintf("File {.file %s} crated successfully.", script)
  )
  return(invisible())
}

#' Prepare targets based on parameters
#'
#' Given parameters, this target factory prepares a set of target objects used
#' to fetch data from iQuizoo database, separated into static branches so that
#' each is for a specific project and task/game combination.
#'
#' @param params A [data.frame] contains the parameters to be bound to the
#'   query. For now, only `organization_name` and `project_name` are supported
#'   and both of them should be specified. Each row is a set of parameters.
#' @param ... For future usage. Should be empty.
#' @param what What to fetch. Can be "all", "raw_data" or "scores".
#' @param templates The SQL template files used to fetch data. See
#'   [setup_templates()] for details.
#' @param check_progress Whether to check the progress hash. Set it as `FALSE`
#'   if the project is finalized.
#' @return A S3 object of class `tarflow_targets`. The value is a list of target
#'   objects, and a [data.frame] containing the contents based on which data are
#'   fetched is included in the `"contents"` attribute.
#' @export
prepare_fetch_data <- function(params, ...,
                               what = c("all", "raw_data", "scores"),
                               templates = setup_templates(),
                               check_progress = TRUE) {
  check_dots_empty()
  if (!inherits(templates, "tarflow.template")) {
    cli::cli_abort(
      "{.arg templates} must be created by {.fun setup_templates}.",
      class = "tarflow_bad_templates"
    )
  }
  what <- match.arg(what)
  contents <- fetch_query_mem(
    read_file(templates$contents),
    unname(as.list(params))
  )
  if (nrow(contents) == 0) {
    cli::cli_warn(
      "No contents found based on the given parameters",
      class = "tarflow_bad_params"
    )
    targets <- list()
  } else {
    config_contents <- contents |>
      dplyr::left_join(
        data.iquizoo::game_info,
        by = "game_id"
      ) |>
      dplyr::mutate(
        # https://github.com/ropensci/tarchetypes/issues/94
        project_id = bit64::as.character.integer64(.data$project_id),
        game_id = bit64::as.character.integer64(.data$game_id),
        course_date = as.character(course_date),
        prep_fun = purrr::map(
          .data[["prep_fun_name"]],
          purrr::possibly(sym, NA)
        ),
        dplyr::across(
          dplyr::all_of(c("input", "extra")),
          parse_exprs
        ),
        progress_hash = syms(paste0("progress_hash_", project_id))
      )
    branches <- tarchetypes::tar_map(
      config_contents,
      names = c("project_id", "game_id"),
      if (what %in% c("all", "raw_data")) {
        list(
          targets::tar_target_raw(
            "raw_data",
            expr({
              progress_hash
              fetch_data(
                !!read_file(templates[["raw_data"]]),
                project_id,
                game_id,
                course_date,
                what = "raw_data"
              )
            })
          ),
          targets::tar_target(
            raw_data_parsed,
            wrangle_data(raw_data)
          ),
          targets::tar_target(
            indices,
            if (!is.na(prep_fun_name)) {
              preproc_data(
                raw_data_parsed, prep_fun,
                .input = input, .extra = extra
              )
            }
          )
        )
      },
      if (what %in% c("all", "scores")) {
        targets::tar_target_raw(
          "scores",
          expr({
            progress_hash
            fetch_data(
              !!read_file(templates[["scores"]]),
              project_id,
              game_id,
              course_date,
              what = "scores"
            )
          })
        )
      }
    )
    targets <- list(
      tarchetypes::tar_map(
        dplyr::distinct(config_contents, project_id),
        targets::tar_target_raw(
          "progress_hash",
          expr(
            fetch_query(
              !!read_file(templates[["progress_hash"]]),
              list(project_id)
            )
          ),
          cue = targets::tar_cue(if (check_progress) "always")
        )
      ),
      targets::tar_target_raw(
        "users",
        expr(
          unique(
            fetch_query(
              !!read_file(templates[["users"]]),
              !!substitute(unname(as.list(params)))
            )
          )
        )
      ),
      branches,
      if (what %in% c("all", "raw_data")) {
        list(
          tarchetypes::tar_combine(
            raw_data,
            branches$raw_data
          ),
          tarchetypes::tar_combine(
            indices,
            branches$indices
          )
        )
      },
      if (what %in% c("all", "scores")) {
        tarchetypes::tar_combine(
          scores,
          branches$scores
        )
      }
    )
  }
  structure(
    targets,
    class = "tarflow_targets",
    contents = contents
  )
}

#' Set up templates used to fetch data
#'
#' If you want to extract data based on your own parameters, you should use this
#' function to set up your own SQL templates. Note that the SQL queries should
#' be parameterized.
#'
#' @param contents The SQL template file used to fetch contents. At least
#'   `project_id`, `game_id` and `course_date` should be included in the
#'   contents.
#' @param users The SQL template file used to fetch users.
#' @param raw_data The SQL template file used to fetch raw data. See
#'   [fetch_data()] for details. Usually you don't need to change this.
#' @param scores The SQL template file used to fetch scores. See [fetch_data()]
#'   for details. Usually you don't need to change this.
#' @param progress_hash The SQL template file used to fetch progress hash.
#'   Usually you don't need to change this.
#' @return A S3 object of class `tarflow.template` with the options.
#' @export
setup_templates <- function(contents = NULL,
                            users = NULL,
                            raw_data = NULL,
                            scores = NULL,
                            progress_hash = NULL) {
  structure(
    list(
      contents = contents %||% package_sql_file("contents.sql"),
      users = users %||% package_sql_file("users.sql"),
      raw_data = raw_data %||% package_sql_file("raw_data.sql"),
      scores = scores %||% package_sql_file("scores.sql"),
      progress_hash = progress_hash %||%
        package_sql_file("progress_hash.sql")
    ),
    class = "tarflow.template"
  )
}

utils::globalVariables(
  c(
    "scores", "raw_data", "raw_data_parsed", "indices",
    "progress_hash", "project_id", "game_id", "course_date",
    "prep_fun_name", "prep_fun", "input", "extra"
  )
)

# helper functions
package_sql_file <- function(file) {
  system.file(
    "sql", file,
    package = "tarflow.iquizoo"
  )
}

read_file <- function(file) {
  paste0(readLines(file), collapse = "\n")
}
