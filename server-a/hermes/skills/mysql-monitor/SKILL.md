---
name: MySQL Monitor
description: เธ•เธฃเธงเธเธชเธญเธเธชเธ–เธฒเธเธฐ MySQL 8.0 เธเธ Windows Server โ€” connections, uptime, databases (read-only)
version: 1.0.0
category: server-monitoring
platforms:
  - windows
---

# MySQL Monitor Skill

เธ•เธฃเธงเธเธชเธญเธเธชเธ–เธฒเธเธฐ MySQL server เธเธเน€เธเธฃเธทเนเธญเธเธเธตเนเนเธ”เธขเนเธเน read-only queries เน€เธ—เนเธฒเธเธฑเนเธ เนเธกเนเนเธเนเนเธ data เธซเธฃเธทเธญ schema เนเธ”เน

## Usage

เน€เธฃเธตเธขเธเนเธเนเธ”เนเธงเธขเธเธณเน€เธเนเธ:
- "check MySQL status"
- "เธ•เธฃเธงเธ MySQL"
- "how many MySQL connections"
- "show databases"

## MySQL Connection

MySQL เธฃเธฑเธเธ—เธตเน port 3306 เธเธเน€เธเธฃเธทเนเธญเธเธเธตเน

```powershell
# เนเธเน mysql client (เธ•เนเธญเธเธญเธขเธนเนเนเธ PATH เธซเธฃเธทเธญเธฃเธฐเธเธธ full path)
$mysql = "mysql"   # เธซเธฃเธทเธญ "C:\MySQL\bin\mysql.exe"
```

## How to Check MySQL Status

### 1. Server uptime เนเธฅเธฐ basic status
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

เนเธชเธ”เธเธเธฅเน€เธเนเธ markdown:
- Uptime: X hours
- Active connections: N / max N
- Databases: เธฃเธฒเธขเธเธทเนเธญ + เธเธเธฒเธ”
- Slow queries: N
- Warning เธ–เนเธฒ connections > 80% เธเธญเธ max

## Constraints

- เนเธเนเน€เธเธเธฒเธฐ SELECT, SHOW, EXPLAIN (read-only)
- เธซเนเธฒเธก INSERT, UPDATE, DELETE, DROP, ALTER, CREATE
- เธซเนเธฒเธกเนเธเนเนเธ user permissions เธซเธฃเธทเธญ configuration

