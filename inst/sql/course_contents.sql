SELECT
    pcc.Id project_id,
    c.Id course_id,
    c.Name course_name,
    c.Period course_period_code,
    c.CreateTime course_date,
    c2.Id game_id,
    c2.ContentType game_type_code
FROM
    iquizoo_content_db.course c
    INNER JOIN iquizoo_business_db.project_course_config pcc ON pcc.CourseId = c.Id
    INNER JOIN iquizoo_content_db.course_child cc ON cc.CourseId = c.Id
    INNER JOIN iquizoo_content_db.course_child_config ccc ON ccc.ChildCourseId = cc.Id
    INNER JOIN iquizoo_content_db.content c2 ON c2.Id = ccc.ContentId
WHERE c.Name = ? AND c.Period = ? AND c2.ContentType <> 4;
