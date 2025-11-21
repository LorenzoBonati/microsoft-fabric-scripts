# Fabric Data Warehouse – Support Scripts

This folder contains scripts and utilities for troubleshooting Microsoft Fabric Data Warehouse scenarios.  

> ⚠️ These scripts are intended for support engineers and advanced users.  
> Always validate changes in a non-production environment before applying them to customer workloads.

---

## 📌 Script: Delete Orphaned SQL Analytics Endpoint

**Path:** `fabric-data-warehouse/delete_fabric_orphaned_sql_analytics_endpoint.py`  
**Purpose:** Removes an orphaned SQL Analytics Endpoint from a Fabric workspace, including its associated Semantic Model.

### 🧭 When to use this script

Run this script when:

- A Lakehouse was deleted, but its SQL Endpoint and/or Semantic Model remain in the workspace  
- You encounter deployment errors such as:
  - `InvalidShortcutPayloadBatchErrors`
  - `Shortcut metadata not found for the path /<workspace-id>/<lakehouse-id>/Tables/...`
- The Fabric UI cannot delete the SQL Endpoint  
- Power BI / Lakehouse operations fail due to stale metadata

This script issues the same DELETE call used by PowerShell, but runs natively inside a Fabric Notebook.

---

## 🔧 Required Parameters (and How to Get Them)

To run the cleanup you only need two values:  
- **Host URL** – Open the affected workspace → press **F12** → **Network** tab → refresh the web page → select any successful GET request → copy the value in the `:authority` / `Host` header (example: `wabi-west-us3-a-primary-redirect.analysis.windows.net`).
  
  <img width="1200" height="580" alt="image" src="https://github.com/user-attachments/assets/74c0bcd7-170b-4511-8a21-45d540b00e14" />

- **Artifact ID** – Open the SQL Endpoint in your browser → copy the ArtifactID that appears in the URL after `mirroredwarehouses/` (example structure: `https://msit.powerbi.com/groups/
<workspace-id>/mirroredwarehouses/<artifact-id>?experience=fabric-developer`).  

No bearer token is required when using the Fabric Notebook, as it is automatically retrieved.
