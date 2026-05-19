# BMA Data Lake Portal

- **Slug:** `lake`
- **Path:** `C:\inetpub\wwwroot\lake`
- **URL:** https://172.27.15.6/lake/
- **Stack:** Next.js 14 + React 18 + TypeScript + Tailwind
- **Process:** PM2 (bma-lake :3000) -> IIS ARR
- **DB:** CKAN PostgreSQL (read) + lake MySQL (write)

- **Files (excl node_modules/.next/.venv/logs/.git/tmp_):** 106 files, 0.5 MB

## Activity (จากการสแกน file mtime)

### AI Summary (24 ชั่วโมงล่าสุด)

**สรุปการเปลี่ยนแปลง**  
- อัปเดตหน้าหลัก (`page.tsx`) และคอมโพเนนต์ค้นหา (`HeroSearch.tsx`)  
- ปรับปรุง API ค้นหาข้อมูล (`search/smart/route.ts`) และตรรกะการค้นหา (`dataset-search.ts`)  
- เพิ่มสคริปต์ตรวจสอบแหล่งข้อมูล (`check-sources.mjs`)  
- ปรับปรุงคอมโพเนนต์จัดการแหล่งข้อมูลในส่วน Admin (`SourceChecksClient.tsx`)  
- เพิ่มฟีเจอร์แชท AI หลายหน้า (`DatasetChat.tsx`, `AIChat.tsx`, `HomeAIChat.tsx`)  
- อัปเดต API สำหรับแชท AI (`ai/dataset-chat/route.ts`, `ai/chat/route.ts`)  
- ปรับปรุงไลบรารี AI (`ai.ts`) และตั้งค่า `.env.local`  

**ข้อควรระวัง**  
- ตรวจสอบการทำงานของ AI fallback ใน API ค้นหา (`search/smart/route.ts`) กรณีไม่พบผลลัพธ์  
- ตรวจสอบประสิทธิภาพตรรกะค้นหา (`dataset-search.ts`) หลังอัปเดต  
- รันสคริปต์ `check-sources.mjs` เพื่อตรวจสอบความถูกต้องของแหล่งข้อมูล  
- ตรวจสอบสิทธิ์การเข้าถึงคอมโพเนนต์ Admin (`SourceChecksClient.tsx`)  
- ตรวจสอบความปลอดภัยของฟีเจอร์แชท AI (เช่น การป้องกันการโจมตีผ่านอินพุต)  
- ตรวจสอบค่าตัวแปรใน `.env.local` ว่าตรงกับสภาพแวดล้อมปัจจุบันหรือไม่

*(model: Qwen/Qwen3-14B, 14 files analyzed)*

### วันนี้ (2026-05-20): 0 ไฟล์

  (ไม่มีไฟล์แก้ไขวันนี้)

### 7 วันล่าสุด (ไม่รวมวันนี้): 22 ไฟล์

- **2026-05-19** (14 ไฟล์):
  - 18:02 `src/app/(public)/page.tsx`
  - 18:01 `src/components/HeroSearch.tsx`
  - 18:01 `src/app/api/search/smart/route.ts`
  - 18:00 `src/lib/dataset-search.ts`
  - 16:54 `scripts/check-sources.mjs`
  - 15:07 `src/components/admin/SourceChecksClient.tsx`
  - 14:46 `src/components/DatasetChat.tsx`
  - 14:46 `src/components/AIChat.tsx`
  - ... (+6 more)
- **2026-05-13** (8 ไฟล์):
  - 10:49 `src/middleware.ts`
  - 10:29 `src/app/admin/mcp/page.tsx`
  - 10:29 `src/app/api/mcp/v1/route.ts`
  - 10:03 `src/app/api/mcp/call/route.ts`
  - 10:03 `src/lib/api-key.ts`
  - 09:58 `src/app/api/admin/api-keys/[id]/route.ts`
  - 09:58 `src/app/api/admin/api-keys/route.ts`
  - 09:57 `sql/004-api-keys.sql`

### 8-30 วันก่อน: 84 ไฟล์ (ดูสรุป)

- **2026-05-12**: 5 ไฟล์
- **2026-05-11**: 20 ไฟล์
- **2026-05-10**: 8 ไฟล์
- **2026-05-06**: 17 ไฟล์
- **2026-05-05**: 1 ไฟล์
- **2026-05-04**: 1 ไฟล์
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
*Auto-generated 2026-05-20 02:00 by `server-b/refresh-server-b.ps1` (disk scan)*

