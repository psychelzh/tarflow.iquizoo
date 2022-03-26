test_that("Basic functions work correctly", {
  data <- tibble::tibble(
    game_data = rep(jsonlite::toJSON(data.frame(a = 1:5, b = 1:5)), 2)
  )
  wrangle_data(data) |>
    expect_silent() |>
    expect_snapshot_value(style = "json2")
  wrangle_data(data, name_raw_parsed = "parsed") |>
    expect_silent() |>
    expect_named("parsed")
})

test_that("Can deal with invalid or empty json", {
  data_case_invalid <- tibble::tibble(
    game_data = c("[1", "[]", "{}")
  )
  expect_silent(data_wrangled <- wrangle_data(data_case_invalid))
  expect_true(all(purrr::map_lgl(data_wrangled$raw_parsed, is.null)))
})

test_that("Change names and values to lowercase", {
  data_upper_case <- tibble::tibble(
    game_data = jsonlite::toJSON(data.frame(A = LETTERS[1:2]))
  )
  expect_silent(parsed <- wrangle_data(data_upper_case))
  raw_parsed <- parsed$raw_parsed[[1]]
  expect_true(stringr::str_detect(names(raw_parsed), "^[[:lower:]]+$"))
  expect_true(all(stringr::str_detect(raw_parsed[[1]], "^[[:lower:]]+$")))
})
