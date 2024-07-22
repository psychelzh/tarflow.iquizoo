SELECT
    MD5(concat_ws(", ", Id, FinishedUserCount, ConfiguredUserCount, Progress, CompletionRate)) AS MD5
FROM
    iquizoo_business_db.project_course_config
WHERE
    Id = ?;
