# Check Red-Team checklist and fail if any item is unchecked
# This script reads redteam_checklist.md and looks for a line containing the unchecked box (❌).
# If any unchecked items are found, it exits with code 1 to block CI.

$checklistPath = "..\redteam_checklist.md"
if (-Not (Test-Path $checklistPath)) {
    Write-Error "Red-Team checklist not found at $checklistPath"
    exit 1
}

$unlocked = Select-String -Path $checklistPath -Pattern "❌"
if ($unlocked) {
    Write-Host "Red-Team checklist has unchecked items:" -ForegroundColor Red
    $unlocked.Line
    exit 1
} else {
    Write-Host "All Red-Team items are checked. ✅" -ForegroundColor Green
    exit 0
}
