targets_scores <- tar_map(
  values = games,
  names = game_name_abbr,
  tar_target(
    scores,
    tarflow.iquizoo::fetch_single_game(
      query_tmpl_scores, config_where, game_id
    )
  )
)
