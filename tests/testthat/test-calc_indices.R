data <- tibble::tibble(
  id = 1,
  game_data = jsonlite::toJSON(
    data.frame(NHit = 10, Feedback = 1)
  )
)
data_case_invalid <- tibble::tibble(
  id = 1,
  game_data = jsonlite::toJSON(
    data.frame(NHit = 10, Feedback = 1)
  ) %>%
    substr(1, 5)
)
data_case_empty1 <- tibble::tibble(
  id = 1,
  game_data = "[]"
)
data_case_empty2 <- tibble::tibble(
  id = 1,
  game_data = "{}"
)

test_that("Works for regular case", {
  expect_snapshot(calc_indices(data, bart))
})

test_that("Can deal with invalid json (remove it)", {
  expect_silent(be_null <- calc_indices(data_case_invalid, bart))
  expect_null(be_null)
})

test_that("Can deal with empty json (remove it)", {
  expect_silent(be_null <- calc_indices(data_case_empty1, bart))
  expect_null(be_null)
  expect_silent(be_null <- calc_indices(data_case_empty2, bart))
  expect_null(be_null)
})
