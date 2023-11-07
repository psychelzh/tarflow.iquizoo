test_that("Basic situation for `wrangle_data()`", {
  js_str <- r"([{"a": 1, "b": 2}])"
  data <- tibble::tibble(game_data = js_str)
  wrangle_data(data) |>
    expect_silent() |>
    expect_named("raw_parsed") |>
    purrr::pluck("raw_parsed", 1) |>
    expect_identical(jsonlite::fromJSON(js_str))
  wrangle_data(data, name_raw_parsed = "parsed") |>
    expect_silent() |>
    expect_named("parsed")
})

test_that("Can deal with invalid or empty json", {
  data_case_invalid <- tibble::tibble(
    game_data = c("[1", "[]", "{}")
  )
  wrangle_data(data_case_invalid) |>
    expect_silent() |>
    purrr::pluck("raw_parsed") |>
    purrr::map_lgl(is.null) |>
    all() |>
    expect_true()
})

test_that("Change names and values to lowercase", {
  js_str <- r"([{"A": "A"}, {"A": "B"}])"
  data <- tibble::tibble(game_data = js_str)
  wrangle_data(data) |>
    expect_silent() |>
    purrr::pluck("raw_parsed", 1) |>
    expect_identical(data.frame(a = c("a", "b")))
})

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
  tibble::tibble(raw_parsed = list(NULL)) |>
    preproc_data(prep_fun) |>
    expect_null()
})

test_that("Can deal with mismatch column types in raw data", {
  skip_if_not_installed("tidytable")
  data <- tibble::tibble(
    user_id = 1:3,
    raw_parsed = list(
      data.frame(nhit = 1, feedback = 0),
      data.frame(nhit = 2, feedback = 1),
      data.frame(nhit = "3", feedback = 1)
    )
  )
  preproc_data(data, fn = prep_fun) |>
    expect_silent() |>
    expect_snapshot_value(style = "json2")
})
