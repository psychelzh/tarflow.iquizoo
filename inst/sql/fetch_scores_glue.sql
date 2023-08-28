SELECT
    ProjectCourseConfigId project_id,
    OrganizationUserId user_id,
    ContentId game_id,
    ContentAbilityId ability_id,
    ContentVersion game_version,
    CreateTime game_time,
    ApproximateScore game_score_raw,
    StandardScore game_score_std
FROM
    iquizoo_business_db.{ tbl_data }
WHERE
    ProjectCourseConfigId = ? AND ContentId = ?
