withr::local_package("preproc.iquizoo")

test_that("Basic situation in `preproc_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    raw_parsed = list(
      data.frame(nhit = 1, feedback = 0),
      data.frame(nhit = 1, feedback = 1)
    )
  )
  preproc_data(data, fn = bart) |>
    expect_silent() |>
    expect_snapshot_value(style = "json2")
})
