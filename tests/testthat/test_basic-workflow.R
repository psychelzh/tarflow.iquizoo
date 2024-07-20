skip_if_not(check_source())
test_that("Workflow works", {
  skip_if_not_installed("preproc.iquizoo")
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "北京师范大学", "4.19-4.20夜晚睡眠test"
      )
      tarflow.iquizoo::tar_prep_iquizoo(params, combine = "scores")
    })
    expect_silent(targets::tar_make(reporter = "silent", callr_function = NULL))
    expect_snapshot_value(targets::tar_objects(), style = "json2")
    expect_snapshot_value(targets::tar_read(users), style = "json2")
    expect_snapshot_value(targets::tar_read(scores), style = "json2")
  })
})
