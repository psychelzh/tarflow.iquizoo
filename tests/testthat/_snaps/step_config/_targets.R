library(targets)
library(tarchetypes)
tar_option_set()
list(
  tar_file(file_config, "config.yml"),
  tar_target(config_where, config::get("where", file = file_config))
)
