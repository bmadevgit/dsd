# exam/vhv — ระบบจัดการอาสาสมัครสาธารณสุข (อสส.)

**Path:** `C:\inetpub\wwwroot\exam\vhv`
**Stack:** PHP 8 · MySQL 8 · Bootstrap 5 · Chart.js · jQuery · Composer
**Tool:** Claude Code

---

## Timeline

- **2026-03-27** — เริ่มโปรเจกต์: README, config, database structure (`database/schema.sql`)
- **2026-03-27 – 2026-04-03** — core framework: Controllers structure, auth system, database setup
- **2026-04-02 – 2026-04-09** — feature development: templates ทั้งหมด (auth, home, ecard, profile, reports, dashboard, chat, admin), CSS styling
- **2026-04-09** — refinement: script utilities, mobile-friendly adjustments
- **2026-05-04** — maintenance ล่าสุด

## Features

- ฐานข้อมูล อสส. กรุงเทพฯ พร้อม CRUD
- บทบาท 4 ระดับ: Admin · Nurse · Center Staff · VHV
- E-Card ดิจิทัลพร้อม QR Code (flipcard animation)
- ส่งรายงานสุขภาพประจำเดือน (mobile-friendly)
- Dashboard สถิติด้วย Chart.js
- AI Chat ค้นหาข้อมูลด้วยภาษาธรรมชาติ
- Import Excel, role-based access

## Status

**Active development** — ใช้งานจริง ยังพัฒนาต่อ

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\exam\vhv`
- Stack: PHP
- Entry points: index.php
- Config files: web.config, README.md
- DB hints: mysql/pdo

### Recent Files

- `templates\layouts\main.php` 2026-05-20 10:37
- `templates\admin\security_dashboard.php` 2026-05-20 10:37
- `src\Controllers\SecurityController.php` 2026-05-20 10:36
- `src\Controllers\ChatController.php` 2026-05-20 10:35
- `src\Controllers\AuthController.php` 2026-05-20 10:35
- `index.php` 2026-05-20 10:35
- `config\app.php` 2026-04-09 09:41
- `src\Auth.php` 2026-04-09 09:40
- `scripts\test_query.php` 2026-04-09 09:27
- `scripts\test_chat.php` 2026-04-09 09:24

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

<!-- AUTO_SECTION_END -->
