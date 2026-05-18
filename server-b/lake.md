# BMA Data Lake Portal

- **Slug:** `lake`
- **Path:** `C:\inetpub\wwwroot\lake`
- **URL:** https://172.27.15.6/lake/
- **Stack:** Next.js 14 + React 18 + TypeScript + Tailwind
- **Process:** PM2 (bma-lake :3000) -> IIS ARR
- **DB:** CKAN PostgreSQL (read) + lake MySQL (write)

- **Files (excl node_modules/.next/.venv/logs/.git/tmp_):** 103 files, 0.5 MB

## Activity (จากการสแกน file mtime)

### AI Summary (168 ชั่วโมงล่าสุด)

**สรุปการเปลี่ยนแปลง**  
- อัปเดตการจัดการ MCP (Model Context Protocol) ผ่าน `middleware.ts`, `api/mcp/v1/route.ts`, และ `admin/mcp/page.tsx`  
- เพิ่ม/แก้ไขระบบจัดการ API Key ใน `api-key.ts`, `sql/004-api-keys.sql`, และ API ที่เกี่ยวข้อง  
- ปรับปรุงส่วน AI Chat ด้วยไฟล์ `AIChat.tsx`, `HomeAIChat.tsx`, และ API ที่เกี่ยวข้อง  
- แก้ไขส่วน UI เช่น `Navbar.tsx`, `Footer.tsx`, และหน้าช่วยเหลือ (`help/page.tsx`)  

**ข้อควรระวัง**  
- ตรวจสอบว่า migration `sql/004-api-keys.sql` ถูกประมวลผลแล้วหรือไม่ (อาจมีการเปลี่ยนแปลง schema ของตาราง api_keys)  
- ตรวจสอบการรีไวท์ URL ใน `middleware.ts` อาจส่งผลต่อการทำงานของ MCP client  
- ตรวจสอบความปลอดภัยใน `api-key.ts` (เช่น การตรวจสอบสิทธิ์, การบันทึกเหตุการณ์)  
- ทดสอบการทำงานของ API ที่เกี่ยวข้องกับ MCP และ API Key หลังอัปเดต

*(model: Qwen/Qwen3-14B, 43 files analyzed)*

### วันนี้ (2026-05-18): 0 ไฟล์

  (ไม่มีไฟล์แก้ไขวันนี้)

### 7 วันล่าสุด (ไม่รวมวันนี้): 43 ไฟล์

- **2026-05-13** (8 ไฟล์):
  - 10:49 `src/middleware.ts`
  - 10:29 `src/app/admin/mcp/page.tsx`
  - 10:29 `src/app/api/mcp/v1/route.ts`
  - 10:03 `src/app/api/mcp/call/route.ts`
  - 10:03 `src/lib/api-key.ts`
  - 09:58 `src/app/api/admin/api-keys/[id]/route.ts`
  - 09:58 `src/app/api/admin/api-keys/route.ts`
  - 09:57 `sql/004-api-keys.sql`
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
- **2026-05-11** (26 ไฟล์):
  - 21:40 `src/lib/mcp-tools.ts`
  - 21:32 `src/app/(public)/datasets/lake/[name]/page.tsx`
  - 21:32 `src/app/(public)/datasets/ckan/[name]/page.tsx`
  - 21:32 `src/components/DatasetChat.tsx`
  - 21:31 `src/lib/csv.ts`
  - 21:24 `src/app/(public)/page.tsx`
  - 21:17 `src/app/admin/source-checks/page.tsx`
  - 21:17 `src/components/admin/SourceChecksClient.tsx`
  - ... (+18 more)

### 8-30 วันก่อน: 60 ไฟล์ (ดูสรุป)

- **2026-05-10**: 8 ไฟล์
- **2026-05-06**: 17 ไฟล์
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
*Auto-generated 2026-05-18 11:54 by `server-b/refresh-server-b.ps1` (disk scan)*

