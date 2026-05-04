# now — Digital Bureau Task Tracker + Archive

**Path:** `C:\inetpub\wwwroot\now`
**Stack:** React 19 · Vite · Tailwind CSS · PHP backend · JSON storage
**Tool:** Claude Code / Codex

---

## Timeline

- **2026-01-02** — เริ่มระบบ task tracking สำหรับสำนักดิจิทัล BMA
- **2026-02-20** — เริ่มสร้าง archive exports (RAR)
- **2026-03-05** — export ใหญ่เสร็จ: `car.rar` (14 GB), `org.rar` (5 GB), `dumps.rar` (934 MB)
- **2026-03-19** — อัปเดตล่าสุด

## Features

- Task management สำหรับสำนักดิจิทัล BMA
- เก็บข้อมูลใน `tasks_data.json` (77 KB)
- ระบบ archive: export ข้อมูลเป็น RAR สำหรับ backup/migration
  - `car.rar` (14 GB) — ข้อมูลยานพาหนะ
  - `org.rar` (5 GB) — ข้อมูลองค์กร
  - `dumps.rar` (934 MB) — database dumps

## Status

**Archive/Light use** — ใช้เป็น file server และ task tracker ของทีม
