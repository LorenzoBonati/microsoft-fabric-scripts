/* ============================================================
   FILE: 02-export-role-permissions.sql
   PURPOSE:
      Export Fabric Warehouse custom roles, explicit GRANT/DENY
      permissions, and role memberships.

      Generates one T-SQL command per row (idempotent).
      Output can be executed in the TARGET Warehouse to restore
      the same security model.

   USAGE:
      Run in SOURCE Warehouse (e.g., Dev).
      Copy full result set → paste into 03-apply script → run in Prod.
   ============================================================ */

IF OBJECT_ID('tempdb..#Out') IS NOT NULL DROP TABLE #Out;
IF OBJECT_ID('tempdb..#BuiltInRoles') IS NOT NULL DROP TABLE #BuiltInRoles;

CREATE TABLE #Out (
    ord int NOT NULL,
    cmd nvarchar(max) COLLATE DATABASE_DEFAULT NOT NULL
);

CREATE TABLE #BuiltInRoles(name sysname COLLATE DATABASE_DEFAULT NOT NULL);
INSERT INTO #BuiltInRoles(name)
VALUES
(N'db_accessadmin'),(N'db_backupoperator'),(N'db_datareader'),(N'db_datawriter'),
(N'db_ddladmin'),(N'db_denydatareader'),(N'db_denydatawriter'),
(N'db_owner'),(N'db_securityadmin'),(N'public');

-------------------------------------------------------------
-- 1) CREATE CUSTOM ROLES (idempotent)
-------------------------------------------------------------
INSERT INTO #Out(ord, cmd)
SELECT
    1,
    N'IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE type=''R'' AND name=N'
    + QUOTENAME(r.name,'''') + N') CREATE ROLE ' + QUOTENAME(r.name) + N';'
FROM sys.database_principals AS r
WHERE r.type='R'
  AND r.name NOT IN (SELECT name FROM #BuiltInRoles);

-------------------------------------------------------------
-- 2) GRANT / DENY permissions
-------------------------------------------------------------
INSERT INTO #Out(ord, cmd)
SELECT
    2,
    CASE
        WHEN dp.class_desc='DATABASE' THEN
            (CASE WHEN dp.state_desc LIKE 'DENY%' THEN N'DENY ' ELSE N'GRANT ' END)
            + UPPER(dp.permission_name)
            + N' TO ' + QUOTENAME(p.name) + N';'

        WHEN dp.class_desc='SCHEMA' THEN
            (CASE WHEN dp.state_desc LIKE 'DENY%' THEN N'DENY ' ELSE N'GRANT ' END)
            + UPPER(dp.permission_name)
            + N' ON SCHEMA::' + QUOTENAME(SCHEMA_NAME(dp.major_id))
            + N' TO ' + QUOTENAME(p.name) + N';'

        WHEN dp.class_desc='OBJECT_OR_COLUMN' AND dp.minor_id=0 THEN
            (CASE WHEN dp.state_desc LIKE 'DENY%' THEN N'DENY ' ELSE N'GRANT ' END)
            + UPPER(dp.permission_name)
            + N' ON OBJECT::'
            + QUOTENAME(OBJECT_SCHEMA_NAME(dp.major_id)) + N'.' + QUOTENAME(OBJECT_NAME(dp.major_id))
            + N' TO ' + QUOTENAME(p.name)
            + CASE WHEN dp.state_desc='GRANT_WITH_GRANT_OPTION' THEN N' WITH GRANT OPTION' ELSE N'' END
            + N';'

        WHEN dp.class_desc='OBJECT_OR_COLUMN' AND dp.minor_id>0 THEN
            (CASE WHEN dp.state_desc LIKE 'DENY%' THEN N'DENY ' ELSE N'GRANT ' END)
            + UPPER(dp.permission_name)
            + N' (' + QUOTENAME(COL_NAME(dp.major_id, dp.minor_id)) + N')'
            + N' ON OBJECT::'
            + QUOTENAME(OBJECT_SCHEMA_NAME(dp.major_id)) + N'.' + QUOTENAME(OBJECT_NAME(dp.major_id))
            + N' TO ' + QUOTENAME(p.name)
            + N';'
    END
FROM sys.database_permissions dp
JOIN sys.database_principals p ON p.principal_id = dp.grantee_principal_id
WHERE p.type='R'
  AND p.name NOT IN (SELECT name FROM #BuiltInRoles);

-------------------------------------------------------------
-- 3) ROLE MEMBERSHIPS (idempotent)
-------------------------------------------------------------
INSERT INTO #Out(ord, cmd)
SELECT
    3,
    N'IF NOT EXISTS (SELECT 1 FROM sys.database_role_members WHERE role_principal_id = DATABASE_PRINCIPAL_ID(N'
    + QUOTENAME(r.name,'''') + N') AND member_principal_id = DATABASE_PRINCIPAL_ID(N'
    + QUOTENAME(m.name,'''') + N')) ALTER ROLE ' + QUOTENAME(r.name)
    + N' ADD MEMBER ' + QUOTENAME(m.name) + N';'
FROM sys.database_role_members drm
JOIN sys.database_principals r ON r.principal_id = drm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = drm.member_principal_id
WHERE r.type='R'
  AND r.name NOT IN (SELECT name FROM #BuiltInRoles);

-------------------------------------------------------------
-- 4) OUTPUT
-------------------------------------------------------------
SELECT cmd
FROM #Out
ORDER BY ord, cmd;
   
