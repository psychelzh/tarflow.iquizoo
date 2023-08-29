SELECT
    ProjectCourseConfigId project_id,
    OrganizationUserId user_id,
    ContentId game_id,
    ContentVersion game_version,
    CreateTime game_time,
    ContentAbilityId ability_id,
    Stage game_stage,
    Star game_star,
    ApproximateScore game_score_raw,
    StandardScore game_score_std
FROM
    iquizoo_business_db.{ tbl_data }
WHERE
    ProjectCourseConfigId = ? AND ContentId = ?
