# exam/a — BMA Alert Data Explorer

**Path:** `C:\inetpub\wwwroot\exam\a`
**Stack:** PHP · PDO · MySQL · Python (worker + scraper)
**Tool:** Claude Code

---

## Timeline

- **2026-03-29** — สร้าง PHP components: `index.php`, `api.php`, `map.php`
- **2026-04-11 – 2026-04-12** — เพิ่ม API + ปรับ worker
- **2026-05-04** — Python worker updates ล่าสุด

## Features

- ค้นหาและดู LINE messages จาก BMA Alert system
- Filter ด้วย keyword, วันที่, ประเภทข้อความ
- Pagination + สถิติตามประเภท
- Python worker: scraper + AI processor (`worker/ai_worker.py`)
- Windows Task Scheduler integration (`worker/install_task.ps1`)
- Database: MySQL (tables: `line_data`, `enriched_alerts`)

## Status

**Active** — ใช้งานจริง ยังพัฒนาต่อ
