package_file <- function(type, file) {
  system.file(
    type, file,
    package = "tarflow.iquizoo"
  )
}

read_file <- function(file) {
  paste0(readLines(file), collapse = "\n")
}

create_hash_deps <- function(project_ids) {
  as.call(
    c(
      quote(list),
      syms(paste0("progress_hash_", project_ids))
    )
  )
}
