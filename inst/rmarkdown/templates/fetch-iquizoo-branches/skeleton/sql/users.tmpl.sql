SELECT DISTINCT
	v_organizationuser.OrganizationUserId user_id,
	v_organizationuser.RealName user_name,
	v_organizationuser.Gender user_sex,
	v_organizationuser.Birthday user_dob,
	base_organization.`Name` school,
	base_organization.Province province,
	base_organization.City city,
	base_organization.District district,
	v_organizationuser.GradeName grade,
	v_organizationuser.ClassName class
FROM
	iquizoo_content_db.v_organizationuser
	INNER JOIN iquizoo_user_db.base_organization ON base_organization.Id = v_organizationuser.OrganizationId  -- `base_organization` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.project_course_user ON project_course_user.OrganizationUserId = v_organizationuser.OrganizationUserId
	INNER JOIN iquizoo_content_db.course ON course.Id = project_course_user.CourseId -- `course` might be used in "where_clause"
	INNER JOIN iquizoo_content_db.course_child ON course_child.CourseId = course.Id
	INNER JOIN iquizoo_content_db.course_child_config ON course_child_config.ChildCourseId = course_child.Id
	INNER JOIN iquizoo_content_db.content ON content.Id = course_child_config.ContentId -- `content` might be used in "where_clause"
{ where_clause };
