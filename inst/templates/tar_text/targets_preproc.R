targets_data <- tar_map(
  values = games,
  names = game_name_abbr,
  tar_target(
    data,
    tarflow.iquizoo::fetch_single_game(
      query_tmpl_data, config_where, game_id
    )
  ),
  tar_target(
    data_parsed,
    tarflow.iquizoo::wrangle_data(data)
  ),
  tar_target(
    indices,
    dataproc.iquizoo::preproc_data(
      data_parsed, prep_fun,
      by = attr(data_parsed, "name_key")
    )
  )
)
