future::plan(future::multisession)
search_games_mem <- memoise::memoise(
  tarflow.iquizoo::search_games,
  cache = cachem::cache_disk("{path}")
)
games <- search_games_mem(config::get("where"))
