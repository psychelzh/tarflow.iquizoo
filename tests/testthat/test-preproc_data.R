test_that("Basic situation in `preproc_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    raw_parsed = list(
      data.frame(nhit = 1, feedback = 0),
      data.frame(nhit = 1, feedback = 1)
    )
  )
  prep_fun <- function(data, .by = NULL) {
    data |>
      dplyr::group_by(dplyr::across(dplyr::all_of(.by))) |>
      dplyr::summarise(
        nhit = mean(.data$nhit[.data$feedback == 1]),
        .groups = "drop"
      )
  }
  preproc_data(data, fn = prep_fun) |>
    expect_silent() |>
    expect_snapshot_value(style = "json2")
})
