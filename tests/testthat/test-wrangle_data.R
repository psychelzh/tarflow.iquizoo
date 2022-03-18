test_that("Basic situation of `wrange_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    game_id = LETTERS[1:2],
    game_time = rep("1990-01-01", 2),
    game_data = rep(jsonlite::toJSON(data.frame(a = 1:5, b = 1:5)), 2)
  )
  expect_silent(data_wrangled <- wrangle_data(data))
  expect_snapshot_value(data_wrangled, style = "json2")
})

test_that("Can deal with invalid or empty json in `wrangle_data()`", {
  data_case_invalid <- tibble::tibble(
    user_id = 1:3,
    game_data = c("[1", "[]", "{}")
  )
  expect_silent(data_wrangled <- wrangle_data(data_case_invalid))
  expect_true(all(purrr::map_lgl(data_wrangled$raw_parsed, is.null)))
})

test_that("Change names and values to lowercase in `wrangle_data()", {
  data <- tibble::tibble(
    user_id = 1,
    game_data = jsonlite::toJSON(data.frame(A = LETTERS[1:2]))
  )
  expect_silent(parsed <- wrangle_data(data))
  raw_parsed <- parsed$raw_parsed[[1]]
  expect_true(stringr::str_detect(names(raw_parsed), "^[[:lower:]]+$"))
  expect_true(all(stringr::str_detect(raw_parsed[[1]], "^[[:lower:]]+$")))
})
