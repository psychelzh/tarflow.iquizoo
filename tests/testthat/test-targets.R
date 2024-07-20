skip_if_not(check_source())
test_that("Default templates work", {
  params <- tibble::tribble(
    ~organization_name, ~project_name,
    "北京师范大学", "认知测评预实验"
  )
  tar_prep_iquizoo(params) |>
    expect_targets_list()
})

test_that("Signal error if templates not created correctly", {
  templates <- list(contents = "myfile")
  tar_prep_iquizoo(NULL, templates = templates) |>
    expect_error(class = "tarflow_bad_templates")
})

test_that("Custom templates work", {
  tar_prep_iquizoo(
    data.frame(),
    templates = setup_templates(
      contents = "sql/contents.sql"
    )
  ) |>
    expect_targets_list()
})

test_that("Support `data.frame` contents", {
  tar_prep_iquizoo(
    contents = data.frame(
      project_id = bit64::as.integer64(599627356946501),
      game_id = bit64::as.integer64(581943246745925)
    )
  ) |>
    expect_targets_list()
})

test_that("Signal error if `contents` contains no data", {
  params_bad <- tibble::tribble(
    ~organization_name, ~project_name,
    "Unexisted", "Malvalue"
  )
  tar_prep_iquizoo(params_bad) |>
    expect_error(class = "tarflow_bad_contents")
})
