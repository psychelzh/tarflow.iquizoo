## code to prepare `course_periods` and `game_types` dataset goes here

course_periods <- tibble::tribble(
  ~course_period_code, ~course_period_name,
  0, "未指定",
  1, "学前",
  2, "小学低段",
  3, "小学中段",
  4, "小学高段",
  5, "小学",
  6, "初中",
  7, "高中",
)
game_types <- tibble::tribble(
  ~game_type_code, ~game_type_name,
  1, "测评游戏",
  2, "训练游戏",
  3, "题目壳",
  4, "课程视频"
)

usethis::use_data(
  course_periods, game_types,
  overwrite = TRUE, internal = TRUE
)
