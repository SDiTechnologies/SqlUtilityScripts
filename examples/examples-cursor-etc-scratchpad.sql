-- DECLARE @tags NVARCHAR(400) = 'clothing,road,,touring,bike'  

-- -- SELECT TOP 1 value  
-- -- FROM STRING_SPLIT(@tags, ',')  
-- -- WHERE RTRIM(value) <> ''
-- -- ORDER BY value DESC;

-- SELECT value  
-- FROM STRING_SPLIT(@tags, ',')
-- WHERE RTRIM(value) <> '';


/* CURSOR */
-- use master
-- --fetch cursor sample
-- --It shows backup scripts
-- declare @db_list table(dbase_name sysname)

-- insert into @db_list
-- select [name] from sys.databases
-- where database_id>4  --- I don't want system databases' backupdeclare @sqlcmd2 nvarchar(250)

-- declare @db_name sysname 
-- --What is sysname type? I will explain below

-- declare database_cursor cursor for
-- select [dbase_name] from @db_listopen database_cursor
-- fetch next from database_cursor into @db_name
-- while @@FETCH_STATUS = 0
-- begin
--  SELECT @sqlcmd2 = ‘BACKUP DATABASE ‘ 
--  + @db_name + ‘TO DISK=’’E:\SQLBackups\’ + @db_name + ‘.bak’’
--  WITH COMPRESSION;’
-- PRINT (@sqlcmd2);
-- FETCH NEXT FROM database_cursor INTO @db_name;
-- end
-- close database_cursor
-- deallocate database_cursor


/* WHILE LOOP */
Declare  @dhome Tinyint, @bp smallint, @lr smallint, @q smallint

Set @dhome = 1
While(@dhome <= 3) // My attempt to add a loop
begin
  SELECT @lr = MAX(NQdDate), @q = NQd
  FROM NQdHistory
  WHERE dhomeId = @dhome 
  GROUP BY NQdDate, NQd

  SELECT @bd = COUNT(*)
  FROM bdhome
  WHERE NQdDate= @lr AND dhomeID= @dhome 

  DELETE FROM ND1 WITH(XLOCK)
  WHERE dhomeID= @dhome  AND NQdDate= @lr

  UPDATE NQdHistory
  SET Nbd = @q - @@RowCount - @bp, NBd = @bp
  WHERE NQdDate= @lr AND dhomeID= @dhome 

  Set @dhome = @dhome +1 //My attempt to end a loop
end  