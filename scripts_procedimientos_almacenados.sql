CREATE PROCEDURE GetUserPermissionsForEntity
    @EntityCatalogId INT,
    @UserId BIGINT
AS
BEGIN
    -- Temporary table to store resolved permissions
    CREATE TABLE #ResolvedPermissions (
        permission_id BIGINT,
        name NVARCHAR(255),
        can_create BIT,
        can_read BIT,
        can_update BIT,
        can_delete BIT,
        can_import BIT,
        can_export BIT,
        permission_level NVARCHAR(50),
        include_flag BIT
    );

    -- Find the user's companies
    DECLARE @UserCompanyIds TABLE (useco_id BIGINT);
    INSERT INTO @UserCompanyIds
    SELECT id_useco 
    FROM UserCompany 
    WHERE user_id = @UserId AND useco_active = 1;

    -- Step 1: Collect Role-level Permissions
    ;WITH RolePermissions AS (
        SELECT 
            pr.permission_id,
            p.name,
            p.can_create,
            p.can_read,
            p.can_update,
            p.can_delete,
            p.can_import,
            p.can_export,
            'Role' AS permission_level,
            pr.perol_include AS include_flag
        FROM PermiRole pr
        JOIN Permission p ON pr.permission_id = p.id_permi
        JOIN Role r ON pr.role_id = r.id_role
        JOIN UserCompany uc ON r.company_id = uc.company_id
        WHERE pr.entitycatalog_id = @EntityCatalogId
        AND uc.user_id = @UserId
    )

    -- Step 2: Collect User-level Permissions
    , UserPermissions AS (
        SELECT 
            pu.permission_id,
            p.name,
            p.can_create,
            p.can_read,
            p.can_update,
            p.can_delete,
            p.can_import,
            p.can_export,
            'User' AS permission_level,
            pu.peusr_include AS include_flag
        FROM PermiUser pu
        JOIN Permission p ON pu.permission_id = p.id_permi
        WHERE pu.entitycatalog_id = @EntityCatalogId
        AND pu.usercompany_id IN (SELECT useco_id FROM @UserCompanyIds)
    )

    -- Step 3: Collect Role-Record Permissions
    , RoleRecordPermissions AS (
        SELECT 
            prr.permission_id,
            p.name,
            p.can_create,
            p.can_read,
            p.can_update,
            p.can_delete,
            p.can_import,
            p.can_export,
            'RoleRecord' AS permission_level,
            prr.perrc_include AS include_flag,
            prr.perrc_record AS record_id
        FROM PermiRoleRecord prr
        JOIN Permission p ON prr.permission_id = p.id_permi
        JOIN Role r ON prr.role_id = r.id_role
        JOIN UserCompany uc ON r.company_id = uc.company_id
        WHERE prr.entitycatalog_id = @EntityCatalogId
        AND uc.user_id = @UserId
    )

    -- Step 4: Collect User-Record Permissions
    , UserRecordPermissions AS (
        SELECT 
            pur.permission_id,
            p.name,
            p.can_create,
            p.can_read,
            p.can_update,
            p.can_delete,
            p.can_import,
            p.can_export,
            'UserRecord' AS permission_level,
            pur.peusr_include AS include_flag,
            pur.peusr_record AS record_id
        FROM PermiUserRecord pur
        JOIN Permission p ON pur.permission_id = p.id_permi
        WHERE pur.entitycatalog_id = @EntityCatalogId
        AND pur.usercompany_id IN (SELECT useco_id FROM @UserCompanyIds)
    )

    -- Main Permission Resolution Logic
    -- Priority: UserRecord > RoleRecord > User > Role
    , CombinedPermissions AS (
        SELECT 
            permission_id,
            name,
            CASE WHEN SUM(CAST(can_create AS INT)) > 0 THEN 1 ELSE 0 END AS can_create,
            CASE WHEN SUM(CAST(can_read AS INT)) > 0 THEN 1 ELSE 0 END AS can_read,
            CASE WHEN SUM(CAST(can_update AS INT)) > 0 THEN 1 ELSE 0 END AS can_update,
            CASE WHEN SUM(CAST(can_delete AS INT)) > 0 THEN 1 ELSE 0 END AS can_delete,
            CASE WHEN SUM(CAST(can_import AS INT)) > 0 THEN 1 ELSE 0 END AS can_import,
            CASE WHEN SUM(CAST(can_export AS INT)) > 0 THEN 1 ELSE 0 END AS can_export,
            permission_level,
            MAX(CAST(include_flag AS INT)) AS include_flag
        FROM (
            -- Combine all permission sources
            SELECT 
                permission_id, 
                name, 
                can_create, 
                can_read, 
                can_update, 
                can_delete, 
                can_import, 
                can_export, 
                permission_level, 
                include_flag, 
                record_id 
            FROM UserRecordPermissions
            UNION ALL
            SELECT 
                permission_id, 
                name, 
                can_create, 
                can_read, 
                can_update, 
                can_delete, 
                can_import, 
                can_export, 
                permission_level, 
                include_flag, 
                record_id 
            FROM RoleRecordPermissions
            UNION ALL
            SELECT 
                permission_id, 
                name, 
                can_create, 
                can_read, 
                can_update, 
                can_delete, 
                can_import, 
                can_export, 
                permission_level, 
                include_flag, 
                NULL AS record_id 
            FROM UserPermissions
            UNION ALL
            SELECT 
                permission_id, 
                name, 
                can_create, 
                can_read, 
                can_update, 
                can_delete, 
                can_import, 
                can_export, 
                permission_level, 
                include_flag, 
                NULL AS record_id 
            FROM RolePermissions
        ) AllPermissions
        GROUP BY permission_id, name, permission_level
    )

    -- Final permission selection with precedence
    INSERT INTO #ResolvedPermissions
    SELECT 
        permission_id,
        name,
        can_create,
        can_read,
        can_update,
        can_delete,
        can_import,
        can_export,
        permission_level,
        include_flag
    FROM CombinedPermissions
    WHERE include_flag = 1;

    -- Return the resolved permissions
    SELECT * FROM #ResolvedPermissions;

    -- Clean up
    DROP TABLE #ResolvedPermissions;
END;

