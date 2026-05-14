---
name: Server Dashboard
description: สรุปสถานะ server ครบทุกด้าน — IIS, MySQL, Disk, Memory, CPU, Processes
version: 1.1.0
category: server-monitoring
platforms:
  - windows
---

# Server Dashboard Skill

แสดง dashboard ภาพรวมของ server ในครั้งเดียว ประกอบด้วย IIS, MySQL, Disk, Memory, CPU และ processes สำคัญ

## Usage

- "check server" / "สถานะ server" / "ตรวจเซิร์ฟเวอร์"
- "server status" / "dashboard" / "/dashboard"

## Important: Terminal Shell

Hermes terminal ใช้ **bash** บน Windows ต้องเรียก PowerShell ผ่าน `powershell.exe -NonInteractive -Command "..."`

## Dashboard Commands

รันทีละ section แล้วรวม format เป็น markdown report:

### Section 1: System Overview
```bash
powershell.exe -NonInteractive -Command "\$os = Get-CimInstance Win32_OperatingSystem; \$cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average; Write-Output \"Hostname: \$env:COMPUTERNAME\"; Write-Output \"OS: \$(\$os.Caption)\"; Write-Output \"Uptime: \$(([DateTime]::Now - \$os.LastBootUpTime).Days) days\"; Write-Output \"CPU: \$cpu%\"; Write-Output \"RAM Free: \$([math]::Round(\$os.FreePhysicalMemory/1MB,1)) / \$([math]::Round(\$os.TotalVisibleMemorySize/1MB,1)) GB\""
```

### Section 2: Disk Usage
```bash
powershell.exe -NonInteractive -Command "Get-PSDrive -PSProvider FileSystem | Where-Object { \$_.Used -gt 0 } | Select-Object Name, @{n='UsedGB';e={[math]::Round(\$_.Used/1GB,1)}}, @{n='FreeGB';e={[math]::Round(\$_.Free/1GB,1)}}, @{n='Pct';e={[math]::Round(\$_.Used/(\$_.Used+\$_.Free)*100,0)}} | Format-Table -AutoSize"
```

### Section 3: IIS Sites
```bash
powershell.exe -NonInteractive -Command "Import-Module WebAdministration; Get-WebSite | Select-Object Name, State | Format-Table -AutoSize"
```

### Section 4: Key Processes
```bash
powershell.exe -NonInteractive -Command "foreach (\$p in @('mysqld','w3wp','hermes','node','python','php-cgi')) { \$r = Get-Process \$p -ErrorAction SilentlyContinue; if (\$r) { \$m = [math]::Round((\$r | Measure-Object WorkingSet -Sum).Sum/1MB,1); Write-Output \"\$p: \$((\$r|Measure-Object).Count) proc, \$m MB\" } else { Write-Output \"\$p: not running\" } }"
```

### Section 5: Port Summary
```bash
powershell.exe -NonInteractive -Command "foreach (\$port in @(80,443,3306,8080,8001)) { \$c = Get-NetTCPConnection -LocalPort \$port -State Listen -ErrorAction SilentlyContinue; \$label = @{80='IIS HTTP';443='IIS HTTPS';3306='MySQL';8080='Hermes API';8001='vLLM'}[\$port]; if (\$c) { Write-Output \":\$port (\$label) LISTENING\" } else { Write-Output \":\$port (\$label) not listening\" } }"
```

### Section 6: MySQL Quick Check
```bash
powershell.exe -NonInteractive -Command "& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root --execute='SHOW STATUS WHERE Variable_name IN (Uptime,Threads_connected,Questions);' 2>&1"
```

## Output Format

```
# Server Dashboard — [hostname] — [timestamp]

## System
OS: Windows Server 2025
Uptime: X days | CPU: X% | RAM: X.X/X.X GB

## Disk
C: Used X.X GB / Free X.X GB (X%)

## IIS (X sites)
site1: Started | site2: Stopped

## Processes
mysqld: running X MB | w3wp: X instances | hermes: running

## Ports
:80 IIS HTTP LISTENING | :443 IIS HTTPS LISTENING | :3306 MySQL LISTENING | :8080 Hermes API LISTENING
```

## Constraints

- ทุก command เป็น read-only ไม่ restart หรือแก้ไข service ใดๆ
