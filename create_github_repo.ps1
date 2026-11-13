# create_github_repo.ps1 – upload du projet sur GitHub (sans git CLI)
# Nécessite $env:GITHUB_TOKEN (scope repo)

param(
    [string]$RepoName = "project_setup",
    [string]$Owner    = "$(whoami)"   # à remplacer par votre login GitHub si besoin
)

# Vérifier le token
if (-not $env:GITHUB_TOKEN) {
    Write-Error "GITHUB_TOKEN environment variable not set."
    exit 1
}
$token = $env:GITHUB_TOKEN

function Invoke-GitHubApi {
    param([string]$Method, [string]$Uri, [hashtable]$Body = $null)
    $headers = @{ Authorization = "token $token"; Accept = "application/vnd.github+json" }
    $json = if ($Body) { $Body | ConvertTo-Json -Depth 10 } else { $null }
    Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -Body $json -ContentType "application/json"
}

# ---- 1️⃣ Créer le dépôt (ou passer s’il existe) ----
$createUri  = "https://api.github.com/user/repos"
$createBody = @{ name = $RepoName; private = $false }

try {
    $repo = Invoke-GitHubApi -Method POST -Uri $createUri -Body $createBody
    Write-Host "Repository created: $($repo.html_url)" -ForegroundColor Green
} catch {
    Write-Host "Repository probably already exists – proceeding with upload…" -ForegroundColor Yellow
    $repo = @{ html_url = "https://github.com/$Owner/$RepoName" }
}

# ---- 2️⃣ Upload de tous les fichiers sur la branche main ----
function Upload-File {
    param([string]$FilePath)
    $relativePath = $FilePath.Substring((Get-Location).Path.Length + 1).Replace('\\','/')
    $content = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FilePath))
    $uri = "https://api.github.com/repos/$Owner/$RepoName/contents/$relativePath"
    $body = @{ message = "add $relativePath"; content = $content; branch = "main" }
    try {
        Invoke-GitHubApi -Method PUT -Uri $uri -Body $body | Out-Null
        Write-Host "Uploaded $relativePath" -ForegroundColor DarkGray
    } catch {
        Write-Warning "Failed to upload ${relativePath}: $_"
    }
}

Get-ChildItem -Recurse -File | ForEach-Object { Upload-File $_.FullName }

Write-Host "All files uploaded. Remote repo ready at $($repo.html_url)" -ForegroundColor Green
Write-Host "GitHub Actions will run automatically on the initial commit." -ForegroundColor Cyan
