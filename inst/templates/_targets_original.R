# load required packages used in pipeline setup
library(targets)
library(tarchetypes)
# set required packages used in pipeline running
tar_option_set(packages = c("tidyverse", "tarflow.iquizoo"))
# add more jobs in the following plans
list(
  tar_file(file_config, "config.yml"),
  tar_file(query_tmpl_data, "sql/data.tmpl.sql"),
  tar_file(query_tmpl_users, "sql/users.tmpl.sql"),
  tar_target(config_where, config::get("where", file = file_config)),
  tar_fst_tbl(data, tarflow.iquizoo::fetch(query_tmpl_data, config_where)),
  tar_fst_tbl(users, tarflow.iquizoo::fetch(query_tmpl_users, config_where))
)
