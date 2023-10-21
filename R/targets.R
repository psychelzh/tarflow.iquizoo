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
#' @param params A [data.frame] or [list] contains the parameters to be bound to
#'   the query. Default templates require specifying `organization_name` and
#'   `project_name`, in that order. If `contents` template is specified without
#'   any parameters, set this as `NULL` or 0-row [data.frame].
#' @param ... For future usage. Should be empty.
#' @param what What to fetch. If set as "all", both raw data and scores will be
#'   fetched. If set as "raw_data", only raw data will be fetched. If set as
#'   "scores", only scores will be fetched. Further actions on the fetched raw
#'   data can be specified by `action_raw_data`.
#' @param action_raw_data The action to be taken on the fetched raw data. If set
#'   as "all", both wrangling and pre-processing will be done. If set as
#'   "parse", only wrangling will be done. If set as "none", neither will be
#'   done. If `what` is "scores", this argument will be ignored.
#' @param templates The SQL template files used to fetch data. See
#'   [setup_templates()] for details.
#' @param check_progress Whether to check the progress hash. Set it as `FALSE`
#'   if the project is finalized.
#' @return A list of target objects.
#' @export
prepare_fetch_data <- function(params, ...,
                               what = c("all", "raw_data", "scores"),
                               action_raw_data = c("all", "parse", "none"),
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
  if (what == "all") what <- c("raw_data", "scores")
  action_raw_data <- match.arg(action_raw_data)
  if (inherits(params, "data.frame")) {
    params <- as.list(params)
  }
  if (is_empty(params)) {
    params <- NULL
  }
  contents <- fetch_iquizoo_mem(
    read_file(templates$contents),
    params = unname(params)
  )
  if (nrow(contents) == 0) {
    cli::cli_abort(
      "No contents to fetch.",
      class = "tarflow_bad_contents"
    )
  }
  projects_info <- prepare_pipeline_info(
    contents,
    templates,
    check_progress
  )
  projects_data <- prepare_pipeline_data(
    contents,
    templates,
    what,
    action_raw_data
  )
  list(
    targets::tar_target_raw(
      "contents",
      expr(unserialize(!!serialize(contents, NULL)))
    ),
    projects_info,
    projects_data
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
#'   contents. `project_id` will be used as the only parameter in `users` and
#'   `project` templates, while all three will be used in `raw_data` and
#'   `scores` templates.
#' @param users The SQL template file used to fetch users. Usually you don't
#'   need to change this.
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
      contents = contents %||% package_file("sql", "contents.sql"),
      users = users %||% package_file("sql", "users.sql"),
      raw_data = raw_data %||% package_file("sql", "raw_data.sql"),
      scores = scores %||% package_file("sql", "scores.sql"),
      progress_hash = progress_hash %||%
        package_file("sql", "progress_hash.sql")
    ),
    class = "tarflow.template"
  )
}

# helper functions
prepare_pipeline_data <- function(contents, templates,
                                  what, action_raw_data) {
  contents <- contents |>
    dplyr::distinct(.data$project_id, .data$game_id, .data$course_date)
  targets_fetch <- lapply(
    what,
    set_pipeline_fetch,
    contents = contents,
    templates = templates
  )
  c(
    targets_fetch,
    if ("scores" %in% what) {
      tarchetypes::tar_combine(
        scores,
        targets_fetch[[which(what == "scores")]]$scores
      )
    },
    if ("raw_data" %in% what) {
      contents_preproc <- contents |>
        dplyr::summarise(
          tar_raw_data = stringr::str_glue(
            "raw_data_{project_id}_{game_id}"
          ) |>
            syms() |>
            list(),
          .by = .data$game_id
        ) |>
        dplyr::left_join(data.iquizoo::game_info, by = "game_id") |>
        dplyr::mutate(
          game_id = bit64::as.character.integer64(.data$game_id),
          prep_fun = purrr::map(
            .data[["prep_fun_name"]],
            purrr::possibly(sym, NA)
          ),
          dplyr::across(
            dplyr::all_of(c("input", "extra")),
            parse_exprs
          )
        )
      targets_raw_data_preproc <- tarchetypes::tar_map(
        values = contents_preproc,
        names = game_id,
        list(
          targets::tar_target(
            raw_data,
            dplyr::bind_rows(tar_raw_data)
          ),
          if (action_raw_data %in% c("all", "parse")) {
            targets::tar_target(
              raw_data_parsed,
              wrangle_data(raw_data)
            )
          },
          if (action_raw_data %in% "all") {
            targets::tar_target(
              indices,
              if (!is.na(prep_fun_name)) {
                preproc_data(
                  raw_data_parsed, prep_fun,
                  .input = input, .extra = extra
                )
              }
            )
          }
        )
      )
      targets_raw_data_combine <- c(
        if (action_raw_data %in% c("all", "parse")) {
          tarchetypes::tar_combine(
            raw_data_parsed,
            targets_raw_data_preproc$raw_data_parsed
          )
        },
        if (action_raw_data %in% c("all")) {
          tarchetypes::tar_combine(
            indices,
            targets_raw_data_preproc$indices
          )
        }
      )
      c(
        targets_raw_data_preproc,
        targets_raw_data_combine
      )
    }
  )
}

set_pipeline_fetch <- function(contents, templates, what) {
  key_ids <- c("project_id", "game_id")
  tarchetypes::tar_map(
    contents |>
      dplyr::mutate(
        dplyr::across(
          dplyr::all_of(key_ids),
          bit64::as.character.integer64
        ),
        course_date = as.character(course_date),
        progress_hash = syms(
          paste0("progress_hash_", .data$project_id)
        )
      ),
    names = key_ids,
    list(
      targets::tar_target_raw(
        what,
        expr({
          progress_hash
          fetch_data(
            !!read_file(templates[[what]]),
            project_id,
            game_id,
            course_date,
            what = !!what
          )
        })
      )
    )
  )
}

prepare_pipeline_info <- function(contents, templates, check_progress) {
  targets <- tarchetypes::tar_map(
    contents |>
      dplyr::distinct(.data$project_id) |>
      dplyr::mutate(
        project_id = bit64::as.character.integer64(.data$project_id)
      ),
    list(
      targets::tar_target_raw(
        "progress_hash",
        expr(
          fetch_iquizoo(
            !!read_file(templates[["progress_hash"]]),
            params = list(project_id)
          )
        ),
        cue = targets::tar_cue(if (check_progress) "always")
      ),
      targets::tar_target_raw(
        "users",
        expr(
          fetch_iquizoo(
            !!read_file(templates[["users"]]),
            params = list(project_id)
          )
        )
      )
    )
  )
  c(
    targets,
    tarchetypes::tar_combine(
      users,
      targets$users,
      command = unique(vctrs::vec_c(!!!.x))
    )
  )
}

utils::globalVariables(
  c(
    "scores", "raw_data", "tar_raw_data", "raw_data_parsed", "indices",
    "progress_hash", "project_id", "game_id", "course_date",
    "prep_fun_name", "prep_fun", "input", "extra", "users", ".x"
  )
)
