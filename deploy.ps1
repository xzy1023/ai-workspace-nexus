# deploy.ps1 - Automated Antigravity Native Config Deployer
# Usage: .\deploy.ps1

$ErrorActionPreference = "Stop"

$GEMINI_ROOT = "$env:USERPROFILE\.gemini"
$CONFIG_ROOT = "$GEMINI_ROOT\config"
$SKILLS_TARGET = "$CONFIG_ROOT\skills"
$HOOKS_TARGET = "$CONFIG_ROOT\hooks"
$HOOKS_JSON_TARGET = "$CONFIG_ROOT\hooks.json"
$GEMINI_MD_TARGET = "$GEMINI_ROOT\GEMINI.md"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Deploying Antigravity Native Configuration" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Ensure Target Folders Exist
Write-Host "[1/5] Creating config directories..." -ForegroundColor Yellow
$null = New-Item -ItemType Directory -Force -Path $SKILLS_TARGET
$null = New-Item -ItemType Directory -Force -Path $HOOKS_TARGET

# 2. Deploy Skills
Write-Host "[2/5] Deploying skills to $SKILLS_TARGET..." -ForegroundColor Yellow
if (Test-Path "$SKILLS_TARGET\*") {
    Remove-Item -Path "$SKILLS_TARGET\*" -Recurse -Force -ErrorAction SilentlyContinue
}
Copy-Item -Path "skills\*" -Destination $SKILLS_TARGET -Recurse -Force
Write-Host "  Skills synced successfully." -ForegroundColor Green

# 3. Deploy Rules (GEMINI.md)
Write-Host "[3/5] Deploying GEMINI.md to $GEMINI_MD_TARGET..." -ForegroundColor Yellow
if (Test-Path "GEMINI.md") {
    Copy-Item -Path "GEMINI.md" -Destination $GEMINI_MD_TARGET -Force
    Write-Host "  GEMINI.md deployed successfully." -ForegroundColor Green
} else {
    Write-Warning "GEMINI.md not found in repository."
}

# 4. Deploy Hooks & Rewrite hooks.json
Write-Host "[4/5] Deploying hooks to $HOOKS_TARGET..." -ForegroundColor Yellow
if (Test-Path "$HOOKS_TARGET\*") {
    Remove-Item -Path "$HOOKS_TARGET\*" -Recurse -Force -ErrorAction SilentlyContinue
}
Copy-Item -Path "hooks\*" -Destination $HOOKS_TARGET -Recurse -Force

Write-Host "  Configuring hooks.json..." -ForegroundColor Yellow
if (Test-Path "hooks.json") {
    $HooksJsonRaw = Get-Content -Raw -Encoding UTF8 -Path "hooks.json"
    
    # Generate the absolute path to run-hook.cmd with forward slashes
    $AbsHookCmd = "$HOOKS_TARGET\run-hook.cmd" -replace '\\', '/'
    
    # Replace relative command "./hooks/run-hook.cmd" with absolute path
    $HooksJsonUpdated = $HooksJsonRaw -replace '\./hooks/run-hook.cmd', $AbsHookCmd
    
    [System.IO.File]::WriteAllText($HOOKS_JSON_TARGET, $HooksJsonUpdated, [System.Text.Encoding]::UTF8)
    Write-Host "  Hooks configured successfully with absolute path: $AbsHookCmd" -ForegroundColor Green
} else {
    Write-Warning "hooks.json not found in repository."
}

# 5. Cleanup Obsolete Plugins Directory
Write-Host "[5/5] Cleaning up obsolete custom plugins directory..." -ForegroundColor Yellow
$PluginsPath = "$CONFIG_ROOT\plugins"
if (Test-Path $PluginsPath) {
    Remove-Item -Path $PluginsPath -Recurse -Force
    Write-Host "  Obsolete plugins folder deleted." -ForegroundColor Green
} else {
    Write-Host "  No obsolete plugins folder found. Skipping." -ForegroundColor DarkGreen
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Deployment completed successfully!" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
