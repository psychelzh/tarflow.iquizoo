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
#' @param always_check_hash Whether to always check the project hash. Set to
#'   `FALSE` if you are sure the project has been finished. Default to `TRUE`.
#' @return A S3 object of class `tarflow_targets`. The value is a list of target
#'   objects, and a [data.frame] containing the contents based on which data are
#'   fetched is included in the `"contents"` attribute.
#' @export
prepare_fetch_data <- function(params, ...,
                               what = c("all", "raw_data", "scores"),
                               always_check_hash = TRUE) {
  check_dots_empty()
  what <- match.arg(what)
  contents <- fetch_preset_mem(params, what = "project_contents")
  if (nrow(contents) == 0) {
    warn(
      "No records found based on the given parameters",
      class = "tarflow_bad_params"
    )
    targets <- list()
  } else {
    branches <- tarchetypes::tar_map(
      contents |>
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
            raw_data, {
              project_hash
              fetch_data(
                project_id, game_id, course_date,
                what = "raw_data"
              )
            }
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
          scores, {
            project_hash
            fetch_data(
              project_id, game_id, course_date,
              what = "scores"
            )
          }
        )
      }
    )
    targets <- list(
      targets::tar_target_raw(
        "project_hash",
        expr(
          fetch_preset(!!substitute(params), what = "project_hash")
        ),
        cue = targets::tar_cue(if (always_check_hash) "always")
      ),
      targets::tar_target_raw(
        "project_users",
        expr(
          fetch_preset(!!substitute(params), what = "project_users")
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
#' @param params The parameters used in the SQL query.
#' @param what The name of the preset query file to use.
#' @param ... Further arguments passed to [fetch_parameterized()].
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_preset <- function(params, what, ...) {
  check_dots_used()
  query <- read_sql_file(name_sql_files[[what]])
  fetched <- vector("list", nrow(params))
  for (i in seq_len(nrow(params))) {
    fetched[[i]] <- fetch_parameterized(
      query,
      # RMariaDB accept named parameters but the query is not named
      unname(as.list(params[i, ])),
      ...
    )
  }
  as.data.frame(do.call(rbind, fetched))
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
    "project_hash", "project_id", "game_id", "course_date",
    "prep_fun_name", "prep_fun", "input", "extra"
  )
)
