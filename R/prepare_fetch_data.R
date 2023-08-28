#' Prepare targets pipeline for fetching data
#'
#' @details
#'
#' The `course_period` in `tble_params` could be numeric or character values.
#' See the following table for reference:
#'
#' | code | name |
#' | ---- | ---- |
#' | 0    | 未指定  |
#' | 1    | 学前   |
#' | 2    | 小学低段 |
#' | 3    | 小学中段 |
#' | 4    | 小学高段 |
#' | 5    | 小学   |
#' | 6    | 初中   |
#' | 7    | 高中   |
#'
#' @param tbl_params A [data.frame] contains the parameters to be bound to the
#'   query. For now, only `course_name` and `course_period` are supported. Each
#'   row is a set of parameters. See details for more information.
#' @param ... For future usage. Should be empty.
#' @param what What to fetch. Can be either "raw_data" or "scores".
#' @param cache_dir The directory to store cache. Defaults to
#'   `~/.cache.tarflow`.
#' @param cache_age The maximum age of cache in seconds. Defaults to `Inf`.
#' @return A list of [targets][targets::tar_target()].
#' @export
prepare_fetch_data <- function(tbl_params, ...,
                               what = c("raw_data", "scores"),
                               cache_dir = "~/.cache.tarflow",
                               cache_age = Inf) {
  check_dots_empty()
  what <- match.arg(what)
  fetch_config_tbl_mem <- memoise::memoise(
    fetch_config_tbl,
    cache = cachem::cache_disk(cache_dir, max_age = cache_age)
  )
  # course periods are stored as numeric coding in database
  if (is.character(tbl_params$course_period)) {
    course_periods_map <- set_names(
      course_periods$course_period_code,
      course_periods$course_period_name
    )
    tbl_params$course_period <- course_periods_map[tbl_params$course_period]
  }
  config_tbl <- tbl_params |>
    purrr::pmap(
      \(course_name, course_period) {
        fetch_config_tbl_mem(list(course_name, course_period))
      }
    ) |>
    purrr::list_rbind()
  targets_data <- tarchetypes::tar_map(
    config_tbl |>
      dplyr::left_join(
        data.iquizoo::game_info,
        by = "game_id"
      ) |>
      dplyr::mutate(
        # https://github.com/ropensci/tarchetypes/issues/94
        project_id = bit64::as.character.integer64(.data$project_id),
        game_id = bit64::as.character.integer64(.data$game_id),
        prep_fun = purrr::map(
          .data[["prep_fun_name"]],
          purrr::possibly(sym, NA)
        ),
        dplyr::across(
          dplyr::all_of(c("input", "extra")),
          parse_exprs
        )
      ),
    names = c(.data$project_id, .data$game_id),
    targets::tar_target_raw(
      what,
      expr(
        fetch_data(
          project_id, game_id, course_date,
          what = !!what
        )
      )
    ),
    if (what == "raw_data") {
      list(
        targets::tar_target_raw(
          "raw_data_parsed",
          expr(wrangle_data(!!sym(what)))
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
    }
  )
  list(
    targets_data,
    tarchetypes::tar_combine_raw(
      what,
      targets_data[[what]]
    ),
    if (what == "raw_data") {
      tarchetypes::tar_combine(
        indices,
        targets_data$indices
      )
    }
  )
}

utils::globalVariables(
  c("project_id", "game_id", "course_date", "raw_data_parsed",
    "indices", "prep_fun_name", "prep_fun", "input", "extra")
)
