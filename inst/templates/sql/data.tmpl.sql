-- !preview conn=DBI::dbConnect(odbc::odbc(), "iquizoo-v3", database = "iquizoo_datacenter_db")

SELECT DISTINCT
	user_organization.Id user_org_id,
	user_organization.UserId user_id,
	course.`Name` course_name,
	content.Id game_id,
	content.`Name` game_name,
	content_orginal_data_detail.CreateTime game_time,
	content_orginal_data_detail.TimeConsuming game_duration,
	content_orginal_data_detail.OrginalData game_data
FROM
	iquizoo_datacenter_db.content_orginal_data_detail
	INNER JOIN iquizoo_user_db.user_organization ON user_organization.Id = content_orginal_data_detail.UserId
	INNER JOIN iquizoo_user_db.base_organization ON base_organization.Id = user_organization.OrganizationId -- `base_organization` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.content ON content.Id = content_orginal_data_detail.ContentId -- `content` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.course ON course.Id = content_orginal_data_detail.CourseId -- `course` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.projects ON projects.Id = content_orginal_data_detail.ProjectId -- `projects` might be used in "where_clause"
{ where_clause };
