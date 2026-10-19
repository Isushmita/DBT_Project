---
name: dbt-add-data
description: Add new raw data or a new model to the user's practice dbt project (orders_project) — a new seed CSV, source, staging model, mart, column, or test. Use when the user asks to "add a table", "make a CSV", "bring X into the view", "add a column", "add a test", or build a new model. For just running/building/docs, use dbt-project instead.
---

# Changing orders_project

The user is learning dbt. Make the change end to end, run it, then explain what each file does and why it was needed. Keep their style: small CTEs, lowercase SQL, a one-line `description` on everything.

Project folder: `C:\Users\joshc\Repos\DBT_Project\orders_project`
dbt: `C:\Users\joshc\.venvs\dbt\Scripts\dbt.exe <command> --no-version-check` (dbt 1.12, DuckDB)

## Layout
- `seeds/raw_*.csv` — fake raw data, deliberately messy (stray spaces, mixed case) so staging has something to clean.
- `models/staging/sources.yml` — every seed is registered as a table under source `shop` (schema `main`).
- `models/staging/stg_*.sql` — views; read raw data only via `{{ source('shop', '...') }}`, clean and rename.
- `models/staging/schema.yml`, `models/marts/schema.yml` — descriptions and tests.
- `models/marts/*.sql` — tables; read only via `{{ ref('stg_...') }}` or other marts, never from sources.
- `models/marts/dim_customers.sql` — the one place customer attributes are joined together (names, region, gender). Marts that need customer info read from it.

## The standard (user's rule — always follow)
- **Every seed gets its own `stg_` model, 1:1.** `raw_<name>.csv` → `stg_<name>.sql`.
- **Staging never joins.** It only cleans one table: rename, trim, recast, map codes to labels. CTEs inside a staging model are fine for readability.
- **Joins happen in marts.** New per-customer attributes get joined into `dim_customers`, not into `stg_customers`.

## Adding a new raw table (the full checklist)
1. **Seed** — `seeds/raw_<name>.csv`. Header row, lowercase snake_case columns, keyed to existing IDs (customers are 101–108, orders 1+). Add a little realistic mess.
2. **Source** — add `- name: raw_<name>` with a description under `shop.tables` in `sources.yml`.
3. **Staging** — always a new `stg_<name>.sql` that reads only that one source. No joins.
4. **Mart** — if the data needs combining, join it in a mart (per-customer attributes → `dim_customers`). Use a `left join` so missing rows don't drop records.
5. **Tests** — in `schema.yml`: `unique` + `not_null` on keys, `accepted_values` for categorical columns, `relationships` for foreign keys (e.g. `stg_customer_regions.customer_id` → `stg_customers`).
6. **Run** — `dbt seed`, then `dbt build`, then `dbt show --select <model>` to show the user the result.

## Syntax gotchas
- dbt 1.12 test arguments go under `arguments:`:
  ```yaml
  data_tests:
    - accepted_values:
        arguments:
          values: ['a', 'b']
    - relationships:
        arguments:
          to: ref('stg_customers')
          field: customer_id
  ```
- DuckDB has no `initcap`. Title-case with `upper(left(x, 1)) || lower(substr(x, 2))`, but that only capitalizes the first word — for multi-word labels ("North America") use an explicit `case` mapping.
- New seeds must be loaded with `dbt seed` before `dbt build`, because staging reads them through `source()` and dbt doesn't order seeds first.
- If errors mention a path under `OneDrive\Documents\DBT_Course`, `target/` is stale from before the project moved: delete `target/` and rerun.
- Renaming or deleting a seed/model leaves the old table in `dev.duckdb`. Use `.\run.ps1 fresh` for a clean slate.

## After the change
- Show a `dbt show` preview of the changed model.
- Mention `.\run.ps1 docs` if they want to see the new pieces in the lineage graph.
- Don't commit unless asked.
