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
  ),
  tar_target(
    indices,
    calc_indices(data, prep_fun)
  )
)
