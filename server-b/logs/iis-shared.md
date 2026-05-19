# Log analysis: iis-shared

> Snapshot: 2026-05-20 03:00  ·  log files modified in last 24h: **2**

## AI Analysis

1) **สถานะรวม**  
ระบบทำงานปกติโดยรวม ไม่มี error ร้ายแรง แต่มีการเข้าถึงที่ไม่ได้รับอนุญาต (401) และ redirect ชั่วคราว (307) ที่อาจต้องตรวจสอบเพิ่มเติม

2) **Error/Warning ที่ต้องสนใจ**  
- `401 Unauthorized` สำหรับ `POST /testx/api/auth/login` (พบในทั้ง 2 ไฟล์ log)  
  - ไฟล์: `u_ex260519.log`, `u_ex260518.log`  
  - เวลา: 2026-05-19 20:00:10 และ 2026-05-18 23:00:11  
  - ความเสี่ยง: อาจเกี่ยวข้องกับการเข้าสู่ระบบล้มเหลว ควรตรวจสอบ credential หรือ token ที่ใช้  
- `307 Temporary Redirect` สำหรับ `GET /testx/api/auth/logout`  
  - ไฟล์: `u_ex260519.log`, `u_ex260518.log`  
  - เวลา: 2026-05-19 20:00:09 และ 2026-05-18 23:00:09  
  - ความเสี่ยง: อาจเป็นพฤติกรรมปกติ แต่ควรตรวจสอบว่า redirect นี้ถูกต้องตามออกแบบระบบ

3) **คำแนะนำเบื้องต้น**  
- ตรวจสอบระบบการรับรองตัวตน (Authentication) โดยเฉพาะ endpoint `/api/auth/login` ว่ามีการส่ง credential หรือ token ที่ถูกต้อง  
- ตรวจสอบว่า `307 Temporary Redirect` ที่เกิดขึ้นหลัง logout เป็นไปตามที่คาดไว้หรือไม่  
- ดู log ของ backend หรือ application server เพิ่มเติมเพื่อหาสาเหตุของ 401 ที่เกิดขึ้น

*(model: Qwen/Qwen3-14B, 2 log files analyzed)*

## Log files seen (24h)

- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260519.log` (2026-05-20 02:00, 5,554,966 bytes)
- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260518.log` (2026-05-19 06:00, 31,401,492 bytes)

## Raw log excerpts

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260519.log`

```
... [truncated head]
f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=361df459-2f91-4172-b26d-d70cab3628b5&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-19 20:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=1e4d0803-7f5b-4f53-b291-af1eda850719&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-19 20:00:09 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=25960225-da37-42fd-96de-97c20f58ea80&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 404 415 9
2026-05-19 20:00:09 172.27.15.6 GET /testx/admin/dashboard X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=4e71bfa5-a783-40d2-8dc6-a4a1d0ec1ac9&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 5473 558 43
2026-05-19 20:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/admin/dashboard/page-81b69b1d54b6432c.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=afdfb2f2-4e97-44b7-97a2-f40668227a5d&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/dashboard 200 0 0 1961 449 0
2026-05-19 20:00:09 172.27.15.6 GET /testx/api/auth/logout X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=d6d80ead-32f0-4245-8ff7-4d0a579da305&SERVER-STATUS=307 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 307 0 0 315 511 7
2026-05-19 20:00:09 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=4e91d9f3-916c-431d-a6e1-7ae22c1ad1f9&SERVER-STATUS=304 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 304 0 0 294 454 5
2026-05-19 20:00:10 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c970a22f-ac91-46cf-b408-c8f9d69389de&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 200 0 0 2922 422 6
2026-05-19 20:00:10 172.27.15.6 GET /testx/_next/static/css/1203a7972f747562.css X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=446904b4-4a05-4e6c-952f-21caf908251e&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 4152 348 0
2026-05-19 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/webpack-6283abe281eca2d1.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=8b0ce136-e45b-4275-8e8b-bf1c1dfd1fc9&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 2106 343 0
2026-05-19 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/fd9d1056-87da80e0c187477b.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=d16e4f98-d118-4a03-850d-ee72a06737ba&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 54116 344 0
2026-05-19 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/main-app-6a17828942593d20.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=319724ac-96c4-493f-9889-72332647f20d&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 807 344 0
2026-05-19 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/117-cd24e094a43c1bcf.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e63d7789-0ef5-47fb-9d61-03320b581481&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 32241 339 1
2026-05-19 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/29-d649f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=361df459-2f91-4172-b26d-d70cab3628b5&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-19 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/admin/login/page-671d6df78d1dc1ed.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=305ed357-fb92-4ea6-9c3f-65246d7299e2&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1420 356 0
2026-05-19 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=1e4d0803-7f5b-4f53-b291-af1eda850719&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-19 20:00:10 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e2bb7d9d-ea80-4160-858f-74a01790f4d9&SERVER-STATUS=401 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 401 0 0 287 424 419
```

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260518.log`

```
... [truncated head]
4bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=62fd2a99-ba33-4cf1-a1df-46449ba83835&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-18 23:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c45fdb2c-7692-48b5-9a1d-eabd089873ae&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 1
2026-05-18 23:00:09 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=293d0de0-93b7-47af-85bb-a810e26e44f4&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 404 415 13
2026-05-18 23:00:09 172.27.15.6 GET /testx/admin/dashboard X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=673eca4e-d9d7-4941-9abd-f4506e2096f1&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 5706 558 50
2026-05-18 23:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/admin/dashboard/page-81b69b1d54b6432c.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=fe5981ea-bd6d-4a31-8025-d58d63acdc81&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/dashboard 200 0 0 1961 449 0
2026-05-18 23:00:09 172.27.15.6 GET /testx/api/auth/logout X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=ad98c338-efd7-4da3-884f-714b7a3b1e63&SERVER-STATUS=307 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 307 0 0 315 511 9
2026-05-18 23:00:09 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=86cfde18-a9ed-4468-bb61-ba145f7279f8&SERVER-STATUS=304 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 304 0 0 294 454 8
2026-05-18 23:00:11 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=58d8bc3f-17ef-4350-9361-7451473bf90f&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 200 0 0 2922 422 12
2026-05-18 23:00:11 172.27.15.6 GET /testx/_next/static/css/1203a7972f747562.css X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=0adfc843-edbc-433a-bbe1-8c44bc17a478&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 4152 348 1
2026-05-18 23:00:11 172.27.15.6 GET /testx/_next/static/chunks/webpack-6283abe281eca2d1.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=fa2ecc27-6996-4573-b000-4ccddfb5647c&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 2106 343 0
2026-05-18 23:00:11 172.27.15.6 GET /testx/_next/static/chunks/fd9d1056-87da80e0c187477b.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=2800e69b-0f2a-417d-8186-52e9b91284d6&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 54116 344 1
2026-05-18 23:00:11 172.27.15.6 GET /testx/_next/static/chunks/117-cd24e094a43c1bcf.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c8d0a322-4d21-4d58-bc64-71a929dec65b&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 32241 339 1
2026-05-18 23:00:11 172.27.15.6 GET /testx/_next/static/chunks/main-app-6a17828942593d20.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=d216152d-8699-42bc-8919-544c34136caa&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 807 344 0
2026-05-18 23:00:11 172.27.15.6 GET /testx/_next/static/chunks/app/admin/login/page-671d6df78d1dc1ed.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=49b82450-c189-4a2c-ab96-7bfd7d50299c&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1420 356 0
2026-05-18 23:00:11 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c45fdb2c-7692-48b5-9a1d-eabd089873ae&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-18 23:00:11 172.27.15.6 GET /testx/_next/static/chunks/29-d649f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=62fd2a99-ba33-4cf1-a1df-46449ba83835&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-18 23:00:11 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=943900f9-3630-4514-b5e3-32bc167b8567&SERVER-STATUS=401 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 401 0 0 287 424 427
```

---
*Auto-generated 2026-05-20 03:00 by `server-b/refresh-server-b-logs.ps1`*

