#' Wrangle Raw Data
#'
#' Data wrangling is the first step for data analysis.
#'
#' @param data The raw data.
#' @param name_raw_json The column name in which stores user's raw data in
#'   format of json string.
#' @return
#' @export
wrangle_data <- function(data, name_raw_json = "game_data") {
  # return `NULL` in case of error when parsing
  parse_raw_json <- purrr::possibly(
    ~ jsonlite::fromJSON(.) |>
      dplyr::rename_with(tolower) |>
      dplyr::mutate(dplyr::across(where(is.character), tolower)),
    otherwise = NULL
  )
  data |>
    dplyr::mutate(
      raw_parsed = purrr::map(
        .data[[name_raw_json]],
        parse_raw_json
      ),
      .keep = "unused"
    )
}
