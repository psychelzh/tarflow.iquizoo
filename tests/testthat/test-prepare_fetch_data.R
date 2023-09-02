test_that("Smoke test", {
  skip_if_not_installed("odbc")
  skip_if(!"iquizoo-v3" %in% odbc::odbcListDataSources()$name)
  tbl_params <- tibble::tribble(
    ~organization_name, ~project_name,
    "北京师范大学", "认知测评预实验"
  )
  prepare_fetch_data(tbl_params) |>
    expect_silent()

  tbl_params_bad <- tibble::tribble(
    ~organization_name, ~project_name,
    "Unexisted", "Malvalue"
  )
  prepare_fetch_data(tbl_params_bad) |>
    expect_warning(class = "tarflow_bad_params")

  skip_if_not_installed("preproc.iquizoo")
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      tar_option_set(
        packages = c("tarflow.iquizoo", "preproc.iquizoo")
      )
      tbl_params <- tibble::tribble(
        ~organization_name, ~project_name,
        "北京师范大学测试用账号", "难度测试"
      )
      prepare_fetch_data(tbl_params)
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_equal(length(targets::tar_objects()), 20L)
  })
})
