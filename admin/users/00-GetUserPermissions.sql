-- -- EXECUTE AS USER = 'dev';

-- DROP TABLE IF EXISTS ##PermissionsSet
-- GO

-- SELECT * 
-- INTO ##PermissionsSet
-- FROM fn_my_permissions(NULL, 'DATABASE');
-- GO


-- SELECT * FROM ##PermissionsSet;
-- GO


USE master;
GO

-- Users
SELECT name as username, create_date, 
       modify_date, type_desc as type
FROM sys.database_principals
WHERE type not in ('A', 'G', 'R', 'X')
      and sid is not null
      and name != 'guest'

-- Logins
SELECT name AS [Login Name], type_desc AS [Account Type]
FROM sys.server_principals 
WHERE TYPE IN ('U', 'S', 'G')
and name not like '%##%'
ORDER BY name, type_desc

-- User Roles
SELECT [name], [create_date], [modify_date] 
FROM sys.database_principals
WHERE type = 'R'
ORDER BY [name]

-- -- User Defined Functions
-- SELECT name AS [Function Name],
--        SCHEMA_NAME(schema_id) AS schema_name,
--        type_desc
-- FROM sys.objects
-- WHERE type_desc LIKE '%FUNCTION%';
-- GO

-- -- User Defined Views
-- SELECT name AS [View Name],
--        SCHEMA_NAME(schema_id) AS schema_name,
--        type_desc
-- FROM sys.objects
-- WHERE type = 'V';
-- GO

-- -- User Defined Types
-- SELECT * FROM sys.types
-- WHERE is_user_defined = 1
-- GO

-- -- User Defined Tables
-- SELECT name AS [Table Name],
--        SCHEMA_NAME(schema_id) AS schema_name,
--        type_desc
-- FROM sys.objects
-- WHERE type = 'U';
-- GO

-- SELECT name AS [Table Name],
--        SCHEMA_NAME(schema_id) AS schema_name,
--        type_desc
-- FROM sys.tables
-- GO

-- -- User Defined Stored Procedures
-- SELECT name AS [Procedure Name],
--        SCHEMA_NAME(schema_id) AS schema_name,
--        type_desc
-- FROM sys.objects
-- WHERE type = 'P'
-- GO

-- SELECT name AS [Procedure Name],
--        SCHEMA_NAME(schema_id) AS schema_name,
--        type_desc
-- FROM sys.procedures
-- GO

-- -- User Permissions
-- SELECT * FROM sys.fn_builtin_permissions(DEFAULT); 

-- -- Active Connections
-- SELECT DB_NAME(dbid) AS [DB Name],
--        COUNT(dbid) AS [Number Of Connections],
--        loginame AS [Login Name]
-- FROM sys.sysprocesses
-- GROUP BY dbid, loginame
-- ORDER BY DB_NAME(dbid)

-- -- Orphaned Users
-- -- USE myDB
-- -- GO

-- EXEC sp_change_users_login report
-- GO



-- Get Something Else Instead
SELECT [UserName] = ulogin.[name],
       [UserType]             = CASE princ.[type]
                         WHEN 'S' THEN 'SQL User'
                         WHEN 'U' THEN 'Windows User'
                         WHEN 'G' THEN 'Windows Group'
                    END,
       [DatabaseUserName]     = princ.[name],
       [Role]                 = NULL,
       [PermissionState]      = perm.[state_desc],
       [PermissionType]       = perm.[permission_name],
       [ObjectType]           = CASE perm.[class]
                           WHEN 1 THEN obj.type_desc -- Schema-contained objects
                           ELSE perm.[class_desc] -- Higher-level objects
                      END,
       [ObjectName]           = CASE perm.[class]
                           WHEN 1 THEN OBJECT_NAME(perm.major_id) -- General objects
                           WHEN 3 THEN schem.[name] -- Schemas
                           WHEN 4 THEN imp.[name] -- Impersonations
                      END,
       [ColumnName]           = col.[name]
FROM   --database user
       sys.database_principals princ
       LEFT JOIN --Login accounts
            sys.server_principals ulogin
            ON  princ.[sid] = ulogin.[sid]
       LEFT JOIN --Permissions
            sys.database_permissions perm
            ON  perm.[grantee_principal_id] = princ.[principal_id]
       LEFT JOIN --Table columns
            sys.columns col
            ON  col.[object_id] = perm.major_id
            AND col.[column_id] = perm.[minor_id]
       LEFT JOIN sys.objects obj
            ON  perm.[major_id] = obj.[object_id]
       LEFT JOIN sys.schemas schem
            ON  schem.[schema_id] = perm.[major_id]
       LEFT JOIN sys.database_principals imp
            ON  imp.[principal_id] = perm.[major_id]
WHERE  princ.[type] IN ('S', 'U', 'G')
       AND -- No need for these system accounts
           princ.[name] NOT IN ('sys', 'INFORMATION_SCHEMA')
ORDER BY
       ulogin.[name],
       [UserType],
       [DatabaseUserName],
       [Role],
       [PermissionState],
       [PermissionType],
       [ObjectType],
       [ObjectName],
       [ColumnName] 