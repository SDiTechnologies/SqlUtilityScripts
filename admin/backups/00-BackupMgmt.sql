/** BEGIN runtime execution path variables */
DECLARE @Execute BIT = 0;

/** ONLY ONE MUST BE SET = 1 **/
DECLARE @Restore BIT = 1;
DECLARE @Backup BIT = 0;

/** END runtime execution path variables */

DECLARE @BackupDirectory NVARCHAR(32);
DECLARE @DataDirectory NVARCHAR(32);
DECLARE @RestoreFile NVARCHAR(32);
DECLARE @BackupFile NVARCHAR(128);
DECLARE @ActiveDb NVARCHAR(32);
DECLARE @DelimChar CHAR;
DECLARE @SQL NVARCHAR(MAX);
DECLARE @AddStmt NVARCHAR(MAX);
DECLARE @CurrStmt NVARCHAR(128);
DECLARE @CurrDate INT;

/* dual use variables*/
SET @ActiveDb = 'TutorialDB';
SET @BackupDirectory = '/var/opt/mssql/backup/';

/* restore variable only */
SET @RestoreFile = 'TutorialDB.bak';
SET @DelimChar = '\';
SET @DataDirectory = '/var/opt/mssql/data/';

/* backup variable only */
-- SET @CurrDate = CONVERT(VARCHAR, GETDATE(), 112);
-- Unix epoch FTW!
SET @CurrDate = DATEDIFF(SECOND, '19700101', sysutcdatetime());


DECLARE @FileListTable TABLE (
    [LogicalName]           NVARCHAR(128),
    [PhysicalName]          NVARCHAR(260),
    [Type]                  CHAR(1),
    [FileGroupName]         NVARCHAR(128),
    [Size]                  NUMERIC(20,0),
    [MaxSize]               NUMERIC(20,0),
    [FileID]                BIGINT,
    [CreateLSN]             NUMERIC(25,0),
    [DropLSN]               NUMERIC(25,0),
    [UniqueID]              UNIQUEIDENTIFIER,
    [ReadOnlyLSN]           NUMERIC(25,0),
    [ReadWriteLSN]          NUMERIC(25,0),
    [BackupSizeInBytes]     BIGINT,
    [SourceBlockSize]       INT,
    [FileGroupID]           INT,
    [LogGroupGUID]          UNIQUEIDENTIFIER,
    [DifferentialBaseLSN]   NUMERIC(25,0),
    [DifferentialBaseGUID]  UNIQUEIDENTIFIER,
    [IsReadOnly]            BIT,
    [IsPresent]             BIT,
    [TDEThumbprint]         VARBINARY(32), -- remove this column if using SQL 2005
    [SnapshotURL]           NVARCHAR(360) -- remove this column if using less than SQL 2016 (13.x)
)

IF (@Restore != @Backup)
BEGIN
    IF (@Restore = 1)
    BEGIN
        -- IF OBJECT_ID('tempdb..##BackupFiles', 'U') IS NOT NULL
        -- BEGIN
        --     DROP TABLE ##BackupFiles
        --     -- Create statement here
        -- END

        -- one-liner for 2016 and beyond!
        DROP TABLE IF EXISTS ##BackupFiles

        SET @SQL = ('RESTORE FILELISTONLY FROM DISK = ''' + CONCAT(@BackupDirectory, @RestoreFile) + '''; ' )

        INSERT INTO @FileListTable
        EXEC(@SQL)

        SELECT LogicalName as Src,
            SUBSTRING(PhysicalName, LEN(PhysicalName) - CHARINDEX(@DelimChar, REVERSE(PhysicalName)) + 2, LEN(PhysicalName)) as Dest
        INTO ##BackupFiles
        FROM @FileListTable

        /* BEGIN CURSOR */
        DECLARE @Src NVARCHAR(128);
        DECLARE @Dest NVARCHAR(128);

        DECLARE curBackupFiles CURSOR FAST_FORWARD FOR
        (SELECT Src, Dest FROM ##BackupFiles)

        OPEN curBackupFiles
        FETCH NEXT FROM curBackupFiles
        INTO @Src, @Dest

        SET @AddStmt = '';

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @CurrStmt = (' MOVE ''' + @Src + ''' TO ''' + CONCAT(@DataDirectory, @Dest) + ''',')
            SET @AddStmt = @AddStmt + @CurrStmt

            FETCH NEXT FROM curBackupFiles
            INTO @Src, @Dest
        END

        CLOSE curBackupFiles
        DEALLOCATE curBackupFiles
        /* END CURSOR */

        SET @AddStmt = LEFT(@AddStmt, LEN(@AddStmt)-1)
        SET @AddStmt = CONCAT(@AddStmt, ';');

        SET @SQL = 'RESTORE DATABASE ' + @ActiveDb + ' FROM DISK = ''' + CONCAT(@BackupDirectory, @RestoreFile) + ''' WITH';

        SET @SQL = @SQL + @AddStmt

        IF (@Execute = 1)
        BEGIN
            EXEC(@SQL)
        END
        ELSE
        BEGIN
            PRINT(@SQL)
        END
    END


    IF (@Backup = 1)
    BEGIN
        SET @BackupFile = CONCAT(@ActiveDb, '_', STR(@CurrDate), '.bak')
        SET @SQL = ('BACKUP DATABASE [' + @ActiveDb + '] TO DISK = ''' + CONCAT(@BackupDirectory, @BackupFile) + ''' WITH NOFORMAT, NOINIT, NAME = ''' + CONCAT(@ActiveDb, N'-full') + ''', SKIP, NOREWIND, NOUNLOAD, STATS = 10;');

        IF (@Execute = 1)
        BEGIN
            EXEC(@SQL)
        END
        ELSE
        BEGIN
            PRINT(@SQL)
        END
    END
END
ELSE
    PRINT('@Restore and @Backup MUST NOT BE equal.')