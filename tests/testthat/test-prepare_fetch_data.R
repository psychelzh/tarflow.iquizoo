test_that("Smoke test", {
  skip_if_not_installed("odbc")
  skip_if(!"iquizoo-v3" %in% odbc::odbcListDataSources()$name)
  tbl_params <- tibble::tribble(
    ~course_name, ~course_period,
    "509测试", "高中"
  )
  prepare_fetch_data(tbl_params) |>
    expect_silent()
  tbl_params <- tibble::tribble(
    ~course_name, ~course_period,
    "11.14课程 测试", 0,
    "509测试", 7
  )
  prepare_fetch_data(tbl_params) |>
    expect_silent()

  tbl_params_bad <- tibble::tribble(
    ~course_name, ~course_period,
    "Unexisted", "Malvalue"
  )
  prepare_fetch_data(tbl_params_bad) |>
    expect_error(class = "tarflow_invalid_period")

  tbl_params_bad <- tibble::tribble(
    ~course_name, ~course_period,
    "Unexisted", 7
  )
  prepare_fetch_data(tbl_params_bad) |>
    expect_warning(class = "tarflow_bad_params")

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
