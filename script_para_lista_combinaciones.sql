-- Lista de combinaciones

-- Declarar variables
DECLARE @Combination INT = 0;
DECLARE @MaxCombinations INT = POWER(2, 6) - 1; -- 2^6 - 1 = 63 combinaciones posibles
DECLARE @Name NVARCHAR(255), @Description NVARCHAR(MAX);
DECLARE @CanCreate BIT, @CanRead BIT, @CanUpdate BIT, @CanDelete BIT, @CanImport BIT, @CanExport BIT;

-- Bucle para insertar combinaciones
WHILE @Combination <= @MaxCombinations
BEGIN
    -- Obtener valores individuales usando bits
    SET @CanCreate = (@Combination & 1);
    SET @CanRead   = (@Combination & 2) / 2;
    SET @CanUpdate = (@Combination & 4) / 4;
    SET @CanDelete = (@Combination & 8) / 8;
    SET @CanImport = (@Combination & 16) / 16;
    SET @CanExport = (@Combination & 32) / 32;

    -- Generar nombre y descripción
    SET @Name = CONCAT(
        CASE WHEN @CanCreate = 1 THEN 'Create-' ELSE '' END,
        CASE WHEN @CanRead = 1 THEN 'Read-' ELSE '' END,
        CASE WHEN @CanUpdate = 1 THEN 'Update-' ELSE '' END,
        CASE WHEN @CanDelete = 1 THEN 'Delete-' ELSE '' END,
        CASE WHEN @CanImport = 1 THEN 'Import-' ELSE '' END,
        CASE WHEN @CanExport = 1 THEN 'Export-' ELSE '' END
    );

    SET @Description = CONCAT(
        'Permission: ',
        CASE WHEN @CanCreate = 1 THEN 'Allows creating records. ' ELSE '' END,
        CASE WHEN @CanRead = 1 THEN 'Allows reading records. ' ELSE '' END,
        CASE WHEN @CanUpdate = 1 THEN 'Allows updating records. ' ELSE '' END,
        CASE WHEN @CanDelete = 1 THEN 'Allows deleting records. ' ELSE '' END,
        CASE WHEN @CanImport = 1 THEN 'Allows importing data. ' ELSE '' END,
        CASE WHEN @CanExport = 1 THEN 'Allows exporting data. ' ELSE '' END
    );

    -- Remover el último guión del nombre
    IF RIGHT(@Name, 1) = '-' SET @Name = LEFT(@Name, LEN(@Name) - 1);

    -- Insertar combinación en la tabla
    INSERT INTO Permission (name, description, can_create, can_read, can_update, can_delete, can_import, can_export)
    VALUES (@Name, @Description, @CanCreate, @CanRead, @CanUpdate, @CanDelete, @CanImport, @CanExport);

    -- Incrementar combinación
    SET @Combination = @Combination + 1;
END;

-- Mostrar todas las combinaciones insertadas
SELECT * FROM Permission;
GO
