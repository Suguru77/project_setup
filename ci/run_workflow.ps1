# --------------------------------------------------------------
# run_workflow.ps1 – Full CI orchestrator for the project setup
# --------------------------------------------------------------
# 1️⃣ Add artefacts to snapshot_guard (replaces git)
$guard = "C:\Users\Audrey\.gemini\antigravity\scratch\tooling\snapshot_guard.py"
$files = @(
    "..\\utf8_bootstrap.py",
    "..\\redteam_checklist.md",
    "..\\process_guard.py",
    "..\\demo_app.py"
)
Write-Host "Adding artefacts to snapshot_guard..." -ForegroundColor Cyan
python $guard --create "Initial project‑setup commit"
if ($LASTEXITCODE -ne 0) {
    Write-Error "snapshot_guard add failed – aborting workflow"
    exit 1
}

# 2️⃣ Run Red‑Team checklist validation
Write-Host "\n=== Red‑Team checklist validation ===\n" -ForegroundColor Cyan
& ".\\check_redteam.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Red‑Team validation failed – aborting workflow"
    exit 1
}

# 3️⃣ Show snapshot_guard status
Write-Host "\n=== Snapshot‑Guard status ===\n" -ForegroundColor Cyan
python $guard --list

Write-Host "`nWorkflow completed successfully - project ready-to-commit!" -ForegroundColor Green
exit 0
