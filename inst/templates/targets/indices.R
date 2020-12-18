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
  values = read_csv("settings/game_info.csv", col_types = cols()) %>%
    filter(!is.na(prep_fun_str)) %>%
    filter(game_name %in% get_game_names()) %>%
    mutate(prep_fun = rlang::syms(prep_fun_str)) %>%
    select(game_id, prep_fun, game_name_short),
  tar_target(
    indices,
    calc_indices(data, prep_fun, game_id)
  ),
  names = game_name_short
)
# add more jobs in the following plans
tar_pipeline(
  tar_file(file_game_info, "settings/game_info.csv"),
  tar_file(query_tmpl_data, "sql/data.tmpl.sql"),
  tar_file(query_tmpl_users, "sql/users.tmpl.sql"),
  tar_target(config_where, config::get("where")),
  tar_fst_tbl(data, fetch_from_v3(query_tmpl_data, config_where)),
  tar_fst_tbl(users, fetch_from_v3(query_tmpl_users, config_where)),
  tar_fst_tbl(
    game_info,
    read_csv(file_game_info, col_types = cols()) %>%
      semi_join(game_indices, by = "game_id") %>%
      select(-prep_fun_str)
  )
)
