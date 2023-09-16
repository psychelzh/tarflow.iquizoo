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
#' @param templates The SQL template files used to fetch data. See
#'   [setup_templates()] for details.
#' @param what What to fetch. Can be "all", "raw_data" or "scores".
#' @param always_check_hash Whether to always check the project hash. Set to
#'   `FALSE` if you are sure the project has been finished. Default to `TRUE`.
#' @return A S3 object of class `tarflow_targets`. The value is a list of target
#'   objects, and a [data.frame] containing the contents based on which data are
#'   fetched is included in the `"contents"` attribute.
#' @export
prepare_fetch_data <- function(params, ...,
                               templates = setup_templates(),
                               what = c("all", "raw_data", "scores"),
                               always_check_hash = TRUE) {
  check_dots_empty()
  if (!inherits(templates, "tarflow.template")) {
    cli::cli_abort(
      "{.arg templates} must be created by {.fun setup_templates}."
    )
  }
  what <- match.arg(what)
  contents <- fetch_batch_mem(read_file(templates$contents), params)
  if (nrow(contents) == 0) {
    warn(
      "No records found based on the given parameters",
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
          targets::tar_target(
            raw_data, {
              progress_hash
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
            progress_hash
            fetch_data(
              project_id, game_id, course_date,
              what = "scores"
            )
          }
        )
      }
    )
    targets <- list(
      tarchetypes::tar_map(
        dplyr::distinct(config_contents, project_id),
        targets::tar_target_raw(
          "progress_hash",
          expr(
            fetch_batch(
              !!read_file(templates[["progress_hash"]]),
              data.frame(project_id = project_id)
            )
          ),
          cue = targets::tar_cue(if (always_check_hash) "always")
        )
      ),
      targets::tar_target_raw(
        "users",
        expr(
          fetch_batch(
            !!read_file(templates[["users"]]),
            !!substitute(params)
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
#' @param contents The SQL template file used to fetch contents. At least
#'   `project_id`, `game_id` and `course_date` should be included in the
#'   contents. See [fetch_data()] for details.
#' @param users The SQL template file used to fetch users. See [fetch_batch()]
#'   for details.
#' @param progress_hash The SQL template file used to fetch progress hash. See
#'   [fetch_batch()] for details. Usually you don't need to change this.
#' @return A S3 object of class `tarflow.template` with the options.
#' @export
setup_templates <- function(contents = NULL, users = NULL,
                            progress_hash = NULL) {
  structure(
    list(
      contents = contents %||% package_sql_file(name_sql_files["contents"]),
      users = users %||% package_sql_file(name_sql_files["users"]),
      progress_hash = progress_hash %||%
        package_sql_file(name_sql_files["progress_hash"])
    ),
    class = "tarflow.template"
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
  query <- stringr::str_glue(
    read_file(package_sql_file(sql_file)),
    .envir = env(tbl_data = tbl_data)
  )
  fetch_parameterized(query, list(project_id, game_id), ...)
}

#' Fetch results of a parameterized query based on a batch of parameters
#'
#' @param query A character string containing parameterized SQL.
#' @param params The parameters used in the SQL query.
#' @param ... Further arguments passed to [fetch_parameterized()].
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_batch <- function(query, params, ...) {
  check_dots_used()
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
