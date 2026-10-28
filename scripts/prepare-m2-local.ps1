# Local-only test setup; no keys are printed by the Python helper.
$ErrorActionPreference = 'Stop'
python scripts/prepare_m2_local.py
if ($LASTEXITCODE -ne 0) { throw 'Local Supabase test setup failed. Check stack readiness.' }
