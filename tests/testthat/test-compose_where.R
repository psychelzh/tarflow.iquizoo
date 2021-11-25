test_that("Works for all the class types", {
  config_where <- list(
    list(table = "content", field = "name", values = "test")
  )
  expect_snapshot_value(where_clause <- compose_where(config_where))
  expect_equal(compose_where(config_where), where_clause)
  expect_equal(compose_where(where_clause), where_clause)
  expect_equal(compose_where(NULL), "")
})

test_that("Works for multiple values", {
  config_where <- list(
    list(table = "content", field = "name", values = c("test1","test2"))
  )
  expect_snapshot_value(where_clause <- compose_where(config_where))
})
