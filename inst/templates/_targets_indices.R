# load required packages used in pipeline setup
library(targets)
library(tarchetypes)
# set required packages used in pipeline running
tar_option_set(packages = c("tidyverse", "dataproc.iquizoo", "tarflow.iquizoo"))
# track changes in the following packages
tar_option_set(imports = c("dataproc.iquizoo", "tarflow.iquizoo"))
# build sub-targets of calculating indices for each game
targets_indices <- tarflow.iquizoo::build_targets_indices()
# add more jobs in the following plans
list(
  tar_file(file_config, "config.yml"),
  tar_file(query_tmpl_data, "sql/data.tmpl.sql"),
  tar_file(query_tmpl_users, "sql/users.tmpl.sql"),
  tar_target(config_where, config::get("where", file = file_config)),
  tar_fst_tbl(
    data,
    fetch_from_v3(query_tmpl_data, config_where) %>%
      group_by(game_id) %>%
      tar_group(),
    iteration = "group"
  ),
  tar_fst_tbl(users, fetch_from_v3(query_tmpl_users, config_where)),
  targets_indices,
  tar_combine(game_indices, targets_indices, format = "fst_tbl")
)
