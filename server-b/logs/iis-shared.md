# Log analysis: iis-shared

> Snapshot: 2026-05-23 03:00  ·  log files modified in last 24h: **2**

## AI Analysis

1) **สถานะรวม**  
ระบบทำงานปกติโดยรวม ไม่มี error ร้ายแรง แต่มีการเข้าถึงที่ไม่ได้รับอนุญาต (401) บางครั้ง

2) **Error/Warning ที่ต้องสนใจ**  
- `401 Unauthorized` พบ 2 ครั้ง:  
  - `2026-05-22 20:00:11` ที่ `/testx/api/auth/login` (ไฟล์ `u_ex260522.log`)  
  - `2026-05-21 23:58:56` ที่ `/s2t/api.php` (ไฟล์ `u_ex260521.log`)  
  **ความเสี่ยง**: อาจเกี่ยวกับการรับรองตัวตนผิดพลาดหรือ session หมดอายุ  
- `307 Temporary Redirect` ที่ `/testx/api/auth/logout` (ไฟล์ `u_ex260522.log`)  
  **ความเสี่ยง**: อาจเป็นพฤติกรรมปกติ แต่ควรตรวจสอบว่าไม่ส่งผลต่อการทำงาน

3) **คำแนะนำเบื้องต้น**  
- ตรวจสอบการตั้งค่า authentication และ session ของ application  
- ตรวจสอบ log ของ backend service ที่รับคำขอ `/api/auth/login` และ `/api.php` เพื่อหาสาเหตุ 401  
- ทดสอบ login ด้วย credential ที่ถูกต้องเพื่อยืนยันปัญหา  
- ไม่จำเป็นต้อง restart service เว้นแต่จะมีการเปลี่ยนแปลง config ที่เกี่ยวข้อง

*(model: Qwen/Qwen3-14B, 2 log files analyzed)*

## Log files seen (24h)

- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260522.log` (2026-05-23 02:00, 922,486 bytes)
- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260521.log` (2026-05-22 07:00, 2,389,410 bytes)

## Raw log excerpts

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260522.log`

```
... [truncated head]
f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=fff4afaa-0849-40c6-b5a2-5f98c4c90ce7&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-22 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=f679158c-eefb-4a0a-b54f-5dbc62f435aa&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-22 20:00:10 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=2e4a51ad-034e-4aef-b4ba-d36823d0c536&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 404 415 8
2026-05-22 20:00:10 172.27.15.6 GET /testx/admin/dashboard X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=4cc6d332-f635-463b-ae3c-62502e4fd531&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 5699 558 43
2026-05-22 20:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/admin/dashboard/page-81b69b1d54b6432c.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=590d7998-f523-4b05-b754-2ec4bd0deb2f&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/dashboard 200 0 0 1961 449 0
2026-05-22 20:00:10 172.27.15.6 GET /testx/api/auth/logout X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c9feca2c-dd21-4cee-9358-045bca0e77e7&SERVER-STATUS=307 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 307 0 0 315 511 6
2026-05-22 20:00:10 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=2a54d8bb-1134-4291-bb6c-b5ffd60a7b35&SERVER-STATUS=304 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 304 0 0 295 455 5
2026-05-22 20:00:11 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=4c3c53c5-39ab-465d-9afd-d9db3af35dbf&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 200 0 0 2923 422 7
2026-05-22 20:00:11 172.27.15.6 GET /testx/_next/static/css/9b8b8b7c90a3550d.css X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e83eadb3-ed51-4d1b-8313-1cf60f6fb52c&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 4215 348 0
2026-05-22 20:00:11 172.27.15.6 GET /testx/_next/static/chunks/webpack-6283abe281eca2d1.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=006ad134-75cd-42f4-acad-0ad6c5e29e8c&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 2106 343 0
2026-05-22 20:00:11 172.27.15.6 GET /testx/_next/static/chunks/fd9d1056-87da80e0c187477b.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=827a63c7-3646-4d7b-b1fe-fd5c963632e2&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 54116 344 0
2026-05-22 20:00:11 172.27.15.6 GET /testx/_next/static/chunks/117-cd24e094a43c1bcf.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=8ce322e3-7d16-4c94-9f4d-c6080f1c7092&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 32241 339 1
2026-05-22 20:00:11 172.27.15.6 GET /testx/_next/static/chunks/main-app-6a17828942593d20.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=033c288f-709c-4f2c-b50f-b6ac2a6d1222&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 807 344 0
2026-05-22 20:00:11 172.27.15.6 GET /testx/_next/static/chunks/app/layout-8fc9b676daa4a2c6.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=f679158c-eefb-4a0a-b54f-5dbc62f435aa&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1757 346 0
2026-05-22 20:00:11 172.27.15.6 GET /testx/_next/static/chunks/29-d649f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=fff4afaa-0849-40c6-b5a2-5f98c4c90ce7&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-22 20:00:11 172.27.15.6 GET /testx/_next/static/chunks/app/admin/login/page-671d6df78d1dc1ed.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=9d1b77b6-d390-44e0-8f08-09a1d56ac072&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1420 356 0
2026-05-22 20:00:11 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=21136435-30e1-44e6-9717-8e5913cea6e4&SERVER-STATUS=401 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 401 0 0 287 424 410
```

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260521.log`

```
... [truncated head]
+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 81
2026-05-21 23:52:39 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 208
2026-05-21 23:52:39 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 21249 654 962
2026-05-21 23:53:39 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 21249 654 105
2026-05-21 23:53:39 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 142
2026-05-21 23:54:39 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 21249 654 55
2026-05-21 23:54:39 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 183
2026-05-21 23:55:39 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 21249 654 51
2026-05-21 23:55:39 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 94
2026-05-21 23:56:39 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 92
2026-05-21 23:56:39 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 21249 654 99
2026-05-21 23:57:39 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 106
2026-05-21 23:57:39 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 21249 654 106
2026-05-21 23:58:39 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 143
2026-05-21 23:58:39 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 21249 654 147
2026-05-21 23:58:56 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/605.1.15+(KHTML,+like+Gecko)+Version/26.3.1+Safari/605.1.15 http://100.77.204.6/s2t/dashboard.php 401 0 0 405 427 51
2026-05-21 23:58:56 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/605.1.15+(KHTML,+like+Gecko)+Version/26.3.1+Safari/605.1.15 http://100.77.204.6/s2t/dashboard.php 401 0 0 405 422 45
2026-05-21 23:58:58 100.77.204.6 GET /s2t/dashboard.php - 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/605.1.15+(KHTML,+like+Gecko)+Version/26.3.1+Safari/605.1.15 http://100.77.204.6/s2t/ 302 0 0 431 445 47
2026-05-21 23:58:58 100.77.204.6 GET /s2t/login.php next=%2Fs2t%2Fdashboard.php 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/605.1.15+(KHTML,+like+Gecko)+Version/26.3.1+Safari/605.1.15 http://100.77.204.6/s2t/ 200 0 0 7305 469 76
2026-05-21 23:59:13 100.77.204.6 POST /s2t/login.php next=%2Fs2t%2Fdashboard.php 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/605.1.15+(KHTML,+like+Gecko)+Version/26.3.1+Safari/605.1.15 http://100.77.204.6/s2t/login.php?next=%2Fs2t%2Fdashboard.php 200 0 0 7606 698 73
2026-05-21 23:59:26 100.77.204.6 POST /s2t/login.php next=%2Fs2t%2Fdashboard.php 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/605.1.15+(KHTML,+like+Gecko)+Version/26.3.1+Safari/605.1.15 http://100.77.204.6/s2t/login.php?next=%2Fs2t%2Fdashboard.php 200 0 0 7606 702 77
2026-05-21 23:59:39 100.77.204.6 GET /s2t/api.php action=changelog 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 21249 654 47
2026-05-21 23:59:39 100.77.204.6 GET /s2t/api.php action=dashboard_data 80 - 100.105.26.99 Mozilla/5.0+(Macintosh;+Intel+Mac+OS+X+10_15_7)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/148.0.0.0+Safari/537.36 http://100.77.204.6/s2t/dashboard.php 200 0 0 23703 659 112
```

---
*Auto-generated 2026-05-23 03:00 by `server-b/refresh-server-b-logs.ps1`*

