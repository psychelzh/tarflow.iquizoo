test_that("Works for all the class types", {
  config_where <- list(
    list(table = "content", field = "name", values = "test")
  )
  expect_snapshot_value(where_clause <- compose_where(config_where))
  expect_equal(compose_where(config_where), where_clause)
  expect_equal(compose_where(where_clause, add_keyword = FALSE), where_clause)
  expect_equal(compose_where(NULL), "")
})

test_that("`add_keyword` works properly", {
  config_where <- list(
    list(table = "content", field = "name", values = "test")
  )
  expect_silent(where_clause <- compose_where(config_where, add_keyword = FALSE))
  expect_false(grepl("^WHERE", where_clause))
  expect_error(compose_where(NULL, add_keyword = TRUE), class = "arg_bad_value")
})

test_that("Works for multiple values", {
  config_where <- list(
    list(table = "content", field = "name", values = c("test1", "test2"))
  )
  expect_snapshot_value(where_clause <- compose_where(config_where))
})
