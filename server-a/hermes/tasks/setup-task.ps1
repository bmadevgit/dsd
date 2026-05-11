#Requires -RunAsAdministrator
<#
.SYNOPSIS
    สร้าง Windows Scheduled Task สำหรับ Hermes Gateway (port 8080)
    Task จะ start อัตโนมัติตอน system boot และ restart ถ้า crash
#>

$TaskName   = "Hermes Gateway"
$TaskDesc   = "Hermes Agent gateway service — API port 8080 (NousResearch)"
$BatFile    = "$PSScriptRoot\hermes-gateway.bat"
$HermesPath = (Get-Command hermes -ErrorAction SilentlyContinue)?.Source

if (-not (Test-Path $BatFile)) {
    Write-Error "hermes-gateway.bat not found at $BatFile"
    exit 1
}

# Remove old task if exists
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Removed existing task '$TaskName'"
}

$action  = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$BatFile`""
$trigger = @(
    New-ScheduledTaskTrigger -AtStartup,
    New-ScheduledTaskTrigger -AtLogOn -User "Administrator"
)
$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -RestartCount 5 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -StartWhenAvailable

$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

Register-ScheduledTask `
    -TaskName  $TaskName `
    -Action    $action `
    -Trigger   $trigger `
    -Settings  $settings `
    -Principal $principal `
    -Description $TaskDesc | Out-Null

Write-Host "[OK] Scheduled Task '$TaskName' created." -ForegroundColor Green
Write-Host "     Trigger : At startup + At logon (Administrator)"
Write-Host "     Restart : up to 5 times with 1-min interval"

# Start immediately
Start-ScheduledTask -TaskName $TaskName
Write-Host "[OK] Task started — Hermes Gateway running on port 8080" -ForegroundColor Green
