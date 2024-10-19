test_that("`parse_data()` works", {
  js_str <- r"([{"a": 1, "b": 2}])"
  data <- data.frame(game_data = js_str)
  parse_data(data)$raw_parsed[[1]] |>
    expect_identical(jsonlite::fromJSON(js_str))
  parse_data(data, name_raw_parsed = "parsed") |>
    expect_named("parsed")
})

test_that("Can deal with invalid or empty json", {
  data_case_invalid <- data.frame(game_data = "[1")
  parse_data(data_case_invalid)$raw_parsed[[1]] |>
    expect_null() |>
    expect_warning("Failed to parse json string")
  data_case_empty <- data.frame(game_data = c("[]", "{}"))
  parse_data(data_case_empty)$raw_parsed |>
    lapply(expect_length, 0)
})
