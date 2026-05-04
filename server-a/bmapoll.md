# bmapoll — Traffy Bangkok Data Explorer

**Path:** `C:\inetpub\wwwroot\bmapoll`
**Stack:** PHP 8 · MySQL · Tailwind CSS · Google Maps API · Ollama (Typhoon 2.5)
**Tool:** Claude Code

---

## Timeline

- **2026-03-26** — สร้างระบบทั้งหมดในวันเดียว: SPA (`index.php`), API endpoints (`api/index.php`), config, IIS config
- **2026-03-27** — เพิ่ม database layer (`includes/db.php`), ปรับ query + pagination

## Features

- แสดงข้อมูลเรื่องร้องเรียน Traffy Fondue กรุงเทพฯ
- ค้นหาด้วย keyword, วันที่, เขต, ประเภทเรื่อง
- Google Maps แสดง marker สีตามสถานะ
- AI Chat วิเคราะห์ข้อมูล (Typhoon 2.5 via Ollama)
- Export CSV/Excel

## Status

**Production** — deployed ใช้งานจริง
