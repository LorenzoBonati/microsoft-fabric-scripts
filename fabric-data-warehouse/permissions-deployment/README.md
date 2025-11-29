# Fabric Data Warehouse – Permissions Deployment Scripts

These scripts help manage **database role permissions** in Microsoft Fabric Data Warehouse when promoting a Warehouse between environments (for example, Dev → Prod).

Currently, Fabric deployment pipelines and Git integration do **not** transfer explicit object-level permissions (GRANT/DENY). These scripts provide a manual but repeatable way to:

- Inspect which permissions exist in the source Warehouse
- Export role-based permissions
- Reapply them in the target Warehouse after deployment

> ℹ️ At the moment this process is manual. In the future this folder may be updated with pipeline/notebook samples to automate execution (Dev → export → Prod → apply).

---

## 📄 Scripts

### 1️⃣ `01-permissions-precheck.sql`

**Purpose**

Run a **pre-check** in the source Warehouse to understand the current permission model.

It shows:

- How many explicit permissions are granted to **roles**
- How many explicit permissions are granted directly to **users / groups**
- Detailed lists of:
  - role-based permissions
  - direct user/group permissions

**When to use**

- Before exporting permissions, to know what will be handled by the export script.
- To explain to customers which permissions are role-based and which are directly assigned to users/groups.

---

### 2️⃣ `02-export-role-permissions.sql`

**Purpose**

Export all **role-based permissions** from the source Warehouse as executable T-SQL.

The script generates:

- `CREATE ROLE` statements for **custom roles** (idempotent)
- `GRANT` / `DENY` statements for:
  - database-level permissions
  - schema-level permissions
  - object-level permissions (tables/views)
  - column-level permissions
- `ALTER ROLE ... ADD MEMBER ...` statements for role memberships

The output is **one command per row** in the `cmd` column, designed to be:

- copied from Dev, and
- executed in Prod to recreate the same security model.

**What it deliberately does _not_ do**

- It does **not** export permissions for built-in roles  
  (`db_datareader`, `db_datawriter`, `db_owner`, `public`, etc.) because their permissions are engine-defined.
- It does **not** export direct GRANTs to users/groups (`EXTERNAL_USER`, `EXTERNAL_GROUP`)—only role-based grants.

---

## 🚀 Typical Usage Flow (Manual)

1. **In Dev (source Warehouse)**  
   - Run `01-permissions-precheck.sql` to understand the current permissions layout.  
   - Run `02-export-role-permissions.sql`.  
   - Copy the result directly from the Fabric SQL Editor UI to have a script ready to paste:
   <img width="1575" height="460" alt="image" src="https://github.com/user-attachments/assets/fa4e4a8b-9356-4509-90cb-864ca0717212" />


2. **In Prod (target Warehouse)**  
   - Paste the copied commands into a new query window.  
   - Execute them against the target Warehouse **after** deploying the Warehouse item.

This recreates:

- Custom roles  
- Their GRANT/DENY permissions  
- Role memberships  

in the target environment.

---

## 🔭 Future Automation

In a future iteration, this folder may include:

- Example Azure DevOps / GitHub pipelines that:
  - Run the export script in Dev
  - Combine the `cmd` rows into a single SQL batch
  - Execute the batch in Prod automatically
- Fabric Data Factory / Notebook examples doing the same inside Fabric.

When that is available, this README will be updated with concrete automation steps.
