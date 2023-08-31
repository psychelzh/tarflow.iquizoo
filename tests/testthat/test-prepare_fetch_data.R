test_that("Smoke test", {
  skip_if_not_installed("odbc")
  skip_if(!"iquizoo-v3" %in% odbc::odbcListDataSources()$name)
  tbl_params <- tibble::tribble(
    ~course_name, ~course_period,
    "509测试", "高中"
  )
  prepare_fetch_data(tbl_params) |>
    expect_silent()

  tbl_params_bad <- tibble::tribble(
    ~course_name, ~course_period,
    "Unexisted", "Malvalue"
  )
  memoise::drop_cache(fetch_config_tbl_mem)("Unexisted", "Malvalue")
  prepare_fetch_data(tbl_params_bad) |>
    expect_null() |>
    expect_warning(class = "tarflow_invalid_period") |>
    expect_warning(class = "tarflow_bad_params")
})

test_that("Work with `tar_make()", {
  skip_if_not_installed("odbc")
  skip_if(!"iquizoo-v3" %in% odbc::odbcListDataSources()$name)
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      tar_option_set(
        packages = c("tarflow.iquizoo", "preproc.iquizoo")
      )
      tbl_params <- tibble::tribble(
        ~course_name, ~course_period,
        "509测试", "高中"
      )
      prepare_fetch_data(tbl_params)
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_equal(length(targets::tar_objects()), 39L)
  })
})
