#' Wrangle Raw Data
#'
#' Data wrangling is the first step for data analysis.
#'
#' @param data The raw data.
#' @param name_raw_json The column name in which stores user's raw data in
#'   format of json string.
#' @param name_raw_parsed The name used to store parsed data.
#' @return A [tibble][tibble::tibble-package] contains the parsed data.
#' @export
wrangle_data <- function(data,
                         name_raw_json = "game_data",
                         name_raw_parsed = "raw_parsed") {
  # return `NULL` in case of error when parsing
  parse_raw_json <- purrr::possibly(
    ~ jsonlite::fromJSON(.) |>
      dplyr::rename_with(tolower) |>
      dplyr::mutate(dplyr::across(where(is.character), tolower)),
    otherwise = NULL
  )
  data |>
    dplyr::mutate(
      "{name_raw_parsed}" := purrr::map(
        .data[[name_raw_json]],
        parse_raw_json
      ),
      .keep = "unused"
    )
}
