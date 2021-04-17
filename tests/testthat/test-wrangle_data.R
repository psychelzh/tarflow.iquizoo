test_that("Should return with attributes (meta information):", {
  data <- tibble::tibble(
    user_id = 1,
    game_id = "aabb",
    game_time = "1990-01-01",
    game_data = jsonlite::toJSON(data.frame(a = 1:5, b = 1:5))
  )
  expect_snapshot(wrangle_data(data, "game_data"))
})
