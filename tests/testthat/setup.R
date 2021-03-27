create_local_proj <- function(dir = tempdir(), env = parent.frame()) {
  old_proj <- usethis::proj_get()

  # create new project
  usethis::create_project(dir, rstudio = FALSE, open = FALSE)
  withr::defer(
    # do not remove temporary directory itself
    purrr::walk(
      list.files(dir, full.names = TRUE, recursive = TRUE, all.files = TRUE),
      ~ unlink(.x)
    ),
    envir = env
  )

  # switch to new project
  usethis::proj_set(dir)
  withr::defer(usethis::proj_set(old_proj, force = TRUE), envir = env)

  dir
}

test_schema <- function(test_id, ...) {
  dir <- create_local_proj()

  # snapshot all file names before building
  files_before <- list.files(dir, full.names = TRUE, recursive = TRUE, all.files = TRUE)

  # do schema building
  use_targets(...)

  # snapshot all file names after building
  files_after <- list.files(dir, full.names = TRUE, recursive = TRUE, all.files = TRUE)

  # build snapshot test
  purrr::walk(
    setdiff(files_after, files_before),
    ~ expect_snapshot_file(
      .x,
      paste(test_id, basename(.x), sep = "_"),
      binary = FALSE
    )
  )
}

