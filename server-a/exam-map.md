# exam/map — Pin Survey & Location Mapping

**Path:** `C:\inetpub\wwwroot\exam\map`
**Stack:** PHP · MySQL · Google Maps API · AI URL parser
**Tool:** Claude Code

---

## Timeline

- **2026-04-11** — สร้าง core: config, database schema (`sql/schema.sql`), install tool, Google Sheet importer
- **2026-04-12** — UI สมบูรณ์, API endpoints (`api/import_sheet.php`), admin dashboard
- **2026-04-13** — Updates ล่าสุด

## Features

- แผนที่ปักหมุด community-based สำหรับสำรวจพื้นที่
- Import location จาก Google Sheet อัตโนมัติ
- AI-powered URL parser แยก lat/lng จาก URL ต่าง ๆ
- Admin interface ระดับเขต (district-level access)
- Needs_review workflow สำหรับตรวจสอบข้อมูล
- ปักหมุด GPS manual ได้

## Status

**Production** — deployed ใช้งานจริง

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\exam\map`
- Stack: PHP
- Entry points: index.php
- Config files: README.md
- DB hints: (none)

### Recent Files

- `admin\index.php` 2026-04-12 13:21
- `admin\login.php` 2026-04-12 13:16
- `config\config.php` 2026-04-12 13:15
- `admin\thai-fix.js` 2026-04-12 09:43
- `README.md` 2026-04-12 09:28
- `api\import_sheet.php` 2026-04-12 09:21
- `includes\bootstrap.php` 2026-04-12 09:20
- `includes\auth.php` 2026-04-12 09:20
- `index.php` 2026-04-11 17:29
- `tools\stats_cli.php` 2026-04-11 17:14

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

<!-- AUTO_SECTION_END -->
