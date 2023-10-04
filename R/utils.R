package_file <- function(type, file) {
  system.file(
    type, file,
    package = "tarflow.iquizoo"
  )
}

read_file <- function(file) {
  paste0(readLines(file), collapse = "\n")
}
