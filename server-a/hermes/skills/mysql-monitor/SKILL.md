---
name: MySQL Monitor
description: ตรวจสอบสถานะ MySQL 8.0 บน Windows Server — connections, uptime, databases (read-only)
version: 1.0.0
category: server-monitoring
platforms:
  - windows
---

# MySQL Monitor Skill

ตรวจสอบสถานะ MySQL server บนเครื่องนี้โดยใช้ read-only queries เท่านั้น ไม่แก้ไข data หรือ schema ใดๆ

## Usage

เรียกใช้ด้วยคำเช่น:
- "check MySQL status"
- "ตรวจ MySQL"
- "how many MySQL connections"
- "show databases"

## MySQL Connection

MySQL รันที่ port 3306 บนเครื่องนี้

```powershell
# ใช้ mysql client (ต้องอยู่ใน PATH หรือระบุ full path)
$mysql = "mysql"   # หรือ "C:\MySQL\bin\mysql.exe"
```

## How to Check MySQL Status

### 1. Server uptime และ basic status
```powershell
& mysql -u root --execute="SHOW STATUS LIKE 'Uptime%'; SHOW STATUS LIKE 'Threads_connected'; SHOW STATUS LIKE 'Questions';" 2>&1
```

### 2. Connection statistics
```powershell
& mysql -u root --execute="SHOW STATUS WHERE Variable_name IN ('Threads_connected','Max_used_connections','Connection_errors_total','Aborted_connects');" 2>&1
```

### 3. List databases and sizes
```powershell
& mysql -u root --execute="SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.TABLES GROUP BY table_schema ORDER BY 2 DESC;" 2>&1
```

### 4. Active processes (running queries)
```powershell
& mysql -u root --execute="SHOW FULL PROCESSLIST;" 2>&1
```

### 5. Slow query count
```powershell
& mysql -u root --execute="SHOW STATUS LIKE 'Slow_queries';" 2>&1
```

### 6. Check if MySQL process is running (PowerShell fallback if no CLI access)
```powershell
Get-Process mysqld -ErrorAction SilentlyContinue | Select-Object Id, CPU, WorkingSet | Format-Table -AutoSize
```

## Output Format

แสดงผลเป็น markdown:
- Uptime: X hours
- Active connections: N / max N
- Databases: รายชื่อ + ขนาด
- Slow queries: N
- Warning ถ้า connections > 80% ของ max

## Constraints

- ใช้เฉพาะ SELECT, SHOW, EXPLAIN (read-only)
- ห้าม INSERT, UPDATE, DELETE, DROP, ALTER, CREATE
- ห้ามแก้ไข user permissions หรือ configuration
