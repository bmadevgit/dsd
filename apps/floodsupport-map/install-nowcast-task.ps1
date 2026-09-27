$ErrorActionPreference = 'Stop'
$taskName = 'BMA Nowcast 15 Minute Sync'
$appDir = 'C:\inetpub\apps\floodsupport-map'
$action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument "-NoProfile -NonInteractive -File `"$appDir\sync-nowcast.ps1`"" -WorkingDirectory $appDir
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 15)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 3) -MultipleInstances IgnoreNew
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -User 'SYSTEM' -RunLevel Highest -Description 'Refresh Bangkok district nowcast for now.bangkok.go.th every 15 minutes' -Force | Out-Null
Get-ScheduledTask -TaskName $taskName | Select-Object TaskName, State
