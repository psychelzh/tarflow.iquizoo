test_that("`use_targets()`: 'indices' schema with no further input", {
  test_schema(
    test_id = "indices-common",
    schema = "indices"
  )
})

test_that("`use_targets()`: 'indices' schema with `separate = FALSE`", {
  test_schema(
    test_id = "indices-no-sep",
    schema = "indices",
    separate = FALSE
  )
})

test_that("`use_targets()`: 'indices' schema with `ignore_tar = FALSE`", {
  test_schema(
    test_id = "indices-keep-tar",
    schema = "indices",
    ignore_tar = FALSE
  )
})

test_that("`use_targets()`: 'scores' schema with no further input", {
  test_schema(
    test_id = "scores-common",
    schema = "scores"
  )
})

test_that("`use_targets()`: 'scores' schema with `separate = FALSE`", {
  test_schema(
    test_id = "scores-no-sep",
    schema = "scores",
    separate = FALSE
  )
})

test_that("`use_targets()`: 'scores' schema with `ignore_tar = FALSE`", {
  test_schema(
    test_id = "scores-keep-tar",
    schema = "scores",
    ignore_tar = FALSE
  )
})

test_that("`use_targets()`: 'original' schema with no further input", {
  test_schema(
    test_id = "original-common",
    schema = "original"
  )
})

test_that("`use_targets()`: 'original' schema with `separate = FALSE`", {
  test_schema(
    test_id = "original-no-sep",
    schema = "original",
    separate = FALSE
  )
})

test_that("`use_targets()`: 'original' schema with `ignore_tar = FALSE`", {
  test_schema(
    test_id = "original-keep-tar",
    schema = "original",
    ignore_tar = FALSE
  )
})
