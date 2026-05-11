#Requires -RunAsAdministrator
<#
.SYNOPSIS
    หยุดและลบ Hermes Gateway Scheduled Task
#>

$TaskName = "Hermes Gateway"

$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if (-not $task) {
    Write-Host "Task '$TaskName' not found — nothing to remove." -ForegroundColor Yellow
    exit 0
}

# Stop if running
if ($task.State -eq "Running") {
    Stop-ScheduledTask -TaskName $TaskName
    Write-Host "Stopped task '$TaskName'"
}

# Kill any remaining hermes gateway process
Get-Process -Name "hermes" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "Stopped hermes processes"

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
Write-Host "[OK] Task '$TaskName' removed." -ForegroundColor Green
