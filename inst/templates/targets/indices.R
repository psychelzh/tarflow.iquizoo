# load required packages used in pipeline setup
library(conflicted)
conflict_prefer("filter", "dplyr", quiet = TRUE)
options(tidyverse.quiet = TRUE)
library(tidyverse)
library(targets)
library(tarchetypes)
# set required packages used in pipeline running
tar_option_set(packages = c("tidyverse", "dataproc.iquizoo", "tarflow.iquizoo"))
# track changes in the following packages
tar_option_set(imports = c("dataproc.iquizoo", "tarflow.iquizoo"))
# create all the static targets of indices
targets_indices <- tar_map(
  values = tarflow.iquizoo::gameinfo %>%
    filter(game_name %in% get_game_names()) %>%
    transmute(game_id, game_name_abbr, prep_fun = syms(prep_fun)),
  tar_target(
    indices,
    calc_indices(data, prep_fun, game_id)
  ),
  names = game_name_abbr
)
# add more jobs in the following plans
tar_pipeline(
  tar_file(file_config, "config.yml"),
  tar_file(query_tmpl_data, "sql/data.tmpl.sql"),
  tar_file(query_tmpl_users, "sql/users.tmpl.sql"),
  tar_target(config_where, config::get("where", file = file_config)),
  tar_fst_tbl(data, fetch_from_v3(query_tmpl_data, config_where)),
  tar_fst_tbl(users, fetch_from_v3(query_tmpl_users, config_where)),
  targets_indices,
  tar_combine(game_indices, targets_indices, format = "fst_tbl")
)
