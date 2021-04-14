test_that("Correctly copy config.yml file.", {
  proj_tmp <- create_local_proj()
  script <- TarScript$new()
  step_config(script)
  script$build()
  expect_snapshot_file(fs::path(proj_tmp, "config.yml"), binary = FALSE)
  expect_snapshot_file(fs::path(proj_tmp, "_targets.R"), binary = FALSE)
})
