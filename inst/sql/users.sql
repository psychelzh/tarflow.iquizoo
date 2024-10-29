SELECT DISTINCT
    project_course_user.OrganizationUserId user_id,
    organization_user.RealName user_name,
    organization_user.Gender user_sex,
    organization_user.Birthday user_dob,
    organization_user.IdCard user_id_card,
    organization_user.StudentNumber user_id_student,
    organization_user.Mobile user_phone,
    base_organization.Name organization_name,
    base_organization.Country organization_country,
    base_organization.Province organization_province,
    base_organization.City organization_city,
    base_organization.District organization_district,
    structure_grades.Name grade_name,
    structure_classes.StructureType class_type,
    GROUP_CONCAT(structure_classes.Name SEPARATOR '|') class_name
FROM
    iquizoo_business_db.project_course_config
    INNER JOIN iquizoo_business_db.project_course_user
    ON project_course_user.ProjectCourseConfigId = project_course_config.Id
        AND project_course_user.Deleted <> 1 AND project_course_config.Deleted <> 1
    INNER JOIN iquizoo_user_db.organization_user
    ON organization_user.Id = project_course_user.OrganizationUserId
        AND organization_user.Deleted <> 1
    INNER JOIN iquizoo_user_db.base_organization
    ON base_organization.Id = organization_user.OrganizationId
        AND base_organization.Deleted <> 1
    INNER JOIN iquizoo_user_db.organization_structure_user
    ON organization_structure_user.OrganizationUserId = project_course_user.OrganizationUserId
        AND organization_structure_user.Deleted <> 1
    INNER JOIN iquizoo_user_db.base_organization_structure structure_classes
    ON structure_classes.Id = organization_structure_user.StructureId
        AND structure_classes.Deleted <> 1
    INNER JOIN iquizoo_user_db.base_organization_structure structure_grades
    ON structure_grades.Id = structure_classes.SuperiorId
        AND structure_grades.Deleted <> 1
WHERE
    project_course_config.Id = ?
GROUP BY user_id, class_type;
