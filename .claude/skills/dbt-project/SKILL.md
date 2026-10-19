---
name: dbt-project
description: Run, inspect or troubleshoot the user's practice dbt project (orders_project) in this folder. Use when the user asks to build, rebuild, test, show results, open docs, or "run the project", or forgets how to run it.
---

# Running orders_project

The user is learning dbt. Run what they ask, then explain the output in plain language: what was built, what passed or failed, and why.

## Facts
- Project folder: `C:\Users\joshc\OneDrive\Documents\DBT_Course\orders_project`
- dbt 1.12 (dbt Core v1) with DuckDB, installed in a venv at `C:\Users\joshc\.venvs\dbt` (outside OneDrive on purpose).
- Run dbt by full path, from the project folder: `C:\Users\joshc\.venvs\dbt\Scripts\dbt.exe <command> --no-version-check`
- `profiles.yml` lives in the project folder; the database is the file `dev.duckdb`.
- The user's own shortcut is `.\run.ps1` (build, fresh, show [model], test, docs, help). Remind them of it when useful.

## Gotchas
- Staging models read seeds through `source()`, so dbt doesn't know to load seeds first. On a fresh database (no `dev.duckdb`), run `dbt seed` before `dbt build`. `run.ps1` does this automatically.
- DuckDB SQL differs from Postgres/Snowflake (for example, there is no `initcap`).
- `dbt docs serve` blocks the terminal. Run it in the background, or tell the user to run `.\run.ps1 docs` themselves.

## Common requests
| User says | Run |
|---|---|
| build / run the project | `dbt build` (seed first if `dev.duckdb` is missing) |
| start over / clean rebuild | delete `dev.duckdb` and `target/`, then `dbt seed`, then `dbt build` |
| show me the results | `dbt show --select customer_revenue` (or the model they name) |
| run the tests | `dbt test` |
| open the docs / lineage | `dbt docs generate`, then `dbt docs serve` in the background |
