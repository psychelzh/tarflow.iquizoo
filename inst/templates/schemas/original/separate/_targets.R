# load required packages used in pipeline setup
options(tidyverse.quiet = TRUE)
library(targets)
library(tarchetypes)
library(tidyverse)
# set required packages used in pipeline running
tar_option_set(packages = "tidyverse")
# prepare configurations for games to be fetched
games <- tarflow.iquizoo::fetch("sql/games.tmpl.sql", config::get("where")) %>%
  left_join(tarflow.iquizoo::game_info, by = "game_id") %>%
  mutate(prep_fun = syms(prep_fun_name))
# add more jobs in the following plans
list(
  tar_file(file_config, "config.yml"),
  tar_file(query_tmpl_data, "sql/data.tmpl.sql"),
  tar_file(query_tmpl_users, "sql/users.tmpl.sql"),
  tar_target(config_where, config::get("where", file = file_config)),
  tar_fst_tbl(users, tarflow.iquizoo::fetch(query_tmpl_users, config_where)),
  targets_data <- tar_map(
    values = games,
    names = game_name_abbr,
    tar_target(
      data,
      tarflow.iquizoo::fetch(
        query_tmpl_data,
        tarflow.iquizoo::insert_where(
          config_where,
          list(table = "content", field = "Id", values = game_id)
        )
      )
    )
  ),
  tar_combine(data, targets_data)
)
