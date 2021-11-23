test_that("Basic situation of `wrange_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    game_id = LETTERS[1:2],
    game_time = rep("1990-01-01", 2),
    game_data = rep(jsonlite::toJSON(data.frame(a = 1:5, b = 1:5)), 2)
  )
  data_wrangled <- wrangle_data(data)
  expect_snapshot(data_wrangled)
  expect_named(data_wrangled, c("meta", "data"))
  expect_snapshot(data_wrangled$meta)
  expect_snapshot(data_wrangled$data)
  key <- ".id"
  expect_equal(data_wrangled, wrangle_data(data, name_key = key))
})

test_that("Can deal with invalid json (remove it) in `wrangle_data()`", {
  data_case_invalid <- tibble::tibble(
    user_id = 1,
    game_data = jsonlite::toJSON(
      data.frame(NHit = 10, Feedback = 1)
    ) %>%
      substr(1, 5)
  )
  expect_silent(be_null <- wrangle_data(data_case_invalid))
  expect_null(be_null)
})

test_that("Can deal with empty json (remove it) in `wrangle_data()`", {
  data_case_empty1 <- tibble::tibble(
    user_id = 1,
    game_data = "[]"
  )
  data_case_empty2 <- tibble::tibble(
    user_id = 1,
    game_data = "{}"
  )
  expect_silent(be_null <- wrangle_data(data_case_empty1))
  expect_null(be_null)
  expect_silent(be_null <- wrangle_data(data_case_empty2))
  expect_null(be_null)
})

test_that("Remove duplicates in `wrangle_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    game_data = c(
      jsonlite::toJSON(data.frame(a = 1:5, b = 1:5)),
      jsonlite::toJSON(data.frame(a = 2:4, b = 1:3))
    )
  )
  data_dup <- data %>%
    dplyr::slice(seq_len(nrow(data)), 1)
  parsed_dup <- wrangle_data(data_dup)
  expect_snapshot(parsed_dup)
  expect_named(parsed_dup, c("meta", "data"))
  expect_snapshot(parsed_dup$meta)
  expect_snapshot(parsed_dup$data)
  expect_identical(parsed_dup, wrangle_data(data))
})

test_that("Basic situation in `preproc_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    game_data = c(
      jsonlite::toJSON(data.frame(nhit = 1, feedback = 0)),
      jsonlite::toJSON(data.frame(nhit = 1, feedback = 1))
    )
  )
  dm_indices <- data |>
    wrangle_data() |>
    preproc_data(prep_fun_name = bart)
  expect_snapshot(dm_indices)
  expect_named(dm_indices, c("meta", "indices"))
  expect_snapshot(dm_indices$meta)
  expect_snapshot(dm_indices$indices)
})
