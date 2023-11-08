prep_fun <- function(data, .by = NULL) {
  data |>
    group_by(pick(all_of(.by))) |>
    summarise(
      nhit = mean(.data$nhit[.data$feedback == 1]),
      .groups = "drop"
    )
}
