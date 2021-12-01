test_that("Basic situation in `preproc_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    game_data = c(
      jsonlite::toJSON(data.frame(nhit = 1, feedback = 0)),
      jsonlite::toJSON(data.frame(nhit = 1, feedback = 1))
    )
  )
  skip_if_not_installed("preproc.iquizoo", "1.3.0")
  library(preproc.iquizoo)
  expect_snapshot_value(
    data |>
      wrangle_data() |>
      preproc_data(.fn = bart),
    style = "json2"
  )
})

test_that("Complex dplyr verbs in `preproc_data()`", {
  set.seed(1)
  data <- tibble::tibble(
    user_id = 1,
    game_data = jsonlite::toJSON(
      data.frame(
        acc = sample(c(0, 1), 20, replace = TRUE),
        type = sample(rep(c("target", "nontarget"), 10)),
        rt = runif(20, 300, 2000)
      )
    )
  )
  skip_if_not_installed("preproc.iquizoo", "1.3.0")
  library(preproc.iquizoo)
  expect_snapshot_value(
    data |>
      wrangle_data() |>
      preproc_data(.fn = cpt),
    style = "json2"
  )
})
