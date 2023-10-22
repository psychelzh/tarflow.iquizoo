test_that("Ensure source checking works", {
  source <- list(driver = RMariaDB::MariaDB())
  fetch_iquizoo(source = source) |>
    expect_error(class = "tarflow_bad_source")
  check_source(source = source) |>
    expect_error(class = "tarflow_bad_source")
  source_invalid <- setup_source(driver = NULL)
  fetch_iquizoo(source = source_invalid) |>
    expect_error(class = "tarflow_bad_driver")
  check_source(source = source_invalid) |>
    expect_false()
})
