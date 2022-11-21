config_where_chr <- "content.name = 'test'"
config_where_list <- list(
  list(table = "content", field = "name", values = "test")
)
config_where_df <- data.frame(
  table = "content", field = "name", values = "test"
)
to_insert <- list(
  table = "content",
  field = "name",
  values = "test_new"
)
test_that("Check method dispatch works", {
  expect_snapshot(insert_where(config_where_chr, to_insert))
  expect_snapshot(insert_where(config_where_list, to_insert))
  expect_snapshot(insert_where(config_where_df, to_insert))
})

test_that("Check `replace = FALSE`", {
  expect_snapshot(
    insert_where(
      config_where_list,
      to_insert,
      replace = FALSE
    )
  )
})

test_that("Works with empty old", {
  expect_snapshot(insert_where(NULL, to_insert))
  expect_snapshot(insert_where(list(), to_insert))
  expect_snapshot(insert_where(data.frame(), to_insert))
})

test_that("Error for invalid where config", {
  expect_error(
    insert_where(config_where_list, list(table2 = "")),
    class = "where_invalid"
  )
})

test_that("Insert single game", {
  expect_snapshot_value(insert_where_single_game(NULL, "dummy"))
})

test_that("Can compose after `insert_where()`", {
  insert_where(config_where_list, to_insert) |>
    compose_where() |>
    expect_snapshot_value()
})
