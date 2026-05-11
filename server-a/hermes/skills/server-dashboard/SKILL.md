---
name: Server Dashboard
description: สรุปสถานะ server ครบทุกด้าน — IIS, MySQL, Disk, Memory, CPU, Processes
version: 1.0.0
category: server-monitoring
platforms:
  - windows
---

# Server Dashboard Skill

แสดง dashboard ภาพรวมของ server ในครั้งเดียว ประกอบด้วย IIS, MySQL, Disk, Memory, CPU และ processes สำคัญ

## Usage

เรียกใช้ด้วยคำเช่น:
- "check server"
- "server status"
- "dashboard"
- "/dashboard"
- "สถานะ server"
- "ตรวจเซิร์ฟเวอร์"

## Dashboard Sections

รัน PowerShell commands ต่อไปนี้และ format เป็น markdown report:

### Section 1: System Overview
```powershell
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average
[PSCustomObject]@{
    Hostname    = $env:COMPUTERNAME
    OS          = $os.Caption
    Uptime      = (Get-Date) - $os.LastBootUpTime | Select-Object -ExpandProperty Days | ForEach-Object { "$_ days" }
    CPU_Pct     = "$($cpu.Average)%"
    RAM_Free_GB = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    RAM_Total_GB= [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
} | Format-List
```

### Section 2: Disk Usage
```powershell
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } |
    Select-Object Name,
        @{n='Used GB';e={[math]::Round($_.Used/1GB,1)}},
        @{n='Free GB';e={[math]::Round($_.Free/1GB,1)}},
        @{n='Total GB';e={[math]::Round(($_.Used+$_.Free)/1GB,1)}},
        @{n='Used %';e={[math]::Round($_.Used/($_.Used+$_.Free)*100,0)}} |
    Format-Table -AutoSize
```

### Section 3: IIS Sites
```powershell
Import-Module WebAdministration -ErrorAction SilentlyContinue
Get-WebSite | Select-Object Name, State,
    @{n='Bindings';e={($_.Bindings.Collection | Select-Object -First 1 -ExpandProperty BindingInformation)}} |
    Format-Table -AutoSize
```

### Section 4: Key Processes
```powershell
$procs = @("mysqld","w3wp","hermes","node","python","php-cgi")
foreach ($p in $procs) {
    $r = Get-Process $p -ErrorAction SilentlyContinue
    if ($r) {
        $count = ($r | Measure-Object).Count
        $mem   = [math]::Round(($r | Measure-Object WorkingSet -Sum).Sum / 1MB, 1)
        Write-Output "${p}: ${count} process(es), ${mem} MB RAM"
    } else {
        Write-Output "${p}: not running"
    }
}
```

### Section 5: Port Summary (key services)
```powershell
$ports = @(80, 443, 3306, 8080, 11434, 8000)
foreach ($port in $ports) {
    $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    $label = switch ($port) {
        80     { "IIS HTTP" }; 443   { "IIS HTTPS" }; 3306  { "MySQL" }
        8080   { "Hermes API" }; 11434 { "Ollama" }; 8000  { "AI Gateway" }
        default { "Unknown" }
    }
    if ($conn) { Write-Output "  :${port} ($label) — LISTENING" }
    else        { Write-Output "  :${port} ($label) — not listening" }
}
```

## Output Format

```
# Server Dashboard — [hostname] — [timestamp]

## System
| Metric  | Value |
|---------|-------|
| OS      | ...   |
| Uptime  | X days |
| CPU     | X%    |
| RAM     | X.X / X.X GB |

## Disk
| Drive | Used GB | Free GB | Used % |
...

## IIS Sites (X running)
| Site | State | Binding |
...

## Services
- mysqld: running (X MB)
- w3wp: X instances (X MB)
- hermes: running (X MB)

## Ports
- :80 IIS HTTP — LISTENING
- :8080 Hermes API — LISTENING
...
```

## Constraints

- ทุก command เป็น read-only
- ไม่ restart หรือแก้ไข service ใดๆ
- รายงานข้อมูลเท่านั้น ไม่ดำเนินการแก้ไข
