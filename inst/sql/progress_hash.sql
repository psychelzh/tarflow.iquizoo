SELECT
    MD5(concat_ws(", ", pcc.Id, FinishedUserCount, ConfiguredUserCount, Progress, CompletionRate)) AS MD5
FROM
    iquizoo_business_db.project_course_config pcc
WHERE
    pcc.Id = ?;
