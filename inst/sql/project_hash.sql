SELECT
    MD5(concat_ws(", ", pcc.Id, FinishedUserCount, ConfiguredUserCount, Progress, CompletionRate)) AS MD5
FROM
    iquizoo_business_db.project_course_config pcc
    INNER JOIN iquizoo_user_db.base_organization bo ON bo.Id = pcc.OrganizationId
WHERE
    bo.Name = ? AND pcc.Name = ?;
