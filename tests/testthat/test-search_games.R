test_that("Correctly combine `game_info`", {
  skip_on_os("windows")
  mockery::stub(
    search_games, "pickup",
    function(query_file, ...) tibble::tibble(read.csv(query_file))
  )
  expect_snapshot_value(
    search_games(query_file = "dummy/test.sql"),
    style = "json2"
  )
  expect_snapshot_value(
    search_games(known_only = FALSE, query_file = "dummy/test.sql"),
    style = "json2"
  )
})

test_that("Error when query file not found", {
  expect_error(search_games(NULL), class = "query_file_miss")
})
