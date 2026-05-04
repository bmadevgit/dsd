# OPEN — Hospital Case Status Tracker (`open`)

- **Path:** `C:\inetpub\wwwroot\open`
- **Public URL:** `https://exam.bangkok.go.th/open/`
- **Stack:** PHP (no framework, `mysqli` ตรง) · MariaDB/MySQL · CSS เดียวที่ `assets/style.css`

> มี handoff doc ที่ [open/PROJECT_HANDOFF.md](C:/inetpub/wwwroot/open/PROJECT_HANDOFF.md) และ UAT ที่ [open/UAT_TEST_DOCUMENT.md](C:/inetpub/wwwroot/open/UAT_TEST_DOCUMENT.md)

## หน้าที่

- **Public:** ค้นหาสถานะเคส/เอกสาร/การเงินจาก `invoice_no` หรือ `ref_no` + 4 หลักท้าย TAX ID, filter ตามโรงพยาบาล แสดงข้อมูลเคส + การเงิน + สถานะเอกสาร + timeline จาก `case_status_logs`
- **Admin:** login/logout, KPI dashboard, CRUD case, filter, sync log placeholder ไป MIS, **AI analysis dashboard** (ยิงไป Qwen2.5-32B-Instruct-AWQ ที่ `http://100.99.107.27:8000/v1`)

## Structure

```
open/
├── admin/index.php
├── assets/style.css
├── config/config.php
├── includes/
│   ├── common.php
│   └── db.php
├── sql/
│   ├── schema.sql
│   └── get_sample_cases.php
├── api.asp                   # legacy ASP endpoint
├── guide.php
├── index.php                 # public search
├── install.php               # setup เครื่องใหม่
├── sync.php                  # MIS sync placeholder
├── PROJECT_HANDOFF.md
├── UAT_TEST_DOCUMENT.md
└── web.config
```

## Config (config/config.php)

```php
'base_path' => '/open',
'ai' => [
    'base_url' => 'http://100.99.107.27:8000/v1',
    'model'    => 'Qwen/Qwen2.5-32B-Instruct-AWQ',
    'timeout_seconds' => 60,
],
'db' => [
    'host' => '127.0.0.1', 'port' => 3306,
    'database' => 'open', 'username' => 'open',
    'charset' => 'utf8mb4',
],
```

## Install (เครื่องใหม่)

`install.php` → สร้าง DB `open` + tables + seed 11 โรงพยาบาล + admin เริ่มต้น (`admin / 1234`) + dummy 100+ cases

## ย้าย path

ถ้าย้ายไป root อื่น (เช่น `/exam-open` หรือ `/`) ต้องแก้ `base_path` ใน `config/config.php`
