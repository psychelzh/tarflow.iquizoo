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
#'   specify names from `c("scores", "raw_data", "raw_data_parsed",
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
    contents <- fetch_iquizoo_mem()(
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
  targets <- c(
    targets::tar_target_raw(
      "contents_origin",
      expr(unserialize(!!serialize(contents, NULL)))
    ),
    tar_prep_proj(contents, templates, check_progress),
    sapply(
      what,
      \(what) tar_fetch_data(contents, templates, what, check_progress),
      simplify = FALSE
    ),
    if ("raw_data" %in% what && action_raw_data != "none") {
      if (action_raw_data == "all") {
        action_raw_data <- c("parse", "preproc")
      }
      tar_prep_raw(contents, action_raw_data)
    }
  )
  c(
    targets,
    lapply(
      intersect(combine, names(targets)),
      \(name) {
        tarchetypes::tar_combine_raw(
          name,
          targets[[name]]
        )
      }
    )
  )
}

#' Generate a set of targets for preparing project-level data
#'
#' There are mainly two types of data to be fetched, i.e., the progress hash and
#' the user information. The former is used to check the progress of the
#' project, while the latter is used to identify the users involved in the
#' project.
#'
#' @param contents The contents structure used as the configuration of data
#'   fetching.
#' @param templates The SQL template files used to fetch data. See
#'   [setup_templates()] for details.
#' @param check_progress Whether to check the progress hash. When set as `TRUE`,
#'   a progress hash objects named as `progress_hash_{project_id}` for each
#'   project will be added into the target list. Set it as `FALSE` if the
#'   projects are finalized.
#' @return A list of target objects.
#' @export
tar_prep_proj <- function(contents,
                          templates = setup_templates(),
                          check_progress = TRUE) {
  c(
    if (check_progress) {
      tarchetypes::tar_map(
        data.frame(project_id = as.character(unique(contents$project_id))),
        targets::tar_target_raw(
          "progress_hash",
          bquote(
            fetch_iquizoo(
              .(read_file(templates[["progress_hash"]])),
              params = list(project_id)
            )
          ),
          packages = "tarflow.iquizoo",
          cue = targets::tar_cue("always")
        )
      )
    },
    targets::tar_target_raw(
      "users",
      bquote(
        fetch_iquizoo(
          .(read_file(templates[["users"]])),
          params = list(.(unique(contents$project_id)))
        ) |>
          unique()
      ),
      packages = "tarflow.iquizoo"
    )
  )
}

#' Generate a set of targets for fetching data
#'
#' This target factory is the main part of the `tar_prep_iquizoo` function. It
#' fetches the raw data and scores for each project and task/game combination.
#'
#' @param contents The contents structure used as the configuration of data
#'   fetching.
#' @param templates The SQL template files used to fetch data. See
#'   [setup_templates()] for details.
#' @param what What to fetch.
#' @param check_progress Whether to check the progress hash. If set as `TRUE`,
#'   Before fetching the data, the progress hash objects named as
#'   `progress_hash_{project_id}` will be depended on, which are typically
#'   generated by [tar_prep_proj()]. If the projects are finalized, set this
#'   argument as `FALSE`.
#' @return A list of target objects.
#' @export
tar_fetch_data <- function(contents,
                           templates = setup_templates(),
                           what = c("raw_data", "scores"),
                           check_progress = TRUE) {
  what <- match.arg(what)
  by(
    contents,
    contents$game_id,
    \(contents) {
      project_ids <- as.character(unique(contents$project_id))
      game_id <- as.character(unique(contents$game_id))
      targets::tar_target_raw(
        paste0(what, "_", game_id),
        as.call(c(
          quote(`{`),
          if (check_progress) {
            bquote(
              list(..(syms(paste0("progress_hash_", project_ids)))),
              splice = TRUE
            )
          },
          bquote(
            do.call(
              rbind,
              .mapply(
                fetch_data,
                list(.(project_ids), .(game_id)),
                MoreArgs = list(
                  what = .(what),
                  query = .(read_file(templates[[what]]))
                )
              )
            )
          )
        )),
        packages = "tarflow.iquizoo"
      )
    }
  )
}

#' Generate a set of targets for wrangling and pre-processing raw data
#'
#' This target factory is the main part of the `tar_prep_iquizoo` function. It
#' wrangles the raw data into a tidy format and calculates indices based on the
#' parsed data.
#'
#' @param contents The contents structure used as the configuration of data
#'   fetching.
#' @param action_raw_data The action to be taken on the fetched raw data.
#' @param name_data The name of the raw data target.
#' @param name_parsed The name of the parsed data target.
#' @param name_indices The name of the indices target.
#' @return A list of target objects.
#' @export
tar_prep_raw <- function(contents,
                         action_raw_data = c("parse", "preproc"),
                         name_data = "raw_data",
                         name_parsed = "raw_data_parsed",
                         name_indices = "indices") {
  action_raw_data <- match.arg(action_raw_data, several.ok = TRUE)
  contents <- unique(contents["game_id"])
  contents$tar_data <- syms(sprintf("%s_%s", name_data, contents$game_id))
  contents$tar_parsed <- syms(sprintf("%s_%s", name_parsed, contents$game_id))
  contents$tar_indices <- syms(sprintf("%s_%s", name_indices, contents$game_id))
  list(
    raw_data_parsed = if ("parse" %in% action_raw_data) {
      tarchetypes::tar_eval(
        targets::tar_target(
          tar_parsed,
          parse_data(tar_data),
          packages = "tarflow.iquizoo"
        ),
        contents
      )
    },
    indices = if ("preproc" %in% action_raw_data) {
      check_installed("preproc.iquizoo", "becasue required in pre-processing.")
      tarchetypes::tar_eval(
        targets::tar_target(
          tar_indices,
          preproc.iquizoo::preproc_data(
            tar_parsed,
            prep_fun,
            .input = input,
            .extra = extra
          ),
          packages = "preproc.iquizoo"
        ),
        data.iquizoo::merge_preproc(contents)
      )
    }
  )
}

objects <- function() {
  c("scores", "raw_data", "raw_data_parsed", "indices")
}

utils::globalVariables(
  c(
    "tar_data", "tar_parsed", "tar_indices",
    "prep_fun", "input", "extra"
  )
)
