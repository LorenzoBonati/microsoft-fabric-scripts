/* ============================================================
   FILE: 01-permissions-precheck.sql
   PURPOSE:
      Pre-check tool to understand which permissions exist in a
      Fabric Warehouse before exporting them.

      Identifies:
       - Permissions granted to database roles
       - Permissions granted directly to users/groups
         (These will NOT be exported by the main Export script)

   USAGE:
      Run in the SOURCE Warehouse (e.g., Dev).
      Helps the user understand the security model PRIOR to export.
   ============================================================ */

-------------------------------
-- SUMMARY: Count by principal kind
-------------------------------
SELECT
    CASE WHEN p.type = 'R' THEN 'ROLE' ELSE 'USER_OR_GROUP' END AS principal_kind,
    COUNT(*) AS explicit_permission_count
FROM sys.database_permissions dp
JOIN sys.database_principals p ON p.principal_id = dp.grantee_principal_id
WHERE p.name <> 'public'
GROUP BY CASE WHEN p.type = 'R' THEN 'ROLE' ELSE 'USER_OR_GROUP' END;


-------------------------------
-- ROLE-BASED PERMISSIONS
-------------------------------
SELECT
    'ROLE' AS principal_kind,
    p.name AS principal_name,
    p.type_desc AS principal_type,
    dp.state_desc AS permission_state,
    dp.permission_name,
    dp.class_desc,
    CASE WHEN dp.class_desc='SCHEMA' THEN SCHEMA_NAME(dp.major_id)
         WHEN dp.class_desc='OBJECT_OR_COLUMN' THEN OBJECT_SCHEMA_NAME(dp.major_id) END AS schema_name,
    CASE WHEN dp.class_desc='OBJECT_OR_COLUMN' THEN OBJECT_NAME(dp.major_id) END AS object_name,
    CASE WHEN dp.minor_id>0 THEN COL_NAME(dp.major_id,dp.minor_id) END AS column_name
FROM sys.database_permissions dp
JOIN sys.database_principals p ON p.principal_id = dp.grantee_principal_id
WHERE p.type='R' AND p.name<>'public'
ORDER BY principal_name;


-------------------------------
-- DIRECT USER/GROUP PERMISSIONS
-- (These are NOT exported by the main script)
-------------------------------
SELECT
    'USER_OR_GROUP' AS principal_kind,
    p.name AS principal_name,
    p.type_desc AS principal_type,
    dp.state_desc AS permission_state,
    dp.permission_name,
    dp.class_desc,
    CASE WHEN dp.class_desc='SCHEMA' THEN SCHEMA_NAME(dp.major_id)
         WHEN dp.class_desc='OBJECT_OR_COLUMN' THEN OBJECT_SCHEMA_NAME(dp.major_id) END AS schema_name,
    CASE WHEN dp.class_desc='OBJECT_OR_COLUMN' THEN OBJECT_NAME(dp.major_id) END AS object_name,
    CASE WHEN dp.minor_id>0 THEN COL_NAME(dp.major_id,dp.minor_id) END AS column_name
FROM sys.database_permissions dp
JOIN sys.database_principals p ON p.principal_id = dp.grantee_principal_id
WHERE p.type <> 'R' AND p.name <> 'public'
ORDER BY principal_name;
