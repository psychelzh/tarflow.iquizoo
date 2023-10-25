skip_if_not(check_source())
test_that("Default templates work", {
  params <- tibble::tribble(
    ~organization_name, ~project_name,
    "北京师范大学", "认知测评预实验"
  )
  tar_prep_iquizoo(params) |>
    expect_targets_list() |>
    expect_silent()
})

test_that("Signal error if templates not created correctly", {
  templates <- list(contents = "myfile")
  tar_prep_iquizoo(templates = templates) |>
    expect_error(class = "tarflow_bad_templates")
})

test_that("Custom templates work", {
  tar_prep_iquizoo(
    data.frame(),
    templates = setup_templates(
      contents = "sql/contents.sql"
    )
  ) |>
    expect_targets_list() |>
    expect_silent()
})

test_that("Support `data.frame` contents", {
  tar_prep_iquizoo(
    contents = data.frame(
      project_id = bit64::as.integer64(599627356946501),
      game_id = bit64::as.integer64(581943246745925)
    )
  ) |>
    expect_targets_list() |>
    expect_silent()
})

test_that("Signal error if `contents` contains no data", {
  params_bad <- tibble::tribble(
    ~organization_name, ~project_name,
    "Unexisted", "Malvalue"
  )
  tar_prep_iquizoo(params_bad) |>
    expect_error(class = "tarflow_bad_contents")
})

test_that("Workflow works", {
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "北京师范大学测试用账号", "难度测试",
        "北京师范大学", "4.19-4.20夜晚睡眠test"
      )
      tar_prep_iquizoo(params, action_raw_data = "parse")
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_snapshot_value(targets::tar_objects(), style = "json2")
  })
  skip_if_not_installed("preproc.iquizoo")
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "北京师范大学测试用账号", "难度测试"
      )
      tar_prep_iquizoo(params)
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_snapshot_value(targets::tar_objects(), style = "json2")
  })
})

test_that("Serialize check (no roundtrip error)", {
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "四川省双流棠湖中学高中部", "棠湖中学英才计划测训体验账号"
      )
      tar_prep_iquizoo(params)[1]
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_identical(
      targets::tar_read(contents_origin),
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

test_that("Ensure `action_raw_data = 'none'` work properly", {
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(tarflow.iquizoo)
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "北京师范大学测试用账号", "难度测试"
      )
      tar_prep_iquizoo(params, what = "raw_data", action_raw_data = "none")
    })
    expect_contains(
      targets::tar_manifest()$name,
      c(
        "raw_data_386196539900677",
        "raw_data_375916542735109",
        "raw_data_381576542159749",
        "raw_data_380173961339781"
      )
    )
  })
})
