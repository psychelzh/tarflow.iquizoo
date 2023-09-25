test_that("Test with mock", {
  with_mocked_bindings(
    fetch_query_mem = \(...) {
      tibble::tibble(
        project_id = bit64::as.integer64(1),
        game_id = data.iquizoo::game_info$game_id[1:2],
        course_date = as.Date("2023-01-01")
      )
    },
    prepare_fetch_data(data.frame()) |>
      expect_silent()
  )
  with_mocked_bindings(
    fetch_query_mem = \(...) data.frame(),
    prepare_fetch_data(data.frame()) |>
      expect_warning(class = "tarflow_bad_params")
  )
})

test_that("Smoke test", {
  skip_if_not_installed("RMariaDB")
  name_db_src <- "iquizoo-v3"
  skip_if_not(DBI::dbCanConnect(RMariaDB::MariaDB(), groups = name_db_src))
  params <- tibble::tribble(
    ~organization_name, ~project_name,
    "北京师范大学", "认知测评预实验"
  )
  prepare_fetch_data(params) |>
    expect_s3_class("tarflow_targets") |>
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
