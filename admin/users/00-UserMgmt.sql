DECLARE @Execute BIT = 1;

/* create options */
DECLARE @Create BIT = 1;
DECLARE @CreateSqlLogin BIT = 1;
DECLARE @CreateDbLogin BIT = 1;

/* delete options */
DECLARE @Purge BIT = 0;

DECLARE @UserName NVARCHAR(32);
DECLARE @Password NVARCHAR(32);
DECLARE @ActiveDb NVARCHAR(32);
DECLARE @Schema NVARCHAR(32);
DECLARE @SQL NVARCHAR(MAX);

/* user variables */
SET @UserName = 'gbadmin';
SET @Password = 'StructurallySoundSimian20!';
SET @ActiveDb = 'GitBucket';
-- SET @Schema = 'dbo';


IF (@Create = 1)
BEGIN
    IF (@CreateSqlLogin = 1)
    BEGIN
        BEGIN
            -- SET @SQL = ('CREATE LOGIN ' + @UserName + ' WITH PASSWORD = ''' + @Password + ''', DEFAULT_DATABASE = ' + @ActiveDb + ', CHECK_POLICY=OFF;')
            -- SET @SQL = ('CREATE USER ' + @UserName + ' FOR LOGIN ' + @UserName + ' WITH PASSWORD=''' + @Password + ''' WITH DEFAULT_SCHEMA=[' + @Schema + '], CHECK_POLICY=OFF;')
            -- SET @SQL = ('CREATE LOGIN ' + @UserName + ' WITH PASSWORD=''' + @Password + ''', DEFAULT_SCHEMA=[' + @Schema + '], CHECK_POLICY=OFF;')

            -- SET @SQL = ('CREATE LOGIN ' + @UserName + ' WITH DEFAULT_SCHEMA=[' + @Schema + '], PASSWORD=''' + @Password + ''', CHECK_POLICY=OFF;')
            SET @SQL = ('CREATE LOGIN ' + @UserName + ' WITH PASSWORD=''' + @Password + ''', CHECK_POLICY=OFF;')

            IF (@Execute = 1)
            BEGIN
                BEGIN TRANSACTION 
                EXEC(@SQL)

                IF (@@ERROR > 0)
                BEGIN
                    ROLLBACK TRANSACTION
                END
                ELSE
                BEGIN
                    COMMIT TRANSACTION
                END
            END
            ELSE
                PRINT(@SQL)
        END
    END


    IF (@CreateDbLogin = 1)
    BEGIN
        SET @SQL = ('USE [' + @ActiveDb + '];')
        EXEC(@SQL)

        BEGIN
            SET @SQL = ('CREATE USER [' + @UserName + '] FOR LOGIN [' + @UserName + '];');

            IF (@Execute = 1)
            BEGIN
                BEGIN TRANSACTION 
                EXEC(@SQL)

                IF (@@ERROR > 0)
                BEGIN
                    ROLLBACK TRANSACTION
                END
                ELSE
                BEGIN
                    COMMIT TRANSACTION
                END
            END
            ELSE
                PRINT(@SQL)
        END
    END
END

IF (@Purge = 1)
BEGIN
    PRINT('PURGE = 1')
    -- TODO
END

/** NOTES */
/**
GRANT EXECUTE ON pr_Names TO Mary;  
GO  

GRANT SELECT ON vw_Names TO Mary

-- To remove permissions use the REVOKE statement
You must have EXECUTE permission to execute a stored procedure.
You must have SELECT, INSERT, UPDATE, and DELETE permissions to access and change data.
The GRANT statement is also used for other permissions, such as permission to create tables.
*/