skip_if_not(check_source())
targets::tar_test("Workflow works", {
  skip_if_not_installed("preproc.iquizoo")
  targets::tar_script({
    params <- tibble::tribble(
      ~organization_name, ~project_name, ~course_name, ~game_name,
      "北京师范大学", "4.19-4.20夜晚睡眠test", NA, NA
    )
    tarflow.iquizoo::tar_prep_iquizoo(
      params,
      combine = "scores",
      cache = cachem::cache_mem()
    )
  })
  targets::tar_make(reporter = "silent", callr_function = NULL)
  expect_snapshot_value(targets::tar_objects(), style = "json2")
  expect_snapshot_value(targets::tar_read(users), style = "json2")
  expect_snapshot_value(targets::tar_read(scores), style = "json2")
})

targets::tar_test("Users properties fetching correctly", {
  skip_if_not_installed("preproc.iquizoo")
  targets::tar_script({
    params <- tibble::tribble(
      ~organization_name, ~project_name, ~course_name, ~game_name,
      NA, "北师大附属实验中学大脑课堂体验课前测（2023级初一）", NA, NA
    )
    contents <- fetch_iquizoo(
      read_file(setup_templates()$contents),
      params = unname(as.list(params))
    )[1, ]
    tarflow.iquizoo::tar_prep_iquizoo(
      contents = contents,
      what = "scores",
      combine = "scores",
      cache = cachem::cache_mem()
    )
  })
  targets::tar_make(reporter = "silent", callr_function = NULL)
  expect_snapshot_value(targets::tar_objects(), style = "json2")
  expect_snapshot_value(targets::tar_read(users), style = "json2")
})
