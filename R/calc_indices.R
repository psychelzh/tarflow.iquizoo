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
  # if no data found, no further processing is needed
  if (nrow(data) == 0) {
    return(NULL)
  }
  # use `prep_fun` to calculate
  data %>%
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
          "game_id", "game_name", "game_time", "game_duration",
          "index", "score", "is_normal", "is_outlier")
      )
    )
}
