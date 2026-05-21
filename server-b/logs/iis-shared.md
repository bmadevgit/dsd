# Log analysis: iis-shared

> Snapshot: 2026-05-22 03:00  ·  log files modified in last 24h: **2**

## AI Analysis

1) **สถานะรวม**  
ระบบมีสถานะปกติโดยรวม แต่มี error บางส่วนที่ต้องตรวจสอบเพิ่มเติม (สีเหลือง)

2) **Error/Warning ที่ต้องสนใจ**  
- `401 Unauthorized` ที่ `/testx/api/auth/login` (ไฟล์ `u_ex260521.log` เวลา 2026-05-21 19:00:10)  
  ความเสี่ยง: อาจเกิดจากข้อมูลการเข้าสู่ระบบผิด หรือปัญหาด้านเซิร์ฟเวอร์  
- `502 Bad Gateway` ที่ `/na/api/health` (ไฟล์ `u_ex260520.log` เวลา 2026-05-20 23:31:46)  
  ความเสี่ยง: อาจเกิดจาก backend service ล้มเหลว หรือการตั้งค่า proxy ผิดพลาด  
- `307 Temporary Redirect` ที่ `/testx/api/auth/logout` (ไฟล์ `u_ex260521.log` เวลา 2026-05-21 19:00:09)  
  ความเสี่ยง: อาจเป็นพฤติกรรมปกติ แต่ควรตรวจสอบว่า redirect ถูกต้องหรือไม่

3) **คำแนะนำเบื้องต้น**  
- ตรวจสอบระบบการรับรองความถูกต้อง (authentication) สำหรับ endpoint `/testx/api/auth/login`  
- ตรวจสอบ backend service ที่เชื่อมต่อกับ `/na/api/health` และตรวจสอบการตั้งค่า proxy  
- ตรวจสอบว่า `307 Temporary Redirect` ที่ `/testx/api/auth/logout` เป็นไปตามที่คาดไว้หรือไม่  
- ดู log ของ application server (เช่น IIS, Node.js, หรือ backend service) เพิ่มเติมเพื่อหาสาเหตุของ 401 และ 502

*(model: Qwen/Qwen3-14B, 2 log files analyzed)*

## Log files seen (24h)

- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260521.log` (2026-05-22 02:00, 2,272,254 bytes)
- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260520.log` (2026-05-21 06:55, 1,098,427 bytes)

## Raw log excerpts

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260521.log`

```
... [truncated head]
84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=6bdf2da2-cc11-47e7-ab6e-3fed0a531ad9&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-21 19:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=66763368-38ed-4a91-9983-4e07b82c1e35&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-21 19:00:09 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=f41dc633-3512-41fe-a8f6-c2d7adef9435&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 404 415 10
2026-05-21 19:00:09 172.27.15.6 GET /testx/admin/dashboard X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=9dade872-94aa-493a-a7c1-b85d1f16bfa2&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 5566 558 43
2026-05-21 19:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/admin/dashboard/page-81b69b1d54b6432c.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=a47fcc4e-f1d0-4719-9e44-1e8ee0923b9c&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/dashboard 200 0 0 1961 449 0
2026-05-21 19:00:09 172.27.15.6 GET /testx/api/auth/logout X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e73996db-9fba-4fd6-941d-6377550db9ae&SERVER-STATUS=307 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 307 0 0 315 511 5
2026-05-21 19:00:09 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=b42e426e-fe27-4537-9b40-7d2a31c773a3&SERVER-STATUS=304 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 304 0 0 295 455 4
2026-05-21 19:00:10 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=7d3688b3-47c6-4b56-baf0-d4bdabc35b95&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 200 0 0 2923 422 7
2026-05-21 19:00:10 172.27.15.6 GET /testx/_next/static/css/9b8b8b7c90a3550d.css X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=5789d4bf-bb1e-468e-be7b-2a2b3fc5ecc0&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 4215 348 0
2026-05-21 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/webpack-6283abe281eca2d1.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=3ab35c24-9e20-4de4-84d1-427eba8a024b&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 2106 343 0
2026-05-21 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/fd9d1056-87da80e0c187477b.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=24a8e151-7302-4064-9058-c7682b8fc5b9&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 54116 344 1
2026-05-21 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/117-cd24e094a43c1bcf.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=0db5efef-3737-41bc-bd2b-ffb6a928b3ee&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 32241 339 1
2026-05-21 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/main-app-6a17828942593d20.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=86ca6c85-6bed-4618-9cda-337ebe2fc3a0&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 807 344 0
2026-05-21 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/admin/login/page-671d6df78d1dc1ed.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=2988a15c-d314-4f58-9441-6c2e8a1d430c&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1420 356 0
2026-05-21 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/29-d649f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=6bdf2da2-cc11-47e7-ab6e-3fed0a531ad9&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-21 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=66763368-38ed-4a91-9983-4e07b82c1e35&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-21 19:00:10 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=42d10831-421b-46cc-ac3b-1dce114e9fd5&SERVER-STATUS=401 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 401 0 0 287 424 409
```

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260520.log`

```
... [truncated head]
Kit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 160
2026-05-20 23:28:03 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 59
2026-05-20 23:28:08 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 124
2026-05-20 23:28:13 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 60
2026-05-20 23:28:18 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 68
2026-05-20 23:28:23 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 55
2026-05-20 23:29:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 62
2026-05-20 23:30:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 49
2026-05-20 23:31:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 43
2026-05-20 23:31:46 172.27.15.6 GET /na/api/health X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=75f756ca-7b7d-42a5-adbb-e394f255bd23 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT;+Windows+NT+10.0;+en-US)+WindowsPowerShell/5.1.17763.8755 - 502 3 12029 4928 169 1042
2026-05-20 23:32:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 71
2026-05-20 23:33:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 147
2026-05-20 23:34:11 172.27.15.6 GET /na/api/buildings/summary X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=08794fc4-e11c-45f2-a3f8-587399c888e8&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT;+Windows+NT+10.0;+en-US)+WindowsPowerShell/5.1.17763.8755 - 200 0 0 494 180 2294
2026-05-20 23:34:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 69
2026-05-20 23:35:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 57
2026-05-20 23:36:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 42
2026-05-20 23:37:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 49
2026-05-20 23:38:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 59
2026-05-20 23:39:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 62
2026-05-20 23:40:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 52
2026-05-20 23:41:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 52
2026-05-20 23:42:22 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 69
2026-05-20 23:55:24 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 20673 607 144
```

---
*Auto-generated 2026-05-22 03:00 by `server-b/refresh-server-b-logs.ps1`*

