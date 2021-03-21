# load required packages used in pipeline setup
options(tidyverse.quiet = TRUE)
library(targets)
library(tarchetypes)
library(tidyverse)
# set required packages used in pipeline running
tar_option_set(packages = c("tidyverse", "dataproc.iquizoo"))
# track changes in the following packages
tar_option_set(imports = "dataproc.iquizoo")
# add more jobs in the following plans
list(
  tar_file(file_config, "config.yml"),
  tar_file(query_tmpl_data, "sql/data.tmpl.sql"),
  tar_file(query_tmpl_users, "sql/users.tmpl.sql"),
  tar_target(config_where, config::get("where", file = file_config)),
  tar_fst_tbl(data, tarflow.iquizoo::fetch(query_tmpl_data, config_where)),
  tar_fst_tbl(users, tarflow.iquizoo::fetch(query_tmpl_users, config_where)),
  targets_indices <- tar_map(
    values = tarflow.iquizoo::game_info %>%
      group_by(prep_fun_name) %>%
      summarise(game_ids = list(game_id), .groups = "drop") %>%
      mutate(prep_fun = syms(prep_fun_name)),
    names = prep_fun_name,
    tar_target(data_prep, data %>% filter(game_id %in% game_ids)),
    tar_target(indices, tarflow.iquizoo::calc_indices(data_prep, prep_fun))
  ),
  tar_combine(game_indices, targets_indices[[2]], format = "fst_tbl")
)
