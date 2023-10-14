skip_if_not(check_source())
test_that("Default templates work", {
  params <- tibble::tribble(
    ~organization_name, ~project_name,
    "北京师范大学", "认知测评预实验"
  )
  prepare_fetch_data(params) |>
    expect_type("list") |>
    expect_length(6) |>
    expect_silent()
})

test_that("Custom templates work", {
  prepare_fetch_data(
    data.frame(),
    templates = tarflow.iquizoo::setup_templates(
      contents = "sql/contents.sql"
    )
  ) |>
    expect_type("list") |>
    expect_length(6) |>
    expect_silent()
})

test_that("Bad params show warning", {
  params_bad <- tibble::tribble(
    ~organization_name, ~project_name,
    "Unexisted", "Malvalue"
  )
  prepare_fetch_data(params_bad) |>
    expect_warning(class = "tarflow_bad_params")
})

test_that("Workflow works", {
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      tar_option_set(packages = "tarflow.iquizoo")
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "北京师范大学测试用账号", "难度测试",
        "北京师范大学", "4.19-4.20夜晚睡眠test"
      )
      prepare_fetch_data(params, action_raw_data = "parse")
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_snapshot_value(targets::tar_objects(), style = "json2")
  })
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

test_that("Serialize check (no roundtrip error)", {
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      tar_option_set(
        packages = c("tarflow.iquizoo", "preproc.iquizoo")
      )
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "四川省双流棠湖中学高中部", "棠湖中学英才计划测训体验账号"
      )
      prepare_fetch_data(params)[1]
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_identical(
      targets::tar_read(contents),
      fetch_iquizoo_mem(
        read_file(setup_templates()$contents),
        params = unname(as.list(
          tibble::tribble(
            ~organization_name, ~project_name,
            "四川省双流棠湖中学高中部", "棠湖中学英才计划测训体验账号"
          )
        ))
      )
    )
  })
})
