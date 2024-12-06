-- 1. Insert into EntityCatalog
INSERT INTO EntityCatalog (entit_name, entit_descrip, entit_active)
VALUES 
('Company', 'Entidad de Compañía', 1),
('User', 'Entidad de Usuario', 1),
('Role', 'Entidad de Rol', 1);

-- 2. Insert Companies
INSERT INTO Company (
    compa_name, compa_tradename, compa_doctype, compa_docnum, 
    compa_address, compa_city, compa_state, compa_country, 
    compa_industry, compa_phone, compa_email
)
VALUES 
('Empresa Principal SA', 'EmpresaPrincipal', 'NI', '1234567890', 
 'Calle Principal 123', 'Ciudad Principal', 'Estado Principal', 'País Principal', 
 'Tecnología', '+57 123 4567', 'contacto@empresaprincipal.com');

-- 3. Insert Users
INSERT INTO [User] (user_username, user_password, user_email, user_phone, user_is_admin)
VALUES 
('jperez', 'hashed_password_1', 'jperez@ejemplo.com', '+57 987 6543', 0),
('agarcia', 'hashed_password_2', 'agarcia@ejemplo.com', '+57 321 6549', 1);

-- 4. Insert UserCompany (linking users to companies)
INSERT INTO UserCompany (user_id, company_id)
SELECT u.id_user, c.id_compa
FROM [User] u, Company c;

-- 5. Insert Roles
INSERT INTO Role (company_id, role_name, role_code, role_description)
VALUES 
(1, 'Administrador', 'ADMIN', 'Rol con acceso total al sistema'),
(1, 'Usuario Estándar', 'USER', 'Rol con acceso limitado');

-- 6. Insert Permissions for different scenarios
-- We'll use the pre-generated permission combinations from the original script

-- 7. Insert Role Permissions
INSERT INTO PermiRole (role_id, permission_id, entitycatalog_id, perol_include)
SELECT 
    r.id_role, 
    p.id_permi, 
    ec.id_entit,
    1
FROM 
    Role r, 
    Permission p, 
    EntityCatalog ec
WHERE 
    r.role_name = 'Administrador' 
    AND p.name LIKE '%Create%Read%Update%Delete%'
    AND ec.entit_name = 'Company';

-- 8. Insert User Permissions
INSERT INTO PermiUser (usercompany_id, permission_id, entitycatalog_id, peusr_include)
SELECT 
    uc.id_useco, 
    p.id_permi, 
    ec.id_entit,
    1
FROM 
    UserCompany uc, 
    Permission p, 
    EntityCatalog ec
WHERE 
    uc.user_id = (SELECT id_user FROM [User] WHERE user_username = 'jperez')
    AND p.name LIKE '%Read%'
    AND ec.entit_name = 'User';

-- 9. Example of Role Record Permission
INSERT INTO PermiRoleRecord (
    role_id, 
    permission_id, 
    entitycatalog_id, 
    perrc_record, 
    perrc_include
)
SELECT 
    r.id_role, 
    p.id_permi, 
    ec.id_entit,
    1,  -- Example record ID
    1
FROM 
    Role r, 
    Permission p, 
    EntityCatalog ec
WHERE 
    r.role_name = 'Administrador'
    AND p.name LIKE '%Read%Update%'
    AND ec.entit_name = 'Company';

-- 10. Example of User Record Permission
INSERT INTO PermiUserRecord (
    usercompany_id, 
    permission_id, 
    entitycatalog_id, 
    peusr_record, 
    peusr_include
)
SELECT 
    uc.id_useco, 
    p.id_permi, 
    ec.id_entit,
    1,  -- Example record ID
    1
FROM 
    UserCompany uc, 
    Permission p, 
    EntityCatalog ec
WHERE 
    uc.user_id = (SELECT id_user FROM [User] WHERE user_username = 'jperez')
    AND p.name LIKE '%Read%'
    AND ec.entit_name = 'User';

-- Execute the stored procedure to test permissions for a user
EXEC GetUserPermissionsForEntity @EntityCatalogId = 1, @UserId = 1;