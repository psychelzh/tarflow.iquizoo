# load required packages used in pipeline setup
library(targets)
library(tarchetypes)
# set required packages used in pipeline running
tar_option_set(packages = "tidyverse")
# prepare configurations for games to be fetched
games <- tarflow.iquizoo::fetch("sql/games.tmpl.sql", config::get("where"))
# add more jobs in the following plans
list(
  tar_file(file_config, "config.yml"),
  tar_file(query_tmpl_scores, "sql/scores.tmpl.sql"),
  tar_file(query_tmpl_users, "sql/users.tmpl.sql"),
  tar_target(config_where, config::get("where", file = file_config)),
  targets_scores <- tar_map(
    values = games,
    names = NULL,
    tar_target(
      scores,
      tarflow.iquizoo::fetch(
        query_tmpl_scores,
        tarflow.iquizoo::insert_where(
          config_where,
          list(table = "content", field = "Id", values = game_id)
        )
      )
    )
  ),
  tar_combine(scores, targets_scores),
  tar_fst_tbl(users, tarflow.iquizoo::fetch(query_tmpl_users, config_where))
)
