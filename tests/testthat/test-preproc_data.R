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
  dm_indices <- data |>
    wrangle_data() |>
    preproc_data(.fn = bart)
  expect_snapshot(dm_indices)
  expect_snapshot(dm::dm_get_tables(dm_indices))
})

test_that("Complex dplyr verbs in `preproc_data()`", {
  set.seed(1)
  data <- tibble::tibble(
    user_id = 1,
    game_data = jsonlite::toJSON(
      data.frame(
        acc = sample(c(0, 1), 20, replace = TRUE),
        type = sample(rep(c("left", "right"), 10)),
        rt = runif(20, 300, 2000)
      )
    )
  )
  skip_if_not_installed("preproc.iquizoo", "1.3.0")
  library(preproc.iquizoo)
  dm_indices <- data |>
    wrangle_data() |>
    preproc_data(.fn = cpt)
  expect_snapshot(dm_indices)
  expect_snapshot(dm::dm_get_tables(dm_indices))
})
