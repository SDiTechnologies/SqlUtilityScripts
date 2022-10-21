




/* Transaction example that doesn't work because you can't perform restores in a transaction */
IF (@Execute = 1)
BEGIN
    BEGIN TRANSACTION
    /* CURSOR START */
    DECLARE @Src NVARCHAR(128);
    DECLARE @Dest NVARCHAR(128);

    DECLARE curBackupFiles CURSOR FAST_FORWARD FOR
    (SELECT Src, Dest FROM ##BackupFiles)

    OPEN curBackupFiles
    FETCH NEXT FROM curBackupFiles
    INTO @Src, @Dest

    SET @SQL = 'RESTORE DATABASE ' + @TargetDb + ' FROM DISK = ''' + CONCAT(@BackupDirectory, @BackupFile) + ''' WITH';

    SET @MigrateStmt = '';

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @CurrStmt = (' MOVE ''' + @Src + ''' TO ''' + CONCAT(@DataDirectory, @Dest) + ''',')
        SET @MigrateStmt = @MigrateStmt + @CurrStmt

        FETCH NEXT FROM curBackupFiles
        INTO @Src, @Dest
    END

    CLOSE curBackupFiles
    DEALLOCATE curBackupFiles

    SET @MigrateStmt = LEFT(@MigrateStmt, LEN(@MigrateStmt)-1)
    SET @MigrateStmt = CONCAT(@MigrateStmt, ';');

    SET @SQL = @SQL + @MigrateStmt

    EXEC(@SQL)
    -- PRINT(@SQL)


    IF (@@ERROR > 0)
    BEGIN
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        COMMIT TRANSACTION
    END
END






