prep_fun <- function(data, .by = NULL) {
  data |>
    dplyr::group_by(dplyr::pick(dplyr::all_of(.by))) |>
    dplyr::summarise(
      nhit = mean(.data$nhit[.data$feedback == 1]),
      .groups = "drop"
    )
}
