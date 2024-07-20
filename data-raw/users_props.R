## code to prepare `users_props` dataset goes here

users_props <- readr::read_csv(
  "data-raw/users_props.csv",
  show_col_types = FALSE
)
usethis::use_data(users_props, overwrite = TRUE, internal = TRUE)
