-- start from 2024-07-20, columns related to organization structure will not be supported
SELECT DISTINCT
    project_course_user.OrganizationUserId user_id
    { columns }
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
WHERE
    project_course_config.Id = ?;
