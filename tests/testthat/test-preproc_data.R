withr::local_package("preproc.iquizoo")

test_that("Basic situation in `preproc_data()`", {
  data <- tibble::tibble(
    user_id = 1:2,
    game_data = c(
      jsonlite::toJSON(data.frame(nhit = 1, feedback = 0)),
      jsonlite::toJSON(data.frame(nhit = 1, feedback = 1))
    )
  )
  dm_results <- data |>
    wrangle_data() |>
    preproc_data(.fn = bart)
  expect_snapshot_output(dm_results)
  expect_snapshot_output(dm::dm_get_tables(dm_results))
})

test_that("Complex dplyr verbs in `preproc_data()`", {
  withr::local_seed(1)
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
  dm_results <- data |>
    wrangle_data() |>
    preproc_data(.fn = cpt)
  expect_snapshot_output(dm_results)
  expect_snapshot_output(dm::dm_get_tables(dm_results))
})
