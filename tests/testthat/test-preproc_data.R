prep_fun <- function(data, .by = NULL) {
  data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(.by))) |>
    dplyr::summarise(
      nhit = mean(.data$nhit[.data$feedback == 1]),
      .groups = "drop"
    )
}

test_that("Basic situation in `preproc_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    raw_parsed = list(
      data.frame(nhit = 1, feedback = 0),
      data.frame(nhit = 1, feedback = 1)
    )
  )
  preproc_data(data, fn = prep_fun) |>
    expect_silent() |>
    expect_snapshot_value(style = "json2")
  expect_null(preproc_data(tibble::tibble(raw_parsed = list(NULL)), prep_fun))
})

test_that("Can deal with mismatch column types in raw data", {
  data <- tibble::tibble(
    user_id = 1:2,
    raw_parsed = list(
      data.frame(nhit = 1, feedback = 0),
      data.frame(nhit = "1", feedback = 1)
    )
  )
  preproc_data(data, fn = prep_fun) |>
    expect_silent() |>
    expect_snapshot_value(style = "json2")
})

test_that("Abort if unrecognized error occured", {
  data <- tibble::tibble(
    user_id = 1:2,
    raw_parsed = list(
      data.frame(nhit = 1, feedback = 0),
      1
    )
  )
  preproc_data(data, fn = prep_fun) |>
    expect_error(class = "tarflow/unnest_incompatible")
})
