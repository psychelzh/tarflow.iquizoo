targets_scores <- tar_map(
  values = games,
  names = game_name_abbr,
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
)
