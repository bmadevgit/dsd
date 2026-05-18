# BMA Early-Childhood Data Hub / API Gateway

- **Slug:** `link`
- **Path:** `C:\inetpub\wwwroot\link`
- **URL:** /link/ (redirect -> /admin/login.php)
- **Stack:** PHP (custom OOP, no framework) + MySQL + Bootstrap 5
- **Process:** IIS PHP
- **DB:** MySQL (core_fields, agencies, child_records, audit_logs, ...)

- **Files (excl node_modules/.next/.venv/logs/.git/tmp_):** 148 files, 176.3 MB

## Activity (จากการสแกน file mtime)

### AI Summary (168 ชั่วโมงล่าสุด)

**สรุปการเปลี่ยนแปลง**  
- ปรับปรุงไฟล์ CSS/JS หน้าหลัก (`app.css`, `app.js`) สำหรับ UI/UX เช่น เพิ่มฟังก์ชันยืนยันการลบและ Hover Effect  
- อัปเดตไฟล์ Admin (`_common.php`, `audit_logs.php`, `dataview.php`) สำหรับการจัดการเมนู, ตรวจสอบสิทธิ์ผู้ใช้ (Super Admin), และเพิ่มฟีเจอร์การดู Log  
- เพิ่ม/ปรับปรุงไฟล์ทดสอบ UAT ใน `tests-md/` สำหรับโมดูลต่างๆ เช่น Security, API Key, Data Quality, Accessibility  

**ข้อควรระวัง**  
- ตรวจสอบการเปลี่ยนแปลงสิทธิ์การเข้าถึงใน `audit_logs.php` ที่จำกัดเฉพาะ Super Admin  
- ทดสอบฟังก์ชันใหม่ใน Admin Panel (เช่น `dataview.php`) เพื่อความถูกต้องของข้อมูล  
- ตรวจสอบความสอดคล้องของไฟล์ทดสอบ UAT (`tests-md/*.md`) กับฟีเจอร์ที่ปรับปรุงล่าสุด  
- สำรองข้อมูลก่อนอัปเดตไฟล์ที่เกี่ยวข้องกับการตรวจสอบสิทธิ์ (เช่น `Auth::requireLogin()`)

*(model: Qwen/Qwen3-14B, 86 files analyzed)*

### วันนี้ (2026-05-18): 0 ไฟล์

  (ไม่มีไฟล์แก้ไขวันนี้)

### 7 วันล่าสุด (ไม่รวมวันนี้): 86 ไฟล์

- **2026-05-16** (52 ไฟล์):
  - 18:53 `public/assets/js/app.js`
  - 18:47 `admin/_common.php`
  - 18:45 `admin/audit_logs.php`
  - 18:44 `admin/ui_event_log.php`
  - 18:43 `public/assets/css/app.css`
  - 18:32 `src/DataViewService.php`
  - 18:32 `admin/dataview.php`
  - 18:30 `tests-md/modules/admin-registries-crud.md`
  - ... (+44 more)
- **2026-05-15** (8 ไฟล์):
  - 14:26 `docs/SYSTEM_DIAGRAM_TH.html`
  - 13:37 `admin/setup_admin.php`
  - 13:36 `admin/users.php`
  - 13:36 `admin/change_password.php`
  - 13:35 `admin/login.php`
  - 13:35 `admin/first_profile.php`
  - 13:35 `src/Auth.php`
  - 13:34 `database/migrations/019_first_login_profile_enforcement.sql`
- **2026-05-14** (12 ไฟล์):
  - 20:27 `database/migrations/018_remove_bma_po_workbook_artifacts.sql`
  - 20:24 `src/bootstrap.php`
  - 20:24 `admin/datasets.php`
  - 14:03 `database/migrations/017_create_dataset_ai_analyses.sql`
  - 10:41 `src/AuditLogger.php`
  - 10:38 `admin/health_dict.php`
  - 10:37 `public/api/v1/index.php`
  - 10:37 `src/ApiGateway.php`
  - ... (+4 more)
- **2026-05-13** (13 ไฟล์):
  - 15:55 `admin/sample_data.php`
  - 13:04 `database/migrations/015_seed_digi_health_access_except_pid_hash.sql`
  - 12:59 `admin/dashboard.php`
  - 12:46 `admin/logout.php`
  - 12:41 `src/helpers.php`
  - 12:34 `admin/agencies.php`
  - 12:14 `src/IngestionService.php`
  - 12:13 `src/DatasetService.php`
  - ... (+5 more)
- **2026-05-12** (1 ไฟล์):
  - 15:14 `storage/uploads/incoming/health/vr_school_hygiene_20260512_hash.csv`

### 8-30 วันก่อน: 62 ไฟล์ (ดูสรุป)

- **2026-05-01**: 1 ไฟล์
- **2026-04-30**: 44 ไฟล์
- **2026-04-29**: 17 ไฟล์

## Backup files ที่พบ (บ่งบอกว่ามีการแก้ไขย้อนหลัง)

- `storage/backups/link_code_backup_20260516_085201.zip` (2026-05-16 08:52)
- `admin/field_policies.php.20260501_083617.bak` (2026-05-01 08:34)
- `storage/backups/ADMIN_MANUAL_TH_20260501_062311.md` (2026-04-30 19:47)
- `storage/backups/USER_MANUAL_TH_20260501_062311.md` (2026-04-30 19:47)
- `storage/backups/INSTALL_IIS_20260501_062311.md` (2026-04-30 19:46)
- `storage/backups/FieldPolicyEngine_20260430_193001.php` (2026-04-30 19:10)
- `storage/backups/field_policies_20260430_190832.php` (2026-04-30 19:04)
- `storage/backups/FieldPolicyEngine_20260430_190832.php` (2026-04-30 18:39)
- `storage/backups/mappings_20260430_193001.php` (2026-04-30 15:32)
- `storage/backups/_common_20260430_193001.php` (2026-04-30 14:16)
- `storage/backups/app_css_20260430_183830.css` (2026-04-30 14:15)
- `storage/backups/field_policies_20260430_183830.php` (2026-04-30 14:15)
- `storage/backups/field_policies_20260430_141205.php` (2026-04-30 13:56)
- `storage/backups/ingestion_20260430_193001.php` (2026-04-30 12:09)
- `storage/backups/dashboard_20260430_193001.php` (2026-04-30 11:48)

## Source docs / config (อยู่ใน project)

- [web.config](C:/inetpub/wwwroot/link/web.config) - last modified 2026-04-30 11:50
- [src/bootstrap.php](C:/inetpub/wwwroot/link/src/bootstrap.php) - last modified 2026-05-14 20:24

---
*Auto-generated 2026-05-18 11:54 by `server-b/refresh-server-b.ps1` (disk scan)*

