use test_sql_server;
/*
Catálogo de Entidades.

Un catálogo de entidades representa una tabla que almacena todas las entidades 
(modelos) disponibles en el sistema Django, facilitando su gestión y referencia.

¿Para qué sirve?:

1. Mantener un registro centralizado de todas las entidades del sistema.

2. Facilitar la gestión y el mantenimiento de la estructura de la base de datos.

3. Permitir la referencia dinámica a diferentes modelos del sistema.

4. Proveer una base para la implementación de funcionalidades genéricas.

5. Apoyar en la documentación y organización del sistema.

Creado por:
@Claudio

Fecha: 27/9/2024
*/

-- Create EntityCatalog Table
CREATE TABLE EntityCatalog (
    -- Primary Key
    id_entit INT IDENTITY(1,1) PRIMARY KEY,                    -- Identificador único para el elemento del catálogo de entidades
    
    -- Entity Information
    entit_name NVARCHAR(255) NOT NULL UNIQUE,                  -- Nombre del modelo Django asociado
    entit_descrip NVARCHAR(255) NOT NULL,                      -- Descripción del elemento del catálogo de entidades
    
    -- Status
    entit_active BIT NOT NULL DEFAULT 1,                       -- Indica si el elemento del catálogo está activo (1) o inactivo (0)
    
    -- Configuration
    entit_config NVARCHAR(MAX) NULL                           -- Configuración adicional para el elemento del catálogo
);


/*
Compañía.

Una compañía representa una entidad empresarial con sus datos de identificación,
ubicación y características principales dentro del sistema ERP.

¿Para qué sirve?:

1. Gestión centralizada de la información básica de las empresas en el sistema.

2. Soporte para operaciones comerciales y administrativas específicas de cada empresa.

3. Cumplimiento de requisitos legales y fiscales relacionados con la identificación empresarial.

4. Base para la configuración de parámetros y políticas específicas de cada empresa.

5. Facilitar la gestión multi-empresa dentro del sistema ERP.

Creado por:
@Claudio

Fecha: 27/9/2024
*/

-- Create Company Table
CREATE TABLE Company (
    -- Primary Key
    id_compa BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para la compañía
    
    -- Company Information
    compa_name NVARCHAR(255) NOT NULL,                        -- Nombre legal completo de la compañía
    compa_tradename NVARCHAR(255) NOT NULL,                   -- Nombre comercial o marca de la compañía
    
    -- Document Information
    compa_doctype NVARCHAR(2) NOT NULL                        -- Tipo de documento de identificación de la compañía
        CONSTRAINT CK_Company_DocType 
        CHECK (compa_doctype IN ('NI', 'CC', 'CE', 'PP', 'OT')),
    compa_docnum NVARCHAR(255) NOT NULL,                      -- Número de identificación fiscal o documento legal de la compañía
    
    -- Location Information
    compa_address NVARCHAR(255) NOT NULL,                     -- Dirección física de la compañía
    compa_city NVARCHAR(255) NOT NULL,                        -- Ciudad donde está ubicada la compañía
    compa_state NVARCHAR(255) NOT NULL,                       -- Departamento o estado donde está ubicada la compañía
    compa_country NVARCHAR(255) NOT NULL,                     -- País donde está ubicada la compañía
    
    -- Contact Information
    compa_industry NVARCHAR(255) NOT NULL,                    -- Sector industrial al que pertenece la compañía
    compa_phone NVARCHAR(255) NOT NULL,                       -- Número de teléfono principal de la compañía
    compa_email NVARCHAR(255) NOT NULL,                       -- Dirección de correo electrónico principal de la compañía
    compa_website NVARCHAR(255) NULL,                         -- Sitio web oficial de la compañía
    
    -- Media
    compa_logo NVARCHAR(MAX) NULL,                           -- Logo oficial de la compañía
    
    -- Status
    compa_active BIT NOT NULL DEFAULT 1                       -- Indica si la compañía está activa (1) o inactiva (0)
);

/*
Sucursal.

Una sucursal representa un establecimiento físico o punto de operación 
que pertenece a una compañía específica.

¿Para qué sirve?:

1. Gestión y control de múltiples ubicaciones de una misma empresa.

2. Organización de operaciones por punto de venta o servicio.

3. Seguimiento y análisis de desempeño por sucursal.

4. Asignación y control de recursos específicos por ubicación.

5. Facilitar la gestión descentralizada de operaciones empresariales.

Creado por:
@Claude Assistant

Fecha: 27/10/2024
*/

-- Create BranchOffice Table
CREATE TABLE BranchOffice (
    -- Primary Key
    id_broff BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para la sucursal

    -- Company Reference
    company_id BIGINT NOT NULL                                -- Compañía a la que pertenece esta sucursal
        CONSTRAINT FK_BranchOffice_Company 
        FOREIGN KEY REFERENCES Company(id_compa),
    
    -- Branch Office Information
    broff_name NVARCHAR(255) NOT NULL,                        -- Nombre descriptivo de la sucursal
    broff_code NVARCHAR(255) NOT NULL,                        -- Código único que identifica la sucursal dentro de la empresa
    
    -- Location Information
    broff_address NVARCHAR(255) NOT NULL,                     -- Dirección física de la sucursal
    broff_city NVARCHAR(255) NOT NULL,                        -- Ciudad donde está ubicada la sucursal
    broff_state NVARCHAR(255) NOT NULL,                       -- Departamento o estado donde está ubicada la sucursal
    broff_country NVARCHAR(255) NOT NULL,                     -- País donde está ubicada la sucursal
    
    -- Contact Information
    broff_phone NVARCHAR(255) NOT NULL,                       -- Número de teléfono de la sucursal
    broff_email NVARCHAR(255) NOT NULL,                       -- Dirección de correo electrónico de la sucursal
    
    -- Status
    broff_active BIT NOT NULL DEFAULT 1,                      -- Indica si la sucursal está activa (1) o inactiva (0)

    -- Unique constraint for company and branch code combination
    CONSTRAINT UQ_Company_BranchCode UNIQUE (company_id, broff_code)
);

/*
Centro de Costo.

Un centro de costo representa una unidad organizacional dentro de una empresa
que permite agrupar y controlar costos específicos.

¿Para qué sirve?:

1. Gestión y control de costos por unidad organizativa.

2. Seguimiento detallado de gastos y presupuestos por área.

3. Análisis de rentabilidad por centro de responsabilidad.

4. Facilitación de la toma de decisiones basada en costos.

5. Implementación de estructuras jerárquicas para el control de costos.

Creado por:
@Claudio

Fecha: 27/10/2024
*/

-- Create CostCenter Table
CREATE TABLE CostCenter (
    -- Primary Key
    id_cosce BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para el centro de costo
    
    -- Foreign Keys
    company_id BIGINT NOT NULL                                -- Compañía a la que pertenece este centro de costo
        CONSTRAINT FK_CostCenter_Company 
        FOREIGN KEY REFERENCES Company(id_compa),
    
    cosce_parent_id BIGINT NULL                               -- Centro de costo superior en la jerarquía organizacional
        CONSTRAINT FK_CostCenter_Parent 
        FOREIGN KEY REFERENCES CostCenter(id_cosce),
    
    -- Basic Information
    cosce_code NVARCHAR(255) NOT NULL,                        -- Código único que identifica el centro de costo
    cosce_name NVARCHAR(255) NOT NULL,                        -- Nombre descriptivo del centro de costo
    cosce_description NVARCHAR(MAX) NULL,                     -- Descripción detallada del centro de costo y su propósito
    
    -- Financial Information
    cosce_budget DECIMAL(15,2) NOT NULL DEFAULT 0,            -- Presupuesto asignado al centro de costo
    
    -- Hierarchical Information
    cosce_level SMALLINT NOT NULL DEFAULT 1                   -- Nivel en la jerarquía de centros de costo (1 para nivel superior)
        CONSTRAINT CK_CostCenter_Level 
        CHECK (cosce_level > 0),
    
    -- Status
    cosce_active BIT NOT NULL DEFAULT 1,                      -- Indica si el centro de costo está activo (1) o inactivo (0)
    
    -- Unique constraint for company and cost center code combination
    CONSTRAINT UQ_Company_CostCenterCode UNIQUE (company_id, cosce_code)
);

/*
Usuario.

Un usuario representa una persona que interactúa con el sistema,
con sus credenciales y datos básicos de acceso.

¿Para qué sirve?:

1. Gestión de acceso y autenticación en el sistema.

2. Almacenamiento de información básica de los usuarios.

3. Control de estados y permisos de usuarios.

4. Seguimiento de actividad y auditoría de usuarios.

5. Base para la personalización de la experiencia de usuario.

Creado por:
@Claudio

Fecha: 27/10/2024
*/

-- Create User Table
CREATE TABLE [User] (
    -- Primary Key
    id_user BIGINT IDENTITY(1,1) PRIMARY KEY,                 -- Identificador único para el usuario
    
    -- Authentication Information
    user_username NVARCHAR(255) NOT NULL,                     -- Nombre de usuario para iniciar sesión
    user_password NVARCHAR(255) NOT NULL,                     -- Contraseña encriptada del usuario
    
    -- Contact Information
    user_email NVARCHAR(255) NOT NULL,                        -- Dirección de correo electrónico del usuario
    user_phone NVARCHAR(255) NULL,                            -- Número de teléfono del usuario
    
    -- Access Control
    user_is_admin BIT NOT NULL DEFAULT 0,                     -- Indica si el usuario es Administrador (1) o normal (0)
    user_is_active BIT NOT NULL DEFAULT 1,                    -- Indica si el usuario está activo (1) o inactivo (0)
    
    -- Unique Constraints
    CONSTRAINT UQ_User_Username UNIQUE (user_username),
    CONSTRAINT UQ_User_Email UNIQUE (user_email)
);

/*
Rol.

Un rol representa un conjunto de permisos y responsabilidades que pueden
ser asignados a usuarios dentro de una compañía específica.

¿Para qué sirve?:

1. Definición de niveles de acceso y permisos por compañía.

2. Agrupación de funcionalidades y accesos para asignación eficiente.

3. Control granular de las capacidades de los usuarios en el sistema.

4. Simplificación de la gestión de permisos por grupos de usuarios.

5. Estandarización de roles y responsabilidades dentro de cada compañía.

Creado por:
@Claudio

Fecha: 27/10/2024
*/

-- Create Role Table
CREATE TABLE Role (
    -- Primary Key
    id_role BIGINT IDENTITY(1,1) PRIMARY KEY,                 -- Identificador único para el rol
    
    -- Foreign Keys
    company_id BIGINT NOT NULL                                -- Compañía a la que pertenece este rol
        CONSTRAINT FK_Role_Company 
        FOREIGN KEY REFERENCES Company(id_compa),
    
    -- Basic Information
    role_name NVARCHAR(255) NOT NULL,                         -- Nombre descriptivo del rol
    role_code NVARCHAR(255) NOT NULL,                         -- Código del rol (agregado basado en unique_together)
    role_description NVARCHAR(MAX) NULL,                      -- Descripción detallada del rol y sus responsabilidades
    
    -- Status
    role_active BIT NOT NULL DEFAULT 1,                       -- Indica si el rol está activo (1) o inactivo (0)
    
    -- Unique constraint for company and role code combination
    CONSTRAINT UQ_Company_RoleCode UNIQUE (company_id, role_code)
);

/*
Usuario por Compañía.

Representa la relación entre un usuario y una compañía, permitiendo gestionar
el acceso de usuarios a múltiples compañías en el sistema.

¿Para qué sirve?:

1. Gestión de permisos de usuarios por compañía.

2. Control de acceso multiempresa para cada usuario.

3. Seguimiento de actividades de usuarios por compañía.

4. Configuración de preferencias específicas por usuario y compañía.

5. Soporte para roles y responsabilidades diferentes en cada compañía.

Creado por:
@Claudio 

Fecha: 27/10/2024
*/

-- Create UserCompany Table
CREATE TABLE UserCompany (
    -- Primary Key
    id_useco BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para la relación usuario-compañía
    
    -- Foreign Keys
    user_id BIGINT NOT NULL                                   -- Usuario asociado a la compañía
        CONSTRAINT FK_UserCompany_User 
        FOREIGN KEY REFERENCES [User](id_user),
    
    company_id BIGINT NOT NULL                                -- Compañía asociada al usuario
        CONSTRAINT FK_UserCompany_Company 
        FOREIGN KEY REFERENCES Company(id_compa),
    
    -- Status
    useco_active BIT NOT NULL DEFAULT 1,                      -- Indica si la relación usuario-compañía está activa (1) o inactiva (0)
    
    -- Unique constraint for user and company combination
    CONSTRAINT UQ_User_Company UNIQUE (user_id, company_id)
);

/*
Permiso.

Un permiso representa los diferentes niveles de acceso y operaciones
que pueden realizarse sobre una entidad del sistema.

¿Para qué sirve?:

1. Control granular de acciones sobre entidades del sistema.

2. Definición de permisos específicos para operaciones CRUD.

3. Gestión de capacidades de importación y exportación de datos.

4. Implementación de políticas de seguridad y acceso.

5. Configuración flexible de permisos por funcionalidad.

Creado por:
@Claudio

Fecha: 27/10/2024
*/

-- Create Permission Table
CREATE TABLE Permission (
    -- Primary Key
    id_permi BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para el permiso
    
    -- Basic Information
    name NVARCHAR(255) NOT NULL,                              -- Nombre descriptivo del permiso
    description NVARCHAR(MAX) NULL,                           -- Descripción detallada del permiso y su propósito
    
    -- CRUD Permissions
    can_create BIT NOT NULL DEFAULT 0,                        -- Permite crear nuevos registros
    can_read BIT NOT NULL DEFAULT 0,                          -- Permite ver registros existentes
    can_update BIT NOT NULL DEFAULT 0,                        -- Permite modificar registros existentes
    can_delete BIT NOT NULL DEFAULT 0,                        -- Permite eliminar registros existentes
    
    -- Data Transfer Permissions
    can_import BIT NOT NULL DEFAULT 0,                        -- Permite importar datos masivamente
    can_export BIT NOT NULL DEFAULT 0                         -- Permite exportar datos del sistema
);

/*
Permiso de Usuario.

Representa los permisos específicos asignados a un usuario para una 
entidad particular dentro de una compañía.

¿Para qué sirve?:

1. Asignación de permisos específicos por usuario y entidad.

2. Control granular de accesos a nivel de usuario-compañía.

3. Personalización de capacidades por entidad del sistema.

4. Gestión detallada de privilegios por usuario.

5. Implementación de políticas de seguridad específicas por entidad.

Creado por:
@Claudio

Fecha: 27/10/2024
*/

-- Create PermiUser Table
CREATE TABLE PermiUser (
    -- Primary Key
    id_peusr BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para el permiso de usuario
    
    -- Foreign Keys
    usercompany_id BIGINT NOT NULL                            -- Relación usuario-compañía a la que se asigna el permiso
        CONSTRAINT FK_PermiUser_UserCompany 
        FOREIGN KEY REFERENCES UserCompany(id_useco),
        
    permission_id BIGINT NOT NULL                             -- Permiso asignado al usuario
        CONSTRAINT FK_PermiUser_Permission 
        FOREIGN KEY REFERENCES Permission(id_permi),
        
    entitycatalog_id INT NOT NULL                          -- Entidad sobre la que se aplica el permiso
        CONSTRAINT FK_PermiUser_EntityCatalog
        FOREIGN KEY REFERENCES EntityCatalog(id_entit),
    
    -- Permission Configuration
    peusr_include BIT NOT NULL DEFAULT 1,                     -- Indica si el permiso se incluye (1) o se excluye (0) para el usuario
    
    -- Unique constraint for user-company, permission and entity catalog combination
    CONSTRAINT UQ_UserCompany_Permission_Entity 
        UNIQUE (usercompany_id, permission_id, entitycatalog_id)
);

/*
Permiso de Usuario con Registro.

Representa los permisos específicos asignados a un usuario para una 
entidad particular y un registro específico dentro de una compañía.

¿Para qué sirve?:

1. Asignación de permisos específicos por usuario y entidad a nivel de registro.

2. Control granular de accesos a nivel de usuario-compañía y registro.

3. Personalización de capacidades por entidad y registro del sistema.

4. Gestión detallada de privilegios por usuario a nivel de registro.

5. Implementación de políticas de seguridad específicas por entidad y registro.

Creado por:
@Claudio

Fecha: 27/10/2024
*/

-- Create PermiUserRecord Table
CREATE TABLE PermiUserRecord (
    -- Primary Key
    id_peusr BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para el permiso de usuario
    
    -- Foreign Keys
    usercompany_id BIGINT NOT NULL                            -- Relación usuario-compañía a la que se asigna el permiso
        CONSTRAINT FK_PermiUserRecord_UserCompany 
        FOREIGN KEY REFERENCES UserCompany(id_useco),
        
    permission_id BIGINT NOT NULL                             -- Permiso asignado al usuario
        CONSTRAINT FK_PermiUserRecord_Permission 
        FOREIGN KEY REFERENCES Permission(id_permi),
        
    entitycatalog_id INT NOT NULL                          -- Entidad sobre la que se aplica el permiso
        CONSTRAINT FK_PermiUserRecord_EntityCatalog 
        FOREIGN KEY REFERENCES EntityCatalog(id_entit),
    
    -- Record Specific Information
    peusr_record BIGINT NOT NULL,                             -- Identificador del registro específico de la entidad al que aplica el permiso
    
    -- Permission Configuration
    peusr_include BIT NOT NULL DEFAULT 1,                     -- Indica si el permiso se incluye (1) o se excluye (0) para el usuario
    
    -- Unique constraint for user-company, permission, entity catalog and record combination
    CONSTRAINT UQ_UserCompany_Permission_Entity_Record 
        UNIQUE (usercompany_id, permission_id, entitycatalog_id, peusr_record)
);

/*
Permiso por Rol.

Representa los permisos específicos asignados a un rol para una 
entidad particular dentro del sistema.

¿Para qué sirve?:

1. Asignación de permisos específicos por rol y entidad.

2. Control granular de accesos a nivel de rol.

3. Personalización de capacidades por entidad del sistema.

4. Gestión detallada de privilegios por rol.

5. Implementación de políticas de seguridad específicas por rol y entidad.

Creado por:
@Claudio

Fecha: 27/10/2024
*/

-- Create PermiRole Table
CREATE TABLE PermiRole (
    -- Primary Key
    id_perol BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para el permiso de rol
    
    -- Foreign Keys
    role_id BIGINT NOT NULL                                   -- Rol al que se asigna el permiso
        CONSTRAINT FK_PermiRole_Role 
        FOREIGN KEY REFERENCES Role(id_role),
        
    permission_id BIGINT NOT NULL                             -- Permiso asignado al rol
        CONSTRAINT FK_PermiRole_Permission 
        FOREIGN KEY REFERENCES Permission(id_permi),
        
    entitycatalog_id INT NOT NULL                          -- Entidad sobre la que se aplica el permiso
        CONSTRAINT FK_PermiRole_EntityCatalog 
        FOREIGN KEY REFERENCES EntityCatalog(id_entit),
    
    -- Permission Configuration
    perol_include BIT NOT NULL DEFAULT 1,                     -- Indica si el permiso se incluye (1) o se excluye (0) para el rol
    perol_record BIGINT NULL,                                 -- Campo mencionado en unique_together pero no en el modelo
    
    -- Unique constraint for role, permission, entity catalog, and record combination
    CONSTRAINT UQ_Role_Permission_Entity_Record 
        UNIQUE (role_id, permission_id, entitycatalog_id, perol_record)
);

/*
Permiso por Rol y Registro.

Representa los permisos específicos asignados a un rol para una 
entidad y registro particular dentro del sistema.

¿Para qué sirve?:

1. Asignación de permisos específicos por rol, entidad y registro.

2. Control granular de accesos a nivel de rol y registro.

3. Personalización de capacidades por entidad y registro del sistema.

4. Gestión detallada de privilegios por rol y registro específico.

5. Implementación de políticas de seguridad específicas por rol, entidad y registro.

Creado por:
@Claudio

Fecha: 27/10/2024
*/

-- Create PermiRoleRecord Table
CREATE TABLE PermiRoleRecord (
    -- Primary Key
    id_perrc BIGINT IDENTITY(1,1) PRIMARY KEY,                -- Identificador único para el permiso de rol por registro
    
    -- Foreign Keys
    role_id BIGINT NOT NULL                                   -- Rol al que se asigna el permiso
        CONSTRAINT FK_PermiRoleRecord_Role 
        FOREIGN KEY REFERENCES Role(id_role),
        
    permission_id BIGINT NOT NULL                             -- Permiso asignado al rol
        CONSTRAINT FK_PermiRoleRecord_Permission 
        FOREIGN KEY REFERENCES Permission(id_permi),
        
    entitycatalog_id INT NOT NULL                          -- Entidad sobre la que se aplica el permiso
        CONSTRAINT FK_PermiRoleRecord_EntityCatalog 
        FOREIGN KEY REFERENCES EntityCatalog(id_entit),
    
    -- Record Specific Information
    perrc_record BIGINT NOT NULL,                             -- Identificador del registro específico al que se aplica el permiso
    
    -- Permission Configuration
    perrc_include BIT NOT NULL DEFAULT 1,                     -- Indica si el permiso se incluye (1) o se excluye (0) para el rol y registro
    
    -- Unique constraint for role, permission, entity catalog and record combination
    CONSTRAINT UQ_Role_Permission_Entity_Record_Comb 
        UNIQUE (role_id, permission_id, entitycatalog_id, perrc_record)
);
