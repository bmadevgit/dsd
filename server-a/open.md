# open — Hospital Case Management Portal

**Path:** `C:\inetpub\wwwroot\open`
**Stack:** PHP 8 · MySQL · Qwen2.5-32B (OpenAI-compatible API)
**Tool:** Claude Code

---

## Timeline

- **2026-04-11** — สร้างระบบทั้งหมด: public search portal, admin dashboard, database schema (`sql/schema.sql`), install tool
- **2026-04-14** — finalize + handoff (`PROJECT_HANDOFF.md`, `UAT_TEST_DOCUMENT.md`)

## Features

- ค้นหาสถานะเคส/ใบแจ้งหนี้ด้วยเลขใบแจ้งหนี้ + เลขอ้างอิง + เลขนิติบุคคล
- Payment status: unpaid / partial / paid
- Document status: pending / review / approved / rejected
- Timeline view การเปลี่ยนแปลงสถานะ
- Admin dashboard: CRUD เคส, KPI, AI วิเคราะห์ด้วย Qwen2.5-32B
- MIS integration placeholder
- Multi-role: admin, hospital staff

## Status

**Completed & Handed off** — ส่งมอบ 2026-04-14

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\open`
- Stack: PHP
- Entry points: index.php
- Config files: web.config
- DB hints: (none)

### Recent Files

- `PROJECT_HANDOFF.md` 2026-04-14 21:05
- `admin\index.php` 2026-04-11 13:48
- `config\config.php` 2026-04-11 13:33
- `index.php` 2026-04-11 13:09
- `UAT_TEST_DOCUMENT.md` 2026-04-11 13:06
- `sql\get_sample_cases.php` 2026-04-11 13:05
- `web.config` 2026-04-11 13:02
- `sql\schema.sql` 2026-04-11 13:01
- `install.php` 2026-04-11 12:55
- `assets\style.css` 2026-04-11 12:47

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

<!-- AUTO_SECTION_END -->
