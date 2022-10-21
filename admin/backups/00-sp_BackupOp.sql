USE tempdb;
GO


-- EXEC tempdb.dbo.BackupOperation
-- --   @Execute = 0,
--   @Action = 'Restore',
--   @DBName = 'TestData',
-- --   @RestoreFile = "TestData_22222.bak" 
--   ;


EXEC tempdb.dbo.BackupOperation
  @Action = '',  -- 'Restore' or 'Create'
  @DBName = 'TestData',
  @RestoreFile = 'TestData_22222.bak',
  @CreateFile = '';


-- DROP PROC dbo.BackupOperation


-- CREATE PROC dbo.BackupOperation
-- --   @Execute bit = 0,
--   @Action varchar,  -- change to declare action here and execute based on case
--   @DBName sysname,
--   @RestoreFile nvarchar = '',
--   @CreateFile nvarchar = '',
--   @DelimChar char = '\'
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     DECLARE @BackupDirectory NVARCHAR(32);
--     DECLARE @SQL NVARCHAR(MAX);
--     DECLARE @FileListTable TABLE (
--         [LogicalName] NVARCHAR(128),
--         [PhysicalName] NVARCHAR(260),
--         [Type] CHAR(1),
--         [FileGroupName] NVARCHAR(128),
--         [Size] NUMERIC(20,0),
--         [MaxSize] NUMERIC(20,0),
--         [FileID] BIGINT,
--         [CreateLSN] NUMERIC(25,0),
--         [DropLSN] NUMERIC(25,0),
--         [UniqueID] UNIQUEIDENTIFIER,
--         [ReadOnlyLSN] NUMERIC(25,0),
--         [ReadWriteLSN] NUMERIC(25,0),
--         [BackupSizeInBytes] BIGINT,
--         [SourceBlockSize] INT,
--         [FileGroupID] INT,
--         [LogGroupGUID] UNIQUEIDENTIFIER,
--         [DifferentialBaseLSN] NUMERIC(25,0),
--         [DifferentialBaseGUID] UNIQUEIDENTIFIER,
--         [IsReadOnly] BIT,
--         [IsPresent] BIT,
--         [TDEThumbprint] VARBINARY(32),
--         -- remove this column if using SQL 2005
--         [SnapshotURL] NVARCHAR(360) -- remove this column if using less than SQL 2016 (13.x)
--     )

--     /* dual use variables*/
--     SET @BackupDirectory = '/var/opt/mssql/backup/';


--     IF (@Action = 'Restore')
--     BEGIN
--         DECLARE @DataDirectory NVARCHAR(32);        
--         DECLARE @AddStmt NVARCHAR(MAX);
--         DECLARE @CurrStmt NVARCHAR(128);
--         /* restore variable only */
--         SET @DataDirectory = '/var/opt/mssql/data/';
--         -- IF OBJECT_ID('tempdb..##BackupFiles', 'U') IS NOT NULL
--         -- BEGIN
--         --     DROP TABLE ##BackupFiles
--         --     -- Create statement here
--         -- END

--         -- one-liner for 2016 and beyond!
--         DROP TABLE IF EXISTS ##BackupFiles

--         SET @SQL = ('RESTORE FILELISTONLY FROM DISK = ''' + CONCAT(@BackupDirectory, @RestoreFile) + '''; ' )

--         INSERT INTO @FileListTable
--         EXEC(@SQL)

--         SELECT LogicalName as Src,
--             SUBSTRING(PhysicalName, LEN(PhysicalName) - CHARINDEX(@DelimChar, REVERSE(PhysicalName)) + 2, LEN(PhysicalName)) as Dest
--         INTO ##BackupFiles
--         FROM @FileListTable

--         /* BEGIN CURSOR */
--         DECLARE @Src NVARCHAR(128);
--         DECLARE @Dest NVARCHAR(128);

--         DECLARE curBackupFiles CURSOR FAST_FORWARD FOR
--         (SELECT Src, Dest FROM ##BackupFiles)

--         OPEN curBackupFiles
--         FETCH NEXT FROM curBackupFiles
--         INTO @Src, @Dest

--         SET @AddStmt = '';

--         WHILE @@FETCH_STATUS = 0
--         BEGIN
--             SET @CurrStmt = (' MOVE ''' + @Src + ''' TO ''' + CONCAT(@DataDirectory, @Dest) + ''',')
--             SET @AddStmt = @AddStmt + @CurrStmt

--             FETCH NEXT FROM curBackupFiles
--             INTO @Src, @Dest
--         END

--         CLOSE curBackupFiles
--         DEALLOCATE curBackupFiles
--         /* END CURSOR */

--         SET @AddStmt = LEFT(@AddStmt, LEN(@AddStmt)-1)
--         SET @AddStmt = CONCAT(@AddStmt, ';');

--         SET @SQL = 'RESTORE DATABASE ' + @DBName + ' FROM DISK = ''' + CONCAT(@BackupDirectory, @RestoreFile) + ''' WITH';

--         SET @SQL = @SQL + @AddStmt
    
--     END

--     IF (@Action = 'Create')
--     BEGIN
--         DECLARE @CurrDate INT;
--         /* backup variable only */
--         -- -- SET @CurrDate = CONVERT(VARCHAR, GETDATE(), 112);
--         -- -- Unix epoch FTW!
--         SET @CurrDate = DATEDIFF(SECOND, '19700101', sysutcdatetime());

--         SET @CreateFile = CONCAT(@DBName, '_', STR(@CurrDate), '.bak')
--         SET @SQL = ('BACKUP DATABASE [' + @DBName + '] TO DISK = ''' + CONCAT(@BackupDirectory, @CreateFile) + ''' WITH NOFORMAT, NOINIT, NAME = ''' + CONCAT(@DBName, N'-full') + ''', SKIP, NOREWIND, NOUNLOAD, STATS = 10;');
--     END

--     -- IF (@Execute = 1)
--     -- BEGIN
--     --     EXEC(@SQL)
--     -- END
--     -- ELSE
--     -- BEGIN
--     --     PRINT(@SQL)
--     -- END
--     EXEC(@SQL)

-- END