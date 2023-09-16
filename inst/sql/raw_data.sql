SELECT
    ProjectCourseConfigId project_id,
    OrganizationUserId user_id,
    ContentId game_id,
    ContentVersion game_version,
    CreateTime game_time,
    TimeConsuming game_duration,
    OrginalData game_data
FROM
    iquizoo_business_db.{ table_name }
WHERE
    ProjectCourseConfigId = ? AND ContentId = ?
