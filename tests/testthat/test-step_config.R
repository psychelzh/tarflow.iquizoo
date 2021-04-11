test_that("Correctly copy config.yml file.", {
  proj_tmp <- create_local_proj()
  step_config()
  expect_snapshot_file(fs::path(proj_tmp, "config.yml"), binary = FALSE)
})
