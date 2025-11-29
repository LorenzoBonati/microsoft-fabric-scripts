# Fabric Data Warehouse – Support Scripts

This repository contains support and utility scripts for working with **Microsoft Fabric Data Warehouse**.

The goal is to collect reusable tools that help troubleshoot, repair, and manage Fabric DW environments in real-world support scenarios.

> ⚠️ These scripts are intended for support engineers and advanced users.  
> Always validate changes in a non-production environment before applying them to customer workloads.

---

## 📂 Structure

### `delete-orphaned-sql-analytics-endpoint/`

Scripts and documentation for cleaning up **orphaned SQL Analytics Endpoints** and related Semantic Models when a Lakehouse has been deleted but the SQL endpoint remains.

See the detailed README in that folder:

👉 [`delete-orphaned-sql-analytics-endpoint/README.md`](./delete-orphaned-sql-analytics-endpoint/README.md)

---

### `permissions-deployment/`

Scripts to **inspect and export permissions** from a Fabric Warehouse so they can be reapplied in another environment (for example, Dev → Prod), addressing the current limitation where object-level permissions (GRANT/DENY) are not carried by deployment pipelines or Git integration.

See the dedicated README in that folder:

👉 [`permissions-deployment/README.md`](./permissions-deployment/README.md)

---

More folders and scripts may be added over time as additional Fabric DW scenarios are documented.
