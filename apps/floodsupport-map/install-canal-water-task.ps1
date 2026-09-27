$ErrorActionPreference = 'Stop'
$taskName = 'BMA Canal Water 5 Minute Sync'
$appDir = 'C:\inetpub\apps\floodsupport-map'
$action = New-ScheduledTaskAction -Execute "$appDir\.venv\Scripts\python.exe" -Argument "$appDir\canal_water_daemon.py" -WorkingDirectory $appDir
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -User 'SYSTEM' -RunLevel Highest -Description 'Continuously refresh public Bangkok canal water-level snapshot every five minutes' -Force | Out-Null
Start-ScheduledTask -TaskName $taskName
Get-ScheduledTask -TaskName $taskName | Select-Object TaskName, State
