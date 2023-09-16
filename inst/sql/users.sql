SELECT DISTINCT
    vo.OrganizationUserId user_id,
    vo.RealName user_name,
    vo.Gender user_sex,
    vo.Birthday user_dob,
    vo.OrganizationName organization_name,
    vo.GradeName grade_name,
    vo.ClassName class_name
FROM
    iquizoo_business_db.project_course_config pcc
    INNER JOIN iquizoo_business_db.project_course_user pcu ON pcu.ProjectCourseConfigId = pcc.Id AND pcu.Deleted <>1 AND pcc.Deleted <> 1
    INNER JOIN iquizoo_business_db.v_organizationuser vo ON vo.OrganizationUserId = pcu.OrganizationUserId
WHERE
    vo.OrganizationName = ? AND pcc.Name = ?
