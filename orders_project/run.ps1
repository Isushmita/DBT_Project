<#
  Shortcut for running this dbt project. You don't need to activate anything first.

  .\run.ps1            Build everything (same as .\run.ps1 build)
  .\run.ps1 fresh      Delete the database and rebuild from scratch
  .\run.ps1 show       Show the rows of customer_revenue
  .\run.ps1 show stg_orders   Show the rows of any model
  .\run.ps1 test       Run only the tests
  .\run.ps1 docs       Build the docs site and open it (Ctrl+C to stop)
  .\run.ps1 help       Show this list
#>
param(
    [ValidateSet('build', 'fresh', 'show', 'test', 'docs', 'help')]
    [string]$Task = 'build',
    [string]$Model = 'customer_revenue'
)

$dbt = 'C:\Users\joshc\.venvs\dbt\Scripts\dbt.exe'
Set-Location $PSScriptRoot

if (-not (Test-Path $dbt)) {
    Write-Host "dbt isn't installed at $dbt. Ask Claude to reinstall it." -ForegroundColor Red
    exit 1
}

function Step($text) { Write-Host "`n>> $text" -ForegroundColor Cyan }

# If the database doesn't exist yet, the seeds must be loaded before anything reads them.
function Ensure-Seeded {
    if (-not (Test-Path 'dev.duckdb')) {
        Step 'No database yet: loading seeds first (dbt seed)'
        & $dbt seed --no-version-check
    }
}

switch ($Task) {
    'build' {
        Ensure-Seeded
        Step 'Building everything (dbt build)'
        & $dbt build --no-version-check
    }
    'fresh' {
        Step 'Deleting dev.duckdb and target/ for a clean start'
        Remove-Item dev.duckdb, dev.duckdb.wal -ErrorAction SilentlyContinue
        Remove-Item target -Recurse -ErrorAction SilentlyContinue
        Ensure-Seeded
        Step 'Building everything (dbt build)'
        & $dbt build --no-version-check
    }
    'show' {
        Step "Showing rows of $Model (dbt show --select $Model)"
        & $dbt show --select $Model --no-version-check
    }
    'test' {
        Step 'Running tests (dbt test)'
        & $dbt test --no-version-check
    }
    'docs' {
        Ensure-Seeded
        Step 'Generating docs (dbt docs generate)'
        & $dbt docs generate --no-version-check
        Step 'Opening docs in your browser. Press Ctrl+C here to stop.'
        & $dbt docs serve --no-version-check
    }
    'help' {
        Write-Host @'
.\run.ps1                 Build everything
.\run.ps1 fresh           Delete the database and rebuild from scratch
.\run.ps1 show            Show the rows of customer_revenue
.\run.ps1 show <model>    Show the rows of any model, e.g. stg_orders
.\run.ps1 test            Run only the tests
.\run.ps1 docs            Build the docs site and open it (Ctrl+C to stop)
'@
    }
}
