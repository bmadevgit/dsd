---
name: IIS Monitor
description: ตรวจสอบสถานะ IIS sites และ Application Pools บน Windows Server (read-only)
version: 1.1.0
category: server-monitoring
platforms:
  - windows
---

# IIS Monitor Skill

ตรวจสอบสถานะ IIS sites, Application Pools บน server นี้ โดยไม่แก้ไข configuration ใดๆ

## Usage

- "check IIS status" / "ตรวจ IIS"
- "which sites are running"
- "show IIS application pools"

## Important: Terminal Shell

Hermes terminal ใช้ **bash** บน Windows ต้องเรียก PowerShell ผ่าน `powershell.exe -NonInteractive -Command "..."`

## How to Check IIS Status

### 1. List all sites and state
```bash
powershell.exe -NonInteractive -Command "Import-Module WebAdministration; Get-WebSite | Select-Object Name, State, PhysicalPath | Format-Table -AutoSize"
```

### 2. List Application Pools
```bash
powershell.exe -NonInteractive -Command "Import-Module WebAdministration; Get-WebConfiguration system.applicationHost/applicationPools/add | Select-Object name, state | Format-Table -AutoSize"
```

### 3. Stopped sites only
```bash
powershell.exe -NonInteractive -Command "Import-Module WebAdministration; \$s = Get-WebSite | Where-Object { \$_.State -ne 'Started' }; if (\$s) { \$s | Format-Table Name, State } else { 'All sites running.' }"
```

### 4. Recent IIS errors (last 20 lines)
```bash
powershell.exe -NonInteractive -Command "\$f = Get-ChildItem C:\\inetpub\\logs\\LogFiles -Recurse -Filter '*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 1; if (\$f) { Get-Content \$f.FullName -Tail 20 }"
```

### 5. Worker processes
```bash
powershell.exe -NonInteractive -Command "Get-Process w3wp -ErrorAction SilentlyContinue | Select-Object Id, CPU, WorkingSet | Format-Table -AutoSize"
```

## Constraints

- ห้าม Start/Stop/Restart site หรือ app pool
- ห้ามแก้ไข IIS configuration
- อ่านข้อมูลอย่างเดียว (read-only)
