create_local_proj <- function(dir = tempdir(), env = parent.frame()) {
  old_proj <- usethis::proj_get()

  # create new project
  usethis::create_project(dir, open = FALSE)
  withr::defer(fs::dir_delete(dir), envir = env)

  # switch to new project
  usethis::proj_set(dir)
  withr::defer(usethis::proj_set(old_proj, force = TRUE), envir = env)

  dir
}
