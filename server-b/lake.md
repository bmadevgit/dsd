# BMA Data Lake Portal

- **Slug:** `lake`
- **Path:** `C:\inetpub\wwwroot\lake`
- **URL:** https://172.27.15.6/lake/
- **Stack:** Next.js 14 + React 18 + TypeScript + Tailwind
- **Process:** PM2 (bma-lake :3000) -> IIS ARR
- **DB:** CKAN PostgreSQL (read) + lake MySQL (write)

- **Files (excl node_modules/.next/.venv/logs/.git/tmp_):** 72 files, 0.4 MB

## Activity (จากการสแกน file mtime)

### วันนี้ (2026-05-09): 0 ไฟล์

  (ไม่มีไฟล์แก้ไขวันนี้)

### 7 วันล่าสุด (ไม่รวมวันนี้): 33 ไฟล์

- **2026-05-06** (20 ไฟล์):
  - 10:31 `src/app/admin/settings/page.tsx`
  - 10:31 `src/app/admin/layout.tsx`
  - 10:30 `src/components/ui/Navbar.tsx`
  - 10:30 `src/app/api/admin/settings/map-menu/route.ts`
  - 10:30 `src/app/api/public/settings/route.ts`
  - 10:30 `src/lib/settings.ts`
  - 10:15 `src/components/map/DatasetMap.tsx`
  - 10:13 `src/lib/map-utils.ts`
  - ... (+12 more)
- **2026-05-05** (3 ไฟล์):
  - 21:12 `tsconfig.tsbuildinfo`
  - 16:35 `src/app/(public)/datasets/lake/[name]/page.tsx`
  - 16:34 `src/app/(public)/datasets/ckan/[name]/page.tsx`
- **2026-05-04** (5 ไฟล์):
  - 14:19 `src/app/admin/source-checks/page.tsx`
  - 13:39 `package-lock.json`
  - 13:39 `package.json`
  - 13:34 `next.config.js`
  - 13:23 `scripts/check-sources.mjs`
- **2026-05-03** (5 ไฟล์):
  - 22:12 `scripts/install-task.ps1`
  - 18:33 `src/lib/queries/lake.ts`
  - 18:33 `scripts/001-source-checks.sql`
  - 15:51 `src/components/admin/ResourceManager.tsx`
  - 15:50 `src/app/api/resources/route.ts`

### 8-30 วันก่อน: 39 ไฟล์ (ดูสรุป)

- **2026-05-01**: 1 ไฟล์
- **2026-04-30**: 5 ไฟล์
- **2026-04-29**: 33 ไฟล์

## Source docs / config (อยู่ใน project)

- [RUNBOOK.md](C:/inetpub/wwwroot/lake/RUNBOOK.md) - last modified 2026-05-06 08:51
- [package.json](C:/inetpub/wwwroot/lake/package.json) - last modified 2026-05-04 13:39
- [ecosystem.config.js](C:/inetpub/wwwroot/lake/ecosystem.config.js) - last modified 2026-05-06 08:50
- [web.config](C:/inetpub/wwwroot/lake/web.config) - last modified 2026-05-01 13:15
- [next.config.js](C:/inetpub/wwwroot/lake/next.config.js) - last modified 2026-05-04 13:34

---
*Auto-generated 2026-05-09 02:00 by `server-b/refresh-server-b.ps1` (disk scan)*

