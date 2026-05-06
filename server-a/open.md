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

---

## Recent Activity

_auto-updated 

### Files changed recently

- `PROJECT_HANDOFF.md` 2026-04-14 21:05
- `admin\index.php` 2026-04-11 13:48
- `config\config.php` 2026-04-11 13:33
- `index.php` 2026-04-11 13:09
- `UAT_TEST_DOCUMENT.md` 2026-04-11 13:06
- `sql\get_sample_cases.php` 2026-04-11 13:05
- `web.config` 2026-04-11 13:02
- `sql\schema.sql` 2026-04-11 13:01
