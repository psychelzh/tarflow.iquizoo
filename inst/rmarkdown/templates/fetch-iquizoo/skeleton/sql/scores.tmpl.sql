SELECT DISTINCT
	v_organizationuser.OrganizationUserId user_id,
	project_course_config.`Name` project_name,
	course.`Name` course_name,
	content.Id game_id,
	content.`Name` game_name,
	content.`VersionName` game_name_ver,
	content_score_detail.ContentAbilityId ability_id,
	content_score_detail.CreateTime game_time,
	content_score_detail.ApproximateScore game_score_raw,
	content_score_detail.StandardScore game_score_std
FROM
	iquizoo_content_db.content_score_detail
	INNER JOIN iquizoo_content_db.v_organizationuser ON v_organizationuser.OrganizationUserId = content_score_detail.OrganizationUserId
	INNER JOIN iquizoo_user_db.base_organization ON base_organization.Id = v_organizationuser.OrganizationId -- `base_organization` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.content ON content.Id = content_score_detail.ContentId -- `content` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.project_course_config ON project_course_config.Id = content_score_detail.ProjectCourseConfigId
	INNER JOIN iquizoo_content_db.course ON course.Id = project_course_config.CourseId -- `course` might be used in "where_clause"
{ where_clause };
