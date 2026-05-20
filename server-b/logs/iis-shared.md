# Log analysis: iis-shared

> Snapshot: 2026-05-21 03:00  ·  log files modified in last 24h: **2**

## AI Analysis

1) **สถานะรวม**  
ระบบทำงานปกติโดยไม่มี error ร้ายแรง แต่มีการเข้าถึง API ที่ล้มเหลว (401 Unauthorized) บ่งชี้ปัญหาการรับรองตัวตน

2) **Error/Warning ที่ต้องสนใจ**  
- `401 Unauthorized` พบ 2 ครั้ง (2026-05-19 23:00:10 และ 2026-05-20 20:00:12) ที่ `POST /testx/api/auth/login`  
  - ไฟล์: `u_ex260519.log`, `u_ex260520.log`  
  - ความเสี่ยง: อาจเกิดจากข้อมูลการเข้าสู่ระบบผิด หรือการตั้งค่า API ที่ไม่ถูกต้อง  
- `307 Temporary Redirect` ที่ `GET /testx/api/auth/logout`  
  - ไฟล์: `u_ex260519.log`, `u_ex260520.log`  
  - ความเสี่ยง: อาจส่งผลต่อการออกจากระบบหากไม่จัดการ redirect ให้ถูกต้อง

3) **คำแนะนำเบื้องต้น**  
- ตรวจสอบการรับรองตัวตน (authentication) ที่ `/api/auth/login` ว่ามีการส่งข้อมูลถูกต้องหรือไม่  
- ตรวจสอบการตั้งค่า API หรือ middleware ที่เกี่ยวข้องกับการรับรองตัวตน  
- ตรวจสอบ log ของ backend หรือ application ที่รับ request นี้เพิ่มเติมเพื่อดูสาเหตุ 401 ที่แท้จริง

*(model: Qwen/Qwen3-14B, 2 log files analyzed)*

## Log files seen (24h)

- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260520.log` (2026-05-21 02:18, 967,990 bytes)
- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260519.log` (2026-05-20 06:00, 5,654,800 bytes)

## Raw log excerpts

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260520.log`

```
... [truncated head]
84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=bebe6f81-1876-484d-9e42-e20c1b32729d&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-20 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=d16e16bf-a391-4131-ad4b-e09e9b5a902e&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 1
2026-05-20 20:00:10 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e3379c8a-8103-49c1-94bf-b919dcb31d27&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 404 415 11
2026-05-20 20:00:10 172.27.15.6 GET /testx/admin/dashboard X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=9ad81d80-a959-4ccf-ad58-7efbf7b5bd58&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 5480 558 62
2026-05-20 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/admin/dashboard/page-81b69b1d54b6432c.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=a6351718-e91d-442d-92c1-321201b3b5bd&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/dashboard 200 0 0 1961 449 0
2026-05-20 20:00:10 172.27.15.6 GET /testx/api/auth/logout X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=9670a918-d384-4f51-a99d-3c7da7c3d951&SERVER-STATUS=307 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 307 0 0 315 511 8
2026-05-20 20:00:10 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=b2808aa0-5a28-4c75-b31c-cb1ed70e6bb6&SERVER-STATUS=304 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 304 0 0 294 454 7
2026-05-20 20:00:12 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=8805e0a0-3b0a-4ae5-b490-3527cfb39234&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 200 0 0 2922 422 9
2026-05-20 20:00:12 172.27.15.6 GET /testx/_next/static/css/1203a7972f747562.css X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=5c621e9e-7c28-4443-8f5b-3052e67d65aa&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 4152 348 0
2026-05-20 20:00:12 172.27.15.6 GET /testx/_next/static/chunks/webpack-6283abe281eca2d1.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=b5d7abf4-4506-4fcf-864e-e1b89c9e13ba&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 2106 343 0
2026-05-20 20:00:12 172.27.15.6 GET /testx/_next/static/chunks/fd9d1056-87da80e0c187477b.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=7a036bd8-3aba-4137-894c-275157b4e26f&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 54116 344 1
2026-05-20 20:00:12 172.27.15.6 GET /testx/_next/static/chunks/117-cd24e094a43c1bcf.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e67526f6-6956-4199-845e-7cde7e62f3bd&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 32241 339 1
2026-05-20 20:00:12 172.27.15.6 GET /testx/_next/static/chunks/main-app-6a17828942593d20.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=f892e8b9-666d-4ca7-b0c3-143cf2280e96&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 807 344 0
2026-05-20 20:00:12 172.27.15.6 GET /testx/_next/static/chunks/29-d649f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=bebe6f81-1876-484d-9e42-e20c1b32729d&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-20 20:00:12 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=d16e16bf-a391-4131-ad4b-e09e9b5a902e&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-20 20:00:12 172.27.15.6 GET /testx/_next/static/chunks/app/admin/login/page-671d6df78d1dc1ed.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=7bd53d98-a7c1-4e7c-b836-0d1235106203&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1420 356 0
2026-05-20 20:00:12 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=a0783e5e-0872-433f-8268-6cace3f85f32&SERVER-STATUS=401 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 401 0 0 287 424 430
```

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260519.log`

```
... [truncated head]
f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=a46c9a5a-e87f-44a5-87ff-a754eb82d0c2&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-19 23:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=cc1db591-0640-4b8f-b3d9-6296f102a4d3&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-19 23:00:09 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e41c65f8-ef75-4047-9b8f-0594e812c6bf&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 404 415 9
2026-05-19 23:00:09 172.27.15.6 GET /testx/admin/dashboard X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=7bbd9dc2-f507-4be4-9008-c8d29176abfc&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 5474 558 38
2026-05-19 23:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/admin/dashboard/page-81b69b1d54b6432c.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=ab05fd31-4b1a-41cc-b52d-8fa2a30bf38b&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/dashboard 200 0 0 1961 449 0
2026-05-19 23:00:09 172.27.15.6 GET /testx/api/auth/logout X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=9e54cb50-ad39-4d83-b125-137ee299d1c3&SERVER-STATUS=307 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 307 0 0 315 511 5
2026-05-19 23:00:09 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=9ab33cfb-a78f-4071-be89-fa6fce585b13&SERVER-STATUS=304 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 304 0 0 294 454 4
2026-05-19 23:00:10 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=b19c2bdb-7b06-4d36-9e70-ccf83e692433&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 200 0 0 2922 422 9
2026-05-19 23:00:10 172.27.15.6 GET /testx/_next/static/css/1203a7972f747562.css X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=3b80b98a-6157-4825-9369-9fa0ff892096&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 4152 348 1
2026-05-19 23:00:10 172.27.15.6 GET /testx/_next/static/chunks/webpack-6283abe281eca2d1.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=334c1da3-9bac-42f2-8a06-63bf2ce5203b&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 2106 343 0
2026-05-19 23:00:10 172.27.15.6 GET /testx/_next/static/chunks/fd9d1056-87da80e0c187477b.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=ee2c098d-a299-4997-9b5c-749e3df8b479&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 54116 344 2
2026-05-19 23:00:10 172.27.15.6 GET /testx/_next/static/chunks/117-cd24e094a43c1bcf.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=48c2cadc-ec3d-45ec-aebd-81e97182e812&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 32241 339 2
2026-05-19 23:00:10 172.27.15.6 GET /testx/_next/static/chunks/main-app-6a17828942593d20.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=47babcf3-cb6b-4a95-a6d3-7a9a327ea1d4&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 807 344 0
2026-05-19 23:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/admin/login/page-671d6df78d1dc1ed.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=b38e0d65-26f0-46e3-b3da-0a047471f9df&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1420 356 1
2026-05-19 23:00:10 172.27.15.6 GET /testx/_next/static/chunks/29-d649f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=a46c9a5a-e87f-44a5-87ff-a754eb82d0c2&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 1
2026-05-19 23:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=cc1db591-0640-4b8f-b3d9-6296f102a4d3&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-19 23:00:10 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e168be15-4873-47f0-a8df-14933c96d1f0&SERVER-STATUS=401 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 401 0 0 287 424 420
```

---
*Auto-generated 2026-05-21 03:00 by `server-b/refresh-server-b-logs.ps1`*

