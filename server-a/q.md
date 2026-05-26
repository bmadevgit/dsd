# q — ระบบจองคิวแรงงานต่างด้าว + Email

**Path:** `C:\inetpub\wwwroot\q`
**Stack:** PHP (legacy) · MySQL · PHPMailer · TCPDF · PHP_XLSXWriter · Bootstrap 3
**Tool:** —

---

## Timeline

- **2021-02-22** — เริ่มโปรเจกต์ สร้าง core PHP/MySQL, Bootstrap framework
- **2021-04-01** — เพิ่ม report features (`report.php`)
- **2022-02-24** — เพิ่ม PHPMailer (ส่ง email อัตโนมัติ)
- **2023-10-04** — เพิ่ม utility tools
- **2024-10-12** — อัปเดต image assets
- **2025-12-08** — maintenance, config updates
- **2026-04-29** — อัปเดต `index.php`, `locale.php` ล่าสุด

## Features

- จองคิวแรงงานต่างด้าว 3 สัญชาติ (พม่า, ลาว, กัมพูชา)
- Form submission + validation
- ส่ง email อัตโนมัติ (PHPMailer)
- Export CSV, Excel (XLSXWriter), PDF report (TCPDF)
- รองรับภาษาไทย
- บันทึก WiFi registration, CPD credential tracking

## Status

**Active (maintenance mode)** — ระบบเก่า ใช้งานจริง อยู่ระหว่าง maintain

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\q`
- Stack: PHP
- Entry points: index.php
- Config files: config.php
- DB hints: (none)

### Recent Files

- `x.php` 2026-05-01 16:32
- `locale.php` 2026-04-29 09:25
- `index.php` 2026-04-29 09:23
- `validate_add.php` 2026-04-28 16:04
- `config.php` 2025-12-08 08:30
- `note4.pdf` 2025-02-11 17:15
- `646483.jpg` 2025-02-06 17:16
- `646482.jpg` 2025-02-06 17:16
- `646481.jpg` 2025-02-06 17:16
- `note3.jpg` 2024-11-03 20:19

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

<!-- AUTO_SECTION_END -->
