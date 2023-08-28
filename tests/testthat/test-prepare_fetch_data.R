test_that("Smoke test", {
  skip_on_ci()
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      tar_option_set(
        packages = c("tarflow.iquizoo", "preproc.iquizoo")
      )
      tbl_params <- tibble::tribble(
        ~course_name, ~course_period,
        "509测试", "高中"
      )
      tarflow.iquizoo::prepare_fetch_data(tbl_params)
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_equal(length(targets::tar_objects()), 39L)
  })
})
