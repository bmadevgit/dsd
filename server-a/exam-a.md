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

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\exam\a`
- Stack: PHP
- Entry points: index.php
- Config files: web.config
- DB hints: (none)

### Recent Files

- `worker\worker.log` 2026-05-05 06:56
- `worker\ai_worker.py` 2026-05-04 13:59
- `worker\config.env` 2026-05-04 13:29
- `map.php` 2026-04-12 16:28
- `api.php` 2026-04-12 16:27
- `index.php` 2026-04-11 10:56
- `worker\install_task.ps1` 2026-04-03 19:55
- `worker\requirements.txt` 2026-04-03 10:17
- `worker\scraper.py` 2026-04-03 10:16
- `worker\run_worker.bat` 2026-03-29 10:57

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

<!-- AUTO_SECTION_END -->
