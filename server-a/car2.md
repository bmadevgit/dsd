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
