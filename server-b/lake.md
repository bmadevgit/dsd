# BMA Data Lake Portal

- **Slug:** `lake`
- **Path:** `C:\inetpub\wwwroot\lake`
- **URL:** https://172.27.15.6/lake/
- **Stack:** Next.js 14 + React 18 + TypeScript + Tailwind
- **Process:** PM2 (bma-lake :3000) -> IIS ARR
- **DB:** CKAN PostgreSQL (read) + lake MySQL (write)

- **Files (excl node_modules/.next/.venv/logs/.git/tmp_):** 97 files, 0.5 MB

## Activity (จากการสแกน file mtime)

### วันนี้ (2026-05-13): 0 ไฟล์

  (ไม่มีไฟล์แก้ไขวันนี้)

### 7 วันล่าสุด (ไม่รวมวันนี้): 62 ไฟล์

- **2026-05-12** (9 ไฟล์):
  - 05:31 `src/components/AIChat.tsx`
  - 05:30 `src/lib/cache.ts`
  - 05:30 `src/components/HomeAIChat.tsx`
  - 05:24 `src/app/api/ai/warm/route.ts`
  - 05:22 `next.config.js`
  - 05:22 `src/instrumentation.ts`
  - 05:21 `src/app/api/ai/dataset-chat/route.ts`
  - 05:20 `src/app/api/ai/chat/route.ts`
  - ... (+1 more)
- **2026-05-11** (28 ไฟล์):
  - 21:40 `src/lib/mcp-tools.ts`
  - 21:32 `src/app/(public)/datasets/lake/[name]/page.tsx`
  - 21:32 `src/app/(public)/datasets/ckan/[name]/page.tsx`
  - 21:32 `src/components/DatasetChat.tsx`
  - 21:31 `src/lib/csv.ts`
  - 21:24 `src/app/(public)/page.tsx`
  - 21:17 `src/app/admin/source-checks/page.tsx`
  - 21:17 `src/components/admin/SourceChecksClient.tsx`
  - ... (+20 more)
- **2026-05-10** (8 ไฟล์):
  - 22:18 `src/components/admin/OrgForm.tsx`
  - 22:18 `src/components/admin/DatasetForm.tsx`
  - 22:17 `src/app/api/organizations/[id]/route.ts`
  - 22:17 `src/app/api/organizations/route.ts`
  - 22:17 `src/app/api/datasets/[id]/route.ts`
  - 22:17 `src/app/api/datasets/route.ts`
  - 22:16 `src/lib/types.ts`
  - 22:16 `src/lib/utils.ts`
- **2026-05-06** (17 ไฟล์):
  - 10:31 `src/app/admin/settings/page.tsx`
  - 10:30 `src/app/api/admin/settings/map-menu/route.ts`
  - 10:30 `src/app/api/public/settings/route.ts`
  - 10:30 `src/lib/settings.ts`
  - 10:15 `src/components/map/DatasetMap.tsx`
  - 10:13 `src/lib/map-utils.ts`
  - 10:06 `src/app/(public)/datasets/map-center/page.tsx`
  - 10:06 `src/app/(public)/datasets/maps/page.tsx`
  - ... (+9 more)

### 8-30 วันก่อน: 35 ไฟล์ (ดูสรุป)

- **2026-05-05**: 1 ไฟล์
- **2026-05-04**: 2 ไฟล์
- **2026-05-03**: 5 ไฟล์
- **2026-05-01**: 1 ไฟล์
- **2026-04-30**: 2 ไฟล์
- **2026-04-29**: 24 ไฟล์

## Source docs / config (อยู่ใน project)

- [RUNBOOK.md](C:/inetpub/wwwroot/lake/RUNBOOK.md) - last modified 2026-05-06 08:51
- [package.json](C:/inetpub/wwwroot/lake/package.json) - last modified 2026-05-11 21:07
- [ecosystem.config.js](C:/inetpub/wwwroot/lake/ecosystem.config.js) - last modified 2026-05-06 08:50
- [web.config](C:/inetpub/wwwroot/lake/web.config) - last modified 2026-05-01 13:15
- [next.config.js](C:/inetpub/wwwroot/lake/next.config.js) - last modified 2026-05-12 05:22

---
*Auto-generated 2026-05-13 02:00 by `server-b/refresh-server-b.ps1` (disk scan)*

