test_that("Smoke test", {
  skip_if_not_installed("RMariaDB")
  skip_if_not(db_is_ready())
  params <- tibble::tribble(
    ~organization_name, ~project_name,
    "北京师范大学", "认知测评预实验"
  )
  prepare_fetch_data(params) |>
    expect_type("list") |>
    expect_length(6) |>
    expect_silent()

  params_bad <- tibble::tribble(
    ~organization_name, ~project_name,
    "Unexisted", "Malvalue"
  )
  prepare_fetch_data(params_bad) |>
    expect_warning(class = "tarflow_bad_params")

  skip_if_not_installed("preproc.iquizoo")
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      tar_option_set(
        packages = c("tarflow.iquizoo", "preproc.iquizoo")
      )
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "北京师范大学测试用账号", "难度测试",
        "北京师范大学", "4.19-4.20夜晚睡眠test"
      )
      prepare_fetch_data(params)
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_snapshot_value(targets::tar_objects(), style = "json2")
  })
})
