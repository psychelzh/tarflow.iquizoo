test_that("Correctly combine `game_info`", {
  mockery::stub(
    search_games, "pickup",
    tibble::tibble(
      game_id = bit64::as.integer64(
        c("225528186135045", "225528186135046")
      )
    )
  )
  expect_snapshot_value(
    search_games(),
    style = "json2"
  )
  expect_snapshot_value(
    search_games(known_only = FALSE),
    style = "json2"
  )
})

test_that("Support `integer64`", {
  mockery::stub(
    search_games, "pickup",
    tibble::tibble(game_id = bit64::as.integer64(225528186135045))
  )
  expect_snapshot_value(
    search_games(),
    style = "json2"
  )
})
