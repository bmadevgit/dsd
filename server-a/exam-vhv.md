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
