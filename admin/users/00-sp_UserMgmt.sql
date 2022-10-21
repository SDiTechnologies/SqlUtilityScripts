/****** Clone a SQL Server Login with server and database permissions *********
Source: www.mssqltips.com/sqlservertip/3648/how-to-clone-a-sql-server-login-part-3-of-3

Step 1: Creation 5 stored procedures
CloneLoginAndAllDBPerms <- master script
 GrantUserRoleMembership
 CreateUserInDB
 CloneLogin
 CloneDBPerms

Step 2: Run the query:

EXEC tempdb.dbo.CloneLoginAndAllDBPerms
  @NewLogin = 'NewUser',
  @NewLoginPwd = 'Passw0rd!',
  @LoginToClone = 'ExistingUser',
  @WindowsLogin = 'F';
  
Step 3: Undo:

IF EXISTS(SELECT name FROM sys.procedures WHERE name = 'CloneLogin')
  DROP PROCEDURE dbo.CloneLogin;
GO 
DROP PROCEDURE dbo.CloneLoginAndAllDBPerms;
DROP PROCEDURE dbo.GrantUserRoleMembership;
DROP PROCEDURE dbo.CreateUserInDB;
DROP PROCEDURE dbo.CloneLogin;
DROP PROCEDURE dbo.CloneDBPerms;
  
********************************************************************************/