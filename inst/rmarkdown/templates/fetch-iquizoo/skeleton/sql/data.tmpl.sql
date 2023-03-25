SELECT DISTINCT
	v_organizationuser.OrganizationUserId user_id,
	course.`Name` course_name,
	content.Id game_id,
	content.`Name` game_name,
	content_orginal_data_detail.ContentVersion game_version,
	content_orginal_data_detail.CreateTime game_time,
	content_orginal_data_detail.TimeConsuming game_duration,
	content_orginal_data_detail.OrginalData game_data
FROM
	iquizoo_content_db.content_orginal_data_detail
	INNER JOIN iquizoo_content_db.v_organizationuser ON v_organizationuser.OrganizationUserId = content_orginal_data_detail.OrganizationUserId
	INNER JOIN iquizoo_user_db.base_organization ON base_organization.Id = v_organizationuser.OrganizationId -- `base_organization` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.content ON content.Id = content_orginal_data_detail.ContentId -- `content` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.project_course_config ON project_course_config.Id = content_orginal_data_detail.ProjectCourseConfigId
	INNER JOIN iquizoo_content_db.course ON course.Id = project_course_config.CourseId -- `course` might be used in "where_clause"
{ where_clause };
