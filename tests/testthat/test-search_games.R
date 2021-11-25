test_that("Correctly combine `game_info`", {
  mockery::stub(
    search_games, "pickup",
    function (query_file, ...) tibble::tibble(read.csv(query_file))
  )
  expect_snapshot(
    search_games(NULL, query_file = "dummy/test.sql")
  )
  expect_snapshot(
    search_games(NULL, known_only = FALSE, query_file = "dummy/test.sql")
  )
})

test_that("Error when query file not found", {
  expect_error(search_games(NULL), class = "query_file_miss")
})
