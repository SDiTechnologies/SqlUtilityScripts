-- Cleanup
USE TestA;
GO


IF EXISTS(SELECT name FROM sys.database_principals WHERE name = 'Jimmy')
  DROP USER Jimmy;
GO 

USE TestB;
GO 

IF EXISTS(SELECT name FROM sys.database_principals WHERE name = 'Jimmy')
  DROP USER Jimmy;
GO 

USE master;
GO 

IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'Jimmy')
  DROP LOGIN Jimmy;
GO


-- -- Create User
-- -- EXEC DBAWork.dbo.CloneLoginAndAllDBPerms
-- --   @NewLogin = 'Jimmy',
-- --   @NewLoginPwd = 'SomeOtherPassw0rd!',
-- --   @LoginToClone = 'Bobby',
-- --   @WindowsLogin = 'F';