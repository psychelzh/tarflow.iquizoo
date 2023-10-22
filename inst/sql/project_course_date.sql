SELECT
    c.CreateTime course_date
FROM
    iquizoo_business_db.project_course_config pcc
    INNER JOIN iquizoo_content_db.course c ON c.Id = pcc.CourseId
WHERE
    pcc.Id = ?;
