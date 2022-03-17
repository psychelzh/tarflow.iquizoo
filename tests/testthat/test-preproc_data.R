withr::local_package("preproc.iquizoo")

test_that("Basic situation in `preproc_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    raw_parsed = list(
      data.frame(nhit = 1, feedback = 0),
      data.frame(nhit = 1, feedback = 1)
    )
  )
  preproc_data(data, fn = bart) |>
    expect_silent() |>
    expect_snapshot_value(style = "json2")
})

test_that("Complex dplyr verbs in `preproc_data()`", {
  withr::local_seed(1)
  data <- tibble::tibble(
    user_id = 1,
    raw_parsed = list(
      data.frame(
        acc = sample(c(0, 1), 20, replace = TRUE),
        type = sample(rep(c("target", "nontarget"), 10)),
        rt = runif(20, 300, 2000)
      )
    )
  )
  preproc_data(data, fn = cpt) |>
    expect_silent() |>
    expect_snapshot_value(style = "json2")
})
