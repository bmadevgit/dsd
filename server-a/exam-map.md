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
