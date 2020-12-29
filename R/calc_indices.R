#' Calculate indices for a single game
#'
#' Use the given `prep_fun` to calculate indices for a single game. In addition,
#' a variable named `occasion` is added to track the times of participation.
#'
#' @param data The raw data.
#' @param prep_fun The name (symbol) of the calculation function
#' @return A `tibble` with the calculated indices.
#' @author Liang Zhang
#' @importFrom rlang .data
#' @export
calc_indices <- function(data, prep_fun) {
  # get the name of the preprocessing function
  prep_fun_name <- deparse1(substitute(prep_fun))
  # extract all the data that can be preprocessed by this function
  valid_game_ids <- gameconfig %>%
    dplyr::filter(.data$prep_fun == prep_fun_name) %>%
    dplyr::pull("game_id")
  cur_fun_data <- data %>%
    dplyr::filter(.data$game_id %in% valid_game_ids) %>%
    dplyr::filter(purrr::map_lgl(.data$game_data, jsonlite::validate))
  # if no data found, no further processing is needed
  if (nrow(cur_fun_data) == 0) {
    return(NULL)
  }
  # use `prep_fun` to calculate
  cur_fun_data %>%
    dplyr::group_by(.data$user_id) %>%
    dplyr::mutate(occasion = dplyr::row_number(.data$game_time)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      indices = purrr::map(
        .data$game_data,
        ~ prep_fun(jsonlite::fromJSON(.x)) %>%
          tidyr::pivot_longer(
            -.data$is_normal,
            names_to = "index",
            values_to = "score"
          )
      )
    ) %>%
    tidyr::unnest(.data$indices) %>%
    dplyr::group_by(.data$index) %>%
    dplyr::mutate(
      is_outlier = .data$score %in% grDevices::boxplot.stats(.data$score)$out
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(
      dplyr::all_of(
        c("user_id", "occasion",
          "game_id", "game_name", "game_duration",
          "index", "score", "is_normal", "is_outlier")
      )
    )
}
