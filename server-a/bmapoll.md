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

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\bmapoll`
- Stack: PHP
- Entry points: index.php
- Config files: web.config, README.md
- DB hints: mysql/pdo

### Recent Files

- `index.php` 2026-03-27 07:03
- `includes\db.php` 2026-03-27 06:38
- `web.config` 2026-03-26 22:18
- `api\index.php` 2026-03-26 21:53
- `includes\config.php` 2026-03-26 17:37
- `README.md` 2026-03-26 17:04

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

<!-- AUTO_SECTION_END -->
