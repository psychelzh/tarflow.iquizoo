test_that("Check method dispatch works", {
  config_where <- list(
    list(table = "content", field = "name", values = "test")
  )
  expect_snapshot(insert_where(config_where, list(table = "content")))
  config_where <- data.frame(
    table = "content", field = "name", values = "test"
  )
  expect_snapshot(
    insert_where(config_where, list(table = "content", values = 1))
  )
})

test_that("Check `replace = FALSE`", {
  config_where <- list(
    list(table = "content", field = "name", values = "test")
  )
  expect_snapshot(
    insert_where(config_where, list(table = "content"), replace = FALSE)
  )
})
