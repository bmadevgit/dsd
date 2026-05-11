#Requires -RunAsAdministrator
<#
.SYNOPSIS
    ติดตั้ง Hermes Agent บน Windows Server 2025
    AI Gateway: http://100.99.107.27:8000/v1  |  API Server port: 8080
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$HermesData  = "$env:LOCALAPPDATA\hermes"
$ScriptDir   = $PSScriptRoot

function Write-Step { param([string]$msg) Write-Host "`n>>> $msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$msg) Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Fail { param([string]$msg) Write-Host "    [!!] $msg" -ForegroundColor Red }

# ─── 1. Prerequisites ───────────────────────────────────────────────────────

Write-Step "Checking prerequisites"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Fail "Git not found. Install Git from https://git-scm.com/ then re-run."
    exit 1
}
Write-Ok "Git found"

$gw = "100.99.107.27"
$gwPort = 8000
$conn = Test-NetConnection -ComputerName $gw -Port $gwPort -WarningAction SilentlyContinue
if (-not $conn.TcpTestSucceeded) {
    Write-Fail "Cannot reach AI Gateway at ${gw}:${gwPort}. Check network and re-run."
    exit 1
}
Write-Ok "AI Gateway reachable"

# ─── 2. Install Hermes ───────────────────────────────────────────────────────

Write-Step "Installing Hermes Agent (NousResearch)"
Write-Host "    Running official installer..." -ForegroundColor Yellow

try {
    $installScript = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1"
    Invoke-Expression $installScript
} catch {
    Write-Fail "Installer download failed: $_"
    Write-Host "    Retry manually: irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1 | iex"
    exit 1
}

# Reload PATH so hermes binary is found in current session
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
    Write-Fail "hermes command not found after install. Open a new PowerShell and re-run from Step 3."
    exit 1
}
Write-Ok "hermes installed: $(hermes --version 2>&1)"

# ─── 3. Copy config files ────────────────────────────────────────────────────

Write-Step "Copying configuration files"

New-Item -ItemType Directory -Path $HermesData -Force | Out-Null

$cfgDest = "$HermesData\config.yaml"
if (-not (Test-Path $cfgDest)) {
    Copy-Item "$ScriptDir\config.yaml" $cfgDest
    Write-Ok "config.yaml copied to $cfgDest"
} else {
    Write-Host "    [SKIP] config.yaml already exists — not overwriting. Review manually." -ForegroundColor Yellow
}

$envDest = "$HermesData\.env"
if (-not (Test-Path $envDest)) {
    Copy-Item "$ScriptDir\.env.example" $envDest
    Write-Ok ".env created from template at $envDest"
    Write-Host "    Edit $envDest and set HERMES_API_KEY if required." -ForegroundColor Yellow
} else {
    Write-Host "    [SKIP] .env already exists." -ForegroundColor Yellow
}

# ─── 4. Install custom skills ────────────────────────────────────────────────

Write-Step "Installing custom skills"

$skillsDir = "$HermesData\skills"
New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null

foreach ($skill in @("iis-monitor", "mysql-monitor", "server-dashboard")) {
    $src  = "$ScriptDir\skills\$skill\SKILL.md"
    $dest = "$skillsDir\$skill"
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Copy-Item $src "$dest\SKILL.md" -Force
    Write-Ok "Skill installed: $skill"
}

# ─── 5. Install browser-use skill ────────────────────────────────────────────

Write-Step "Installing official browser-use skill"
try {
    hermes skills install official/browser-use 2>&1 | Out-Null
    Write-Ok "browser-use skill installed"
} catch {
    Write-Host "    [WARN] browser-use install failed (non-fatal): $_" -ForegroundColor Yellow
}

# ─── 6. Set up Windows Scheduled Task ────────────────────────────────────────

Write-Step "Setting up Windows Scheduled Task for Hermes Gateway"
& "$ScriptDir\tasks\setup-task.ps1"

# ─── 7. Verify ───────────────────────────────────────────────────────────────

Write-Step "Running hermes doctor"
hermes doctor

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  Hermes Agent installed successfully!" -ForegroundColor Green
Write-Host "  API Server : http://localhost:8080" -ForegroundColor Green
Write-Host "  Config     : $cfgDest" -ForegroundColor Green
Write-Host "  Gateway    : http://100.99.107.27:8000/v1" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit $envDest (set HERMES_API_KEY if needed)"
Write-Host "  2. hermes model   — verify model selection"
Write-Host "  3. hermes -q 'สวัสดี'   — test quick chat"
Write-Host "  4. Install VSCode extension: search 'Hermes AI Agent' by joaompfp"
