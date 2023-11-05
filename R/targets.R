#' Generate a set of targets for pre-processing of iQuizoo data
#'
#' This target factory prepares a set of target objects used to fetch data from
#' iQuizoo database, separated into static branches so that each is for a
#' specific project and task/game combination. Further pre-processing on the
#' fetched data can also be added if requested.
#'
#' @param params A [data.frame] or [list] contains the parameters to be bound to
#'   the query. Default templates require specifying `organization_name` and
#'   `project_name`, in that order. If `contents` template is specified without
#'   any parameters, set it as empty vector or `NULL`. If `contents` argument is
#'   specified, this argument is omitted.
#' @param ... For future usage. Should be empty.
#' @param contents The contents structure used as the configuration of data
#'   fetching. It is typically automatically fetched from database based on the
#'   `contents` template in `templates`. If not `NULL`, it will be used directly
#'   and ignore that specified in `templates`. Note `contents` should at least
#'   contains `project_id` and `game_id` names.
#' @param what What to fetch. There are basically two types of data, i.e., raw
#'   data and scores. The former is the logged raw data for each trial of the
#'   tasks/games, while the latter is the scores calculated by iQuizoo server.
#'   If set as "all", both raw data and scores will be fetched. Further actions
#'   on the fetched raw data can be specified by `action_raw_data`.
#' @param action_raw_data The action to be taken on the fetched raw data. There
#'   are two consecutive actions, i.e., wrangling and pre-processing. The former
#'   will parse the raw data into a tidy format, while the latter will calculate
#'   indices based on the parsed data. If set as "all", both wrangling and
#'   pre-processing will be done. If set as "parse", only wrangling will be
#'   done. If set as "none", neither will be done. If `what` is "scores", this
#'   argument will be ignored.
#' @param combine Specify which targets to be combined. Note you should only
#'   specify names from `c("users", "scores", "raw_data", "raw_data_parsed",
#'   "indices")`. If `NULL`, none will be combined.
#' @param templates The SQL template files used to fetch data. See
#'   [setup_templates()] for details.
#' @param check_progress Whether to check the progress hash. Set it as `FALSE`
#'   if the project is finalized.
#' @return A list of target objects.
#' @export
tar_prep_iquizoo <- function(params, ...,
                             contents = NULL,
                             what = c("raw_data", "scores"),
                             action_raw_data = c("all", "parse", "none"),
                             combine = NULL,
                             templates = setup_templates(),
                             check_progress = TRUE) {
  check_dots_empty()
  if (!inherits(templates, "tarflow.template")) {
    cli::cli_abort(
      "{.arg templates} must be created by {.fun setup_templates}.",
      class = "tarflow_bad_templates"
    )
  }
  what <- match.arg(what, several.ok = TRUE)
  action_raw_data <- match.arg(action_raw_data)
  if (!is.null(combine) && !all(combine %in% objects())) {
    cli::cli_abort(
      "{.arg combine} must be a subset of {vctrs::vec_c({objects()})}.",
      class = "tarflow_bad_combine"
    )
  }
  if (is.null(contents)) {
    contents <- fetch_iquizoo_mem(
      read_file(templates$contents),
      params = unname(
        if (!is_empty(params)) as.list(params)
      )
    )
  }
  if (nrow(contents) == 0) {
    cli::cli_abort(
      "No contents to fetch.",
      class = "tarflow_bad_contents"
    )
  }
  list(
    targets::tar_target_raw(
      "contents_origin",
      expr(unserialize(!!serialize(contents, NULL)))
    ),
    tar_projects_info(
      contents,
      templates,
      check_progress,
      combine
    ),
    tar_fetch_data(
      contents,
      templates,
      "scores",
      combine
    ),
    tar_fetch_data(
      contents,
      templates,
      "raw_data",
      combine
    ),
    if (action_raw_data != "none") {
      tar_action_raw_data(
        contents,
        action_raw_data,
        combine = combine
      )
    }
  )
}

#' Set up templates used to fetch data
#'
#' If you want to extract data based on your own parameters, you should use this
#' function to set up your own SQL templates. Note that the SQL queries should
#' be parameterized.
#'
#' @param contents The SQL template file used to fetch contents. At least
#'   `project_id` and `game_id` columns should be included in the fetched data
#'   based on the template. `project_id` will be used as the only parameter in
#'   `users` and `project` templates, while all three will be used in `raw_data`
#'   and `scores` templates.
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
tar_projects_info <- function(contents, templates, check_progress, combine) {
  targets <- tarchetypes::tar_map(
    contents |>
      dplyr::distinct(.data$project_id) |>
      dplyr::mutate(project_id = as.character(.data$project_id)),
    targets::tar_target_raw(
      "progress_hash",
      expr(
        fetch_iquizoo(
          !!read_file(templates[["progress_hash"]]),
          params = list(project_id)
        )
      ),
      packages = "tarflow.iquizoo",
      cue = targets::tar_cue(if (check_progress) "always")
    ),
    targets::tar_target_raw(
      "users",
      expr(
        fetch_iquizoo(
          !!read_file(templates[["users"]]),
          params = list(project_id)
        )
      ),
      packages = "tarflow.iquizoo"
    )
  )
  c(
    targets,
    if ("users" %in% combine) {
      tarchetypes::tar_combine(
        users,
        targets$users,
        command = unique(vctrs::vec_c(!!!.x))
      )
    }
  )
}

tar_fetch_data <- function(contents, templates, what, combine) {
  targets <- tarchetypes::tar_map(
    contents |>
      dplyr::summarise(
        game_id_chr = unique(as.character(.data$game_id)),
        project_id_list = list(as.character(.data$project_id)),
        game_id_list = list(as.character(.data$game_id)),
        progress_hash_list = list(
          syms(
            stringr::str_glue("progress_hash_{project_id}")
          )
        ),
        .by = "game_id"
      ),
    names = "game_id_chr",
    targets::tar_target_raw(
      what,
      expr({
        progress_hash_list
        purrr::pmap(
          list(
            query = !!read_file(templates[[what]]),
            project_id = project_id_list,
            game_id = game_id_list,
            what = !!what
          ),
          fetch_data
        ) |>
          purrr::list_rbind()
      }),
      packages = "tarflow.iquizoo"
    )
  )
  c(
    targets,
    if (what %in% combine) {
      tarchetypes::tar_combine_raw(
        what,
        targets[[what]]
      )
    }
  )
}

tar_action_raw_data <- function(contents,
                                action_raw_data,
                                name_data = "raw_data",
                                name_parsed = "raw_data_parsed",
                                name_indices = "indices",
                                combine = c(name_parsed, name_indices)) {
  if (action_raw_data == "all") action_raw_data <- c("parse", "preproc")
  combine <- match.arg(combine, several.ok = TRUE)
  targets <- c(
    tarchetypes::tar_map(
      values = contents |>
        dplyr::mutate(
          game_id = as.character(.data$game_id),
          tar_raw_data = syms(
            stringr::str_glue("{name_data}_{game_id}")
          )
        ),
      names = game_id,
      if ("parse" %in% action_raw_data) {
        targets::tar_target_raw(
          name_parsed,
          expr(wrangle_data(tar_raw_data)),
          packages = "tarflow.iquizoo"
        )
      }
    ),
    if ("preproc" %in% action_raw_data) {
      tarchetypes::tar_map(
        values = contents |>
          data.iquizoo::match_preproc(type = "inner") |>
          dplyr::mutate(
            game_id = as.character(.data$game_id),
            tar_parsed = syms(stringr::str_glue("{name_parsed}_{game_id}"))
          ),
        names = game_id,
        targets::tar_target_raw(
          name_indices,
          expr(
            preproc_data(
              tar_parsed, prep_fun,
              .input = input, .extra = extra
            )
          ),
          packages = c("tarflow.iquizoo", "preproc.iquizoo")
        )
      )
    }
  )
  c(
    targets,
    if (name_parsed %in% combine && "parse" %in% action_raw_data) {
      tarchetypes::tar_combine_raw(
        name_parsed,
        targets[[name_parsed]]
      )
    },
    if (name_indices %in% combine && "preproc" %in% action_raw_data) {
      tarchetypes::tar_combine_raw(
        name_indices,
        targets[[name_indices]]
      )
    }
  )
}

objects <- function() {
  c("users", "scores", "raw_data", "raw_data_parsed", "indices")
}

utils::globalVariables(
  c(
    "tar_raw_data", "tar_parsed",
    "progress_hash", "progress_hash_list",
    "project_id", "project_id_list",
    "game_id", "game_id_list",
    "prep_fun", "input", "extra", "users", ".x"
  )
)
