# BMA Early-Childhood Data Hub / API Gateway (`link`)

- **Path:** `C:\inetpub\wwwroot\link`
- **URL:** `/link/` (entry redirect → `/admin/login.php`)
- **Stack:** PHP (no framework, custom OOP) · MySQL · Bootstrap 5 admin UI

## หน้าที่

ระบบกลางสำหรับ **ข้อมูลเด็กปฐมวัย** ของ กทม. — รวม core fields, mapping จากแต่ละสำนัก/ระบบต้นทาง, ingestion (CSV/XLSX), validation, data-quality monitoring, masking ตาม sensitivity level, audit log สำหรับ API requests

## Structure

```
link/
├── src/                      # core services (PSR-style classes)
│   ├── bootstrap.php         # require services + Security::startSession
│   ├── Database.php
│   ├── Security.php · Auth.php
│   ├── ApiGateway.php        # public API entry
│   ├── AuditLogger.php
│   ├── FieldPolicyEngine.php
│   ├── MaskingService.php
│   ├── ValidationService.php
│   ├── DataQualityService.php
│   ├── ChildIndexService.php
│   ├── MappingService.php
│   ├── IngestionService.php
│   ├── CsvImporter.php · XlsxImporter.php · TabularImporter.php
│   └── helpers.php
├── admin/                    # admin pages (PHP)
│   ├── login.php · logout.php · change_password.php
│   ├── dashboard.php         # KPI + recent audit logs
│   ├── core_fields.php · agencies.php · source_systems.php
│   ├── mappings.php · field_policies.php
│   ├── ingestion.php · sample_data.php
│   ├── data_quality.php
│   ├── audit_logs.php · access_requests.php · api_clients.php
│   ├── users.php · setup_admin.php · manual.php
│   └── _common.php
├── public/                   # public web entry + API
│   ├── api/
│   ├── assets/
│   └── index.php
├── config/                   # config.php + security.php (require'd by bootstrap)
├── database/
├── docs/
├── storage/
└── web.config
```

## Core domain

| Table | บทบาท |
|---|---|
| `core_fields` | นิยาม field กลาง (มี `sensitivity_level`: Internal · Confidential · Sensitive Personal Data) |
| `agencies` | สำนัก/หน่วยงาน |
| `source_systems` | ระบบต้นทางของแต่ละสำนัก |
| `child_records` | ข้อมูลเด็ก (sample/test) |
| `audit_logs` | ทุก API request, มี `blocked_fields_json`, `blocked_reason`, `api_client_id` |
| `data_quality_errors` | error จาก ValidationService |

Mapping reference: [BMA_EarlyChildhood_CoreDataset_Mapping.xlsx](C:/codex/BMA_EarlyChildhood_CoreDataset_Mapping.xlsx)

## Dashboard KPI (จาก admin/dashboard.php)

จำนวน core_fields · agencies · source_systems · child_records · mapped/unmapped fields · sensitive/confidential/internal · API requests · blocked fields · data_quality_errors

## Entry flow

`index.php` → `redirect_to('/admin/login.php')` (ดู [src/bootstrap.php](C:/inetpub/wwwroot/link/src/bootstrap.php) สำหรับลำดับ require)
