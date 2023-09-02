test_that("Test with mock", {
  with_mocked_bindings(
    fetch_preset_mem = \(...) {
      tibble::tibble(
        project_id = bit64::as.integer64(1),
        game_id = data.iquizoo::game_info$game_id[1:2],
        course_date = as.Date("2023-01-01")
      )
    },
    prepare_fetch_data(data.frame(x = 1)) |>
      expect_silent()
  )
  with_mocked_bindings(
    fetch_preset_mem = \(...) data.frame(),
    prepare_fetch_data(data.frame(x = 1)) |>
      expect_warning(class = "tarflow_bad_params")
  )
})

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
