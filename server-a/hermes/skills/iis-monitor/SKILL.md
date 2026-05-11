---
name: IIS Monitor
description: ตรวจสอบสถานะ IIS sites และ Application Pools บน Windows Server (read-only)
version: 1.0.0
category: server-monitoring
platforms:
  - windows
---

# IIS Monitor Skill

ตรวจสอบสถานะ IIS sites, Application Pools และ error log บน server นี้โดยไม่แก้ไข configuration ใดๆ

## Usage

เรียกใช้ด้วยคำเช่น:
- "check IIS status"
- "ตรวจ IIS"
- "which sites are running"
- "show IIS application pools"

## How to Check IIS Status

รัน PowerShell commands ต่อไปนี้ (read-only ทั้งหมด):

### 1. List all sites and state
```powershell
Import-Module WebAdministration
Get-WebSite | Select-Object Name, State, PhysicalPath, @{n='Bindings';e={$_.Bindings.Collection | ForEach-Object {"$($_.Protocol)://$($_.BindingInformation)"}}} | Format-Table -AutoSize
```

### 2. List Application Pools and state
```powershell
Import-Module WebAdministration
Get-WebConfiguration system.applicationHost/applicationPools/add | Select-Object name, state, managedRuntimeVersion, enable32BitAppOnWin64 | Format-Table -AutoSize
```

### 3. Check for stopped sites
```powershell
Import-Module WebAdministration
$stopped = Get-WebSite | Where-Object { $_.State -ne 'Started' }
if ($stopped) { $stopped | Select-Object Name, State | Format-Table } else { Write-Output "All sites are running." }
```

### 4. Check recent IIS error logs (last 20 lines)
```powershell
$logPath = "C:\inetpub\logs\LogFiles"
$latestLog = Get-ChildItem -Path $logPath -Recurse -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestLog) { Get-Content $latestLog.FullName -Tail 20 } else { Write-Output "No log files found." }
```

### 5. Check worker processes (w3wp.exe)
```powershell
Get-Process w3wp -ErrorAction SilentlyContinue | Select-Object Id, CPU, WorkingSet, @{n='AppPool';e={(Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").CommandLine}} | Format-Table -AutoSize
```

## Output Format

แสดงผลเป็น markdown table:
- Site Name | State | Bindings
- App Pool | State | Runtime
- Summary: X sites running, Y stopped

## Constraints

- ห้าม Start/Stop/Restart site หรือ app pool ใดๆ
- ห้ามแก้ไข IIS configuration (web.config, applicationHost.config)
- อ่านข้อมูลอย่างเดียว (read-only)
