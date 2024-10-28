# nocov start

#' Get the names of the user properties.
#'
#' @return A character vector of the names.
#' @export
get_users_props_names <- function() {
  c(
    "user_name",
    "user_sex",
    "user_dob",
    "user_id_card",
    "user_id_student",
    "user_phone",
    "organization_name",
    "organization_country",
    "organization_province",
    "organization_city",
    "organization_district",
    "grade_name",
    "class_name_admin",
    "class_name_teach"
  )
}

#' Clean user information
#'
#' @param users A [data.frame] contains the user information.
#' @param props A character vector of the user properties to keep.
#' @return A [data.frame] contains the cleaned user information.
#' @export
clean_user_info <- function(users, props) {
  users |>
    dplyr::mutate(
      class_type = factor(
        .data$class_type,
        1:2,
        c("class_name_admin", "class_name_teach")
      )
    ) |>
    tidyr::pivot_wider(
      names_from = "class_type",
      values_from = "class_name",
      names_expand = TRUE
    ) |>
    dplyr::select(tidyselect::all_of(c("user_id", props)))
}

package_file <- function(type, file) {
  system.file(
    type, file,
    package = "tarflow.iquizoo"
  )
}

read_file <- function(file) {
  paste0(readLines(file), collapse = "\n")
}

# nocov end
