#' Prepare targets pipeline for fetching data
#'
#' @details
#'
#' The `course_period` in `tble_params` could be numeric or character values.
#' Call `tarflow.iquizoo:::name_course_periods` to see all the possible values.
#' You could input numeric index, for example, `1` means the first in the
#' `tarflow.iquizoo:::name_course_periods`. Use `0` or `NA` if you want to refer
#' to older classes with no course periods.
#'
#' @param tbl_params A [data.frame] contains the parameters to be bound to the
#'   query. For now, only `course_name` and `course_period` are supported. Each
#'   row is a set of parameters. See details for more information.
#' @param ... For future usage. Should be empty.
#' @param what What to fetch. Can be "all", "raw_data" or "scores".
#' @return A S3 object of class `tarflow_targets`. The main component is a list
#'   of targets. The other component is a [data.frame] contains the parameters
#'   used to fetch the data.
#' @export
prepare_fetch_data <- function(tbl_params, ...,
                               what = c("all", "raw_data", "scores")) {
  check_dots_empty()
  what <- match.arg(what)
  config_tbl <- tbl_params |>
    purrr::pmap(fetch_preset_mem, what = "project_contents") |>
    purrr::list_rbind()
  if (nrow(config_tbl) == 0) {
    warn(
      "No records found based on the given parameters",
      class = "tarflow_bad_params"
    )
    targets <- list()
  } else {
    branches <- tarchetypes::tar_map(
      config_tbl |>
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
          )
        ),
      names = c("project_id", "game_id"),
      if (what %in% c("all", "raw_data")) {
        list(
          targets::tar_target(
            raw_data,
            fetch_data(
              project_id, game_id, course_date,
              what = "raw_data"
            )
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
        targets::tar_target(
          scores,
          fetch_data(
            project_id, game_id, course_date,
            what = "scores"
          )
        )
      }
    )
    targets <- list(
      targets::tar_target_raw(
        "project_users",
        expr(
          (!!substitute(tbl_params)) |>
            purrr::pmap(fetch_preset, what = "project_users") |>
            purrr::list_rbind()
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
    params = config_tbl |>
      dplyr::mutate(
        course_period_name = ifelse(
          .data$course_period_code == 0, "",
          name_course_periods[.data$course_period_code]
        ),
        game_type_name = name_game_types[.data$game_type_code]
      )
  )
}

#' Fetch data from iQuizoo database
#'
#' @param project_id The project id.
#' @param game_id The game id.
#' @param course_date The course date.
#' @param ... Further arguments passed to [fetch_parameterized()].
#' @param what What to fetch. Can be either "raw_data" or "scores".
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_data <- function(project_id, game_id, course_date, ...,
                       what = c("raw_data", "scores")) {
  check_dots_used()
  what <- match.arg(what)
  prefix <- tbl_data_prefixes[[what]]
  # name injection in the query
  tbl_data <- paste0(prefix, format(as.POSIXct(course_date), "%Y0101"))
  sql_file <- name_sql_files[[what]]
  query <- read_sql_file(sql_file) |>
    stringr::str_glue(.envir = env(tbl_data = tbl_data))
  fetch_parameterized(query, list(project_id, game_id), ...)
}

#' Fetch data from iQuizoo database with preset SQL query files
#'
#' @param ... The parameters used in the SQL query.
#' @param what The name of the preset query file to use.
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_preset <- function(..., what = c("project_contents", "project_users")) {
  check_dots_used()
  query <- read_sql_file(name_sql_files[[what]])
  fetch_parameterized(query, list(...))
}

read_sql_file <- function(file) {
  system.file(
    "sql", file,
    package = "tarflow.iquizoo"
  ) |>
    readLines() |>
    paste0(collapse = "\n")
}

utils::globalVariables(
  c(
    "scores", "raw_data", "raw_data_parsed", "indices",
    "project_id", "game_id", "course_date",
    "prep_fun_name", "prep_fun", "input", "extra"
  )
)
