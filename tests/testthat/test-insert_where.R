config_where <- list(
  list(table = "content", field = "name", values = "test")
)
test_that("Check method dispatch works", {
  expect_snapshot(
    insert_where(
      config_where,
      list(
        table = "content",
        field = "name",
        values = "test_new"
      )
    )
  )
  config_where <- data.frame(
    table = "content", field = "name", values = "test"
  )
  expect_snapshot(
    insert_where(
      config_where, list(
        table = "content",
        field = "name",
        values = "test_new"
      )
    )
  )
})

test_that("Check `replace = FALSE`", {
  expect_snapshot(
    insert_where(
      config_where, list(
        table = "content",
        field = "name",
        values = "test_new"
      ),
      replace = FALSE
    )
  )
})

test_that("Works with empty old", {
  expect_snapshot(
    insert_where(NULL, list(
      table = "content",
      field = "name",
      values = "test_new"
    ))
  )
  expect_snapshot(
    insert_where(list(), list(
      table = "content",
      field = "name",
      values = "test_new"
    ))
  )
  expect_snapshot(
    insert_where(data.frame(), list(
      table = "content",
      field = "name",
      values = "test_new"
    ))
  )
})

test_that("Error for invalid where config", {
  expect_error(
    insert_where(config_where, list(table2 = "")),
    class = "where_invalid"
  )
})
