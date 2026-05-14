---
name: MySQL Monitor
description: ตรวจสอบสถานะ MySQL 8.0 บน Windows Server — connections, uptime, databases (read-only)
version: 1.1.0
category: server-monitoring
platforms:
  - windows
---

# MySQL Monitor Skill

ตรวจสอบสถานะ MySQL server บนเครื่องนี้ โดยใช้ read-only queries เท่านั้น

## Usage

- "check MySQL status" / "ตรวจ MySQL"
- "how many MySQL connections"
- "show databases"

## Important: Terminal Shell

Hermes terminal ใช้ **bash** บน Windows ต้องเรียก PowerShell ผ่าน `powershell.exe -NonInteractive -Command "..."`

MySQL executable อยู่ที่: `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`

## How to Check MySQL Status

### 1. Server uptime และ basic status
```bash
powershell.exe -NonInteractive -Command "& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root --execute='SHOW STATUS LIKE Uptime%; SHOW STATUS LIKE Threads_connected;' 2>&1"
```

### 2. Connection statistics
```bash
powershell.exe -NonInteractive -Command "& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root --execute='SHOW STATUS WHERE Variable_name IN (Threads_connected,Max_used_connections,Aborted_connects);' 2>&1"
```

### 3. List databases and sizes
```bash
powershell.exe -NonInteractive -Command "& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root --execute='SELECT table_schema AS DB, ROUND(SUM(data_length+index_length)/1024/1024,2) AS MB FROM information_schema.TABLES GROUP BY table_schema ORDER BY 2 DESC;' 2>&1"
```

### 4. Active processes
```bash
powershell.exe -NonInteractive -Command "& 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe' -u root --execute='SHOW FULL PROCESSLIST;' 2>&1"
```

### 5. Check MySQL process (fallback ถ้า CLI ไม่ work)
```bash
powershell.exe -NonInteractive -Command "Get-Process mysqld -ErrorAction SilentlyContinue | Select-Object Id, CPU, WorkingSet | Format-Table -AutoSize"
```

## Constraints

- ใช้เฉพาะ SELECT, SHOW, EXPLAIN (read-only)
- ห้าม INSERT, UPDATE, DELETE, DROP, ALTER, CREATE
- ห้ามแก้ไข user permissions หรือ configuration
