test_that("`pickup()` smoke testing", {
  mockery::stub(pickup, "DBI::dbConnect", TRUE, 2)
  mockery::stub(pickup, "DBI::dbDisconnect", TRUE)
  mockery::stub(pickup, "DBI::dbGetQuery", data.frame())
  mockery::stub(pickup, "compose_where", "")
  mockery::stub(pickup, "odbc::odbc()", structure(0, class = "OdbcDriver"))
  withr::local_options(tarflow.driver = odbc::odbc())
  pickup("A\n{where_clause}") |>
    expect_silent() |>
    expect_equal(tibble::tibble())

  mockery::stub(pickup, "readLines", "{where_clause}")
  pickup("") |>
    expect_silent() |>
    expect_equal(tibble::tibble())
})

test_that("Works for both drivers", {
  mockery::stub(pickup, "DBI::dbConnect", TRUE)
  mockery::stub(pickup, "DBI::dbDisconnect", TRUE)
  mockery::stub(pickup, "compose_where", "")
  mockery::stub(pickup, "DBI::dbGetQuery", data.frame())
  mockery::stub(pickup, "readLines", "{where_clause}")
  withr::with_options(
    list(tarflow.driver = structure(0, class = "OdbcDriver")),
    pickup("") |>
      expect_silent() |>
      expect_equal(tibble::tibble())
  )
  withr::with_options(
    list(tarflow.driver = structure(0, class = "MariaDBDriver")),
    pickup("") |>
      expect_silent() |>
      expect_equal(tibble::tibble())
  )
})

test_that("Error when option incorrect", {
  withr::with_options(
    list(tarflow.driver = NULL),
    pickup("") |>
      expect_error("Driver must be either OdbcDriver or MariaDBDriver.")
  )
})
