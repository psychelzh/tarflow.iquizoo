SELECT
    pcc.Id project_id,
    c.Id course_id,
    c.Name course_name,
    CASE
        c.Period
        WHEN 1 THEN '学前'
        WHEN 2 THEN '小学低段'
        WHEN 3 THEN '小学中段'
        WHEN 4 THEN '小学高段'
        WHEN 5 THEN '小学'
        WHEN 6 THEN '初中'
        WHEN 7 THEN '高中'
        ELSE '未指定'
    END course_period,
    c.CreateTime course_date,
    c2.Id game_id,
    CASE
        c2.ContentType
        WHEN 1 THEN '测评游戏'
        WHEN 2 THEN '训练游戏'
        WHEN 3 THEN '题目壳'
        WHEN 4 THEN '课程视频'
    END game_type
FROM
    iquizoo_content_db.course c
    INNER JOIN iquizoo_business_db.project_course_config pcc ON pcc.CourseId = c.Id
    INNER JOIN iquizoo_content_db.course_child cc ON cc.CourseId = c.Id
    INNER JOIN iquizoo_content_db.course_child_config ccc ON ccc.ChildCourseId = cc.Id
    INNER JOIN iquizoo_content_db.content c2 ON c2.Id = ccc.ContentId
WHERE c.Name = ? AND c.Period = ? AND c2.ContentType <> 4;
