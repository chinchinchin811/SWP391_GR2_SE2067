# Database snapshots

`snapshots/HRM_Project_DB.sql` is the full application schema and data snapshot
explicitly approved for sharing, including unchanged account passwords and
personal information. Its companion `.counts.csv` records the exported row
counts. It was imported successfully into an isolated database and checked
against the source: 26 tables, 660 rows, matching row counts for every table.
This snapshot reflects existing data, not recovery of previously deleted data.

Export the current SQL Server schema and data using Windows authentication:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\hrm-career-path\database\export_database.ps1
```

Requires Windows PowerShell 5.1 and the SQL Server SQLPS module. The default
server is `localhost` and database is `HRM_Project_DB`; override with `-Server`
and `-Database` if needed. Pause application writes during export so related
tables represent the same application state.

Exports and table row counts go to `local_exports/`, which Git ignores because
the snapshot includes account passwords, personal information and file data.
Review a snapshot before deliberately sharing it. The export covers application
schemas, tables, data, constraints, indexes, triggers, views, functions,
procedures, sequences and user-defined types. It is not a server backup and
does not include server logins, jobs or database permission configuration.

To import, first create a **new empty database** in SSMS, then select that
database and execute the snapshot. The snapshot does not create/drop a database
or change the selected database. Do not execute it on a populated database.
Verify table counts and application behavior before switching the application
connection. Keep the previous database available until verification is complete.

Git push/pull transfers SQL files only; it does not apply them to SQL Server.
To publish a later snapshot, run the export, verify it in a separate database,
review the data being shared, then copy the SQL and counts into `snapshots/`
and commit/push those files. This is a manual snapshot workflow, not live sync.
The existing `schema/create_tables_sqlserver.sql` drops and recreates
`HRM_Project_DB`; do not use it to update a database whose data you want to keep.
Seed scripts provide sample data, not recovery of previously deleted data.
