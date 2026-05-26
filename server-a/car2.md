# car2 — ระบบบริหารจัดการยานพาหนะ BMA

**Path:** `C:\inetpub\wwwroot\car2`
**Stack:** PHP 8 · MySQL · PHPSpreadsheet · PHPWord
**Tool:** Claude Code

---

## Timeline

- **2026-03-16** — เริ่มโปรเจกต์, ติดตั้ง Composer dependencies (PHPSpreadsheet, PHPWord), สร้าง project structure
- **2026-03-16 – 2026-03-27** — พัฒนา core system: ระบบยืมรถ (`borrow.php`, `borrow_list.php`, `borrow_action.php`), ติดตามซ่อมรถ (`car_repair.php`), ติดตามน้ำมัน (`car_oil.php`), รายงาน mileage
- **2026-03-20** — เพิ่ม AI integration: `ai_chat.php`, `api_ai_chat.php`, `api_ai_search.php`
- **2026-04-17** — เพิ่ม department/division filtering, ปรับ auth system
- **2026-04-28** — ปรับปรุง API layer ล่าสุด

## Features

- จัดการข้อมูลรถ, คนขับ, ประวัติการใช้งาน
- ระบบขอยืมรถ: request → approve → return workflow
- ติดตามการซ่อม, น้ำมัน, mileage
- GPS tracking map real-time
- AI chat ค้นหาข้อมูลด้วยภาษาธรรมชาติ
- Export PDF/Excel (PHPOffice)
- Role-based access ระดับกอง/ฝ่าย

## Status

**Production** — ใช้งานจริง อยู่ระหว่าง maintenance

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\car2`
- Stack: PHP
- Entry points: index.php
- Config files: .env
- DB hints: (none)

### AI Summary (24h)

1) **Summary**
- ระบบ car2 (PHP/MySQL) ทำงานในโหมด Production โดยเน้นการนำเข้าข้อมูล ERP ขนาดใหญ่ (Excel) ล่าสุดเมื่อ 29 พ.ย. 2026
- ไฟล์ที่นำเข้าครอบคลุมข้อมูลยานพาหนะ, เรือ, อะไหล่, และประวัติซ่อมบำรุง/ใช้น้ำมัน จำนวนหลายแสนแถว
- โค้ดล่าสุด (พ.ค. 2026) มีการแก้ไขความเสถียรของ PDO queries เพื่อป้องกัน HTTP 500 errors

2) **Risks**
- การประมวลผลไฟล์ Excel ขนาดใหญ่ (เช่น 115,506 แถว) อาจทำให้ Memory Limit เต็มหรือ Timeout หากไม่ใช้ Chunked Processing
- การเก็บไฟล์ Excel จำนวนมากในโฟลเดอร์ `erp\0569\` อาจทำให้ Disk Space เต็มและจัดการยากหากไม่มีระบบ Cleanup อัตโนมัติ
- ความเสี่ยงด้านความปลอดภัยหากไฟล์ Excel ที่นำเข้ามี Macro หรือ Malicious Content ที่ไม่ได้ถูก Sanitize ก่อนประมวลผล

3) **Next Step**
- ตรวจสอบ Log Server (Error/Access) เพื่อยืนยันว่าการนำเข้าข้อมูลล่าสุดสำเร็จและไม่มี Memory Leak
- ทบทวนโค้ดส่วน Import Excel ว่ามีการใช้ `try/catch` และจัดการ Resource (เช่น `unset`, `gc_collect_cycles`) อย่างถูกต้องหรือไม่
- วางแผนระบบ Archive หรือ Delete ไฟล์ Excel เก่าอัตโนมัติ เพื่อรักษาพื้นที่จัดเก็บและประสิทธิภาพของระบบ

*(model: Qwen/Qwen3-14B)*

### Recent Files

- `erp\0569\all_cars_in_asset_28-04-2026_01-00-29_9896_rows.xlsx` 2076-11-29 15:54
- `erp\0569\rent_cars_oil_used_fiscal67_28-04-2026_01-07-23_97370_rows.xlsx` 2076-11-29 15:54
- `erp\0569\boats_in_asset_28-04-2026_01-12-29_925_rows.xlsx` 2076-11-29 15:54
- `erp\0569\ast_master_part_28-04-2026_01-12-39_115506_rows.xlsx` 2076-11-29 15:54
- `erp\0569\bma_cars_oil_used_fiscal67_28-04-2026_01-02-21_93151_rows.xlsx` 2076-11-29 15:54
- `erp\0569\repair_his_building_asset_28-04-2026_01-12-18_20_rows.xlsx` 2076-11-29 15:54
- `erp\0569\repair_his_agriculture_asset_28-04-2026_01-12-15_170_rows.xlsx` 2076-11-29 15:54
- `erp\0569\repair_his_vehicles_28-04-2026_01-11-25_8029_rows.xlsx` 2076-11-29 15:54
- `erp\0569\repair_his_factory_asset_28-04-2026_01-12-25_659_rows.xlsx` 2076-11-29 15:54
- `manual_user.php` 2026-05-18 17:01

### Git Commits

- 2026-05-18 300f0b7 fix: wrap unguarded PDO queries in try/catch to prevent HTTP 500
- 2026-05-18 6350461 init: car2 v2.3.0 — vehicle borrowing system BMA

### Risks

- future timestamps detected in recent files

<!-- AUTO_SECTION_END -->
