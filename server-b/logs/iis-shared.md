# Log analysis: iis-shared

> Snapshot: 2026-05-19 03:00  ·  log files modified in last 24h: **2**

## AI Analysis

1) **สถานะรวม**  
ระบบทำงานปกติโดยรวม แต่มีการเกิด error 401 Unauthorized 1 ครั้ง ซึ่งอาจบ่งชี้ปัญหาด้านการตรวจสอบสิทธิ์ (เขียว-เหลือง)

2) **Error/Warning ที่ต้องสนใจ**  
- `401 Unauthorized` ที่ `/testx/api/auth/login` (ไฟล์: `u_ex260518.log`, เวลา: 2026-05-18 19:00:10)  
  ความเสี่ยง: ผู้ใช้ไม่สามารถเข้าสู่ระบบได้ อาจเกิดจากข้อมูลการรับรองไม่ถูกต้องหรือระบบตรวจสอบสิทธิ์มีปัญหา  
- `307 Temporary Redirect` ที่ `/testx/api/auth/logout` (ไฟล์: `u_ex260518.log`, เวลา: 2026-05-18 19:00:09)  
  ความเสี่ยง: อาจเป็นพฤติกรรมปกติ แต่ควรตรวจสอบว่าการ redirect นี้ส่งผลต่อการทำงานจริงหรือไม่

3) **คำแนะนำเบื้องต้น**  
- ตรวจสอบระบบตรวจสอบสิทธิ์ (เช่น ตรวจสอบ token, ค่า config ของ API)  
- ตรวจสอบ log ของ backend service เพิ่มเติมเพื่อหาสาเหตุ 401  
- ทดสอบการเข้าสู่ระบบด้วย credential ที่ถูกต้องเพื่อยืนยันปัญหา  
- ตรวจสอบว่า `307 Redirect` ที่เกิดขึ้นเป็นไปตามที่คาดหรือไม่ (เช่น ตรวจสอบ redirect ไปยัง URL ที่ถูกต้อง)

*(model: Qwen/Qwen3-14B, 2 log files analyzed)*

## Log files seen (24h)

- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260518.log` (2026-05-19 02:00, 31,273,212 bytes)
- `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260517.log` (2026-05-18 07:00, 12,656,040 bytes)

## Raw log excerpts

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260518.log`

```
... [truncated head]
f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=1ed43aac-bf31-4231-b333-865a6f45ef4f&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-18 19:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/layout-e48f3fc146641c64.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=60d1266a-db51-4a5a-8d72-77de9a401f29&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1737 346 0
2026-05-18 19:00:09 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=1a7d6c09-95c0-4880-8e91-259a080ca54c&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 404 415 9
2026-05-18 19:00:09 172.27.15.6 GET /testx/admin/dashboard X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=a08ac002-e16d-4053-ac96-038dfc776e37&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 5437 558 38
2026-05-18 19:00:09 172.27.15.6 GET /testx/_next/static/chunks/app/admin/dashboard/page-81b69b1d54b6432c.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=9588931b-960b-4be3-8f9c-48388ddd8cf4&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/dashboard 200 0 0 1961 449 0
2026-05-18 19:00:09 172.27.15.6 GET /testx/api/auth/logout X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=9929e696-adce-4df2-937d-481eb03edc0b&SERVER-STATUS=307 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 307 0 0 315 511 5
2026-05-18 19:00:09 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=a624bcce-2132-435d-bd60-5c6d753dfef5&SERVER-STATUS=304 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 304 0 0 294 454 5
2026-05-18 19:00:10 172.27.15.6 GET /testx/admin/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=cc7656d0-089c-4970-bc4c-e5475f87a16a&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 - 200 0 0 2903 422 7
2026-05-18 19:00:10 172.27.15.6 GET /testx/_next/static/css/e3f71bc912c93ead.css X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c4816f1c-e5d2-413a-9c8d-f951fffdb6c3&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3956 348 0
2026-05-18 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/webpack-6283abe281eca2d1.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=ad97ba59-49b1-4d0f-bdf3-346d9ab25075&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 2106 343 0
2026-05-18 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/fd9d1056-87da80e0c187477b.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=53e4b568-2d9c-425b-8735-4a4e3ee090ad&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 54116 344 1
2026-05-18 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/main-app-6a17828942593d20.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=7e761bbf-6982-48b5-b283-b6222352506b&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 807 344 1
2026-05-18 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/117-cd24e094a43c1bcf.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=cdc46ddb-ba37-42ca-93ad-ef57c9eca994&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 32241 339 1
2026-05-18 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/admin/login/page-671d6df78d1dc1ed.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=119eb004-4714-4d56-8727-d9506e70a8fc&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1420 356 0
2026-05-18 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/29-d649f84bf7223034.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=1ed43aac-bf31-4231-b333-865a6f45ef4f&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 3801 338 0
2026-05-18 19:00:10 172.27.15.6 GET /testx/_next/static/chunks/app/layout-e48f3fc146641c64.js X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=60d1266a-db51-4a5a-8d72-77de9a401f29&SERVER-STATUS=200 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 200 0 0 1737 346 0
2026-05-18 19:00:10 172.27.15.6 POST /testx/api/auth/login X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=af22e207-c325-4bd8-87d2-26b766aa4819&SERVER-STATUS=401 80 - 172.27.15.6 Mozilla/5.0+(Windows+NT+10.0;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+HeadlessChrome/148.0.7778.96+Safari/537.36 http://172.27.15.6/testx/admin/login 401 0 0 287 424 414
```

### `C:\inetpub\logs\LogFiles\W3SVC1\u_ex260517.log`

```
... [truncated head]
min/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c6de044e-eeee-4886-9d69-f85111310e6c&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 8
2026-05-17 23:59:28 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=dc813883-5030-4b72-8b50-83e52cb75286&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 8
2026-05-17 23:59:29 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=52cda816-d6e7-4de4-a020-56fc9510a3ed&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 8
2026-05-17 23:59:30 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c0243e57-5dd3-4356-bb45-2a468219c8b7&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 6
2026-05-17 23:59:31 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=7e0ba7cb-9bad-4968-bf1c-ba09d4474bdf&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 7
2026-05-17 23:59:32 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=5ad7472d-1d5e-4ed7-aa2f-5f72950446ad&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 6
2026-05-17 23:59:33 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=4246b572-5492-4057-bc66-24e086cc8197&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 8
2026-05-17 23:59:34 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=6e26555b-3ef4-400b-a60d-c0138d4cfe6d&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 9
2026-05-17 23:59:35 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c4d118ef-d7c8-420d-ad14-8c30f80f4cec&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 9
2026-05-17 23:59:36 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=60d0009e-06de-4aab-959c-62ed61c49596&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 7
2026-05-17 23:59:37 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=6b51519a-59fd-44bd-884f-ef3f8bbb43a5&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 9
2026-05-17 23:59:38 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=23ebbf39-9771-40f8-aacd-06d6c6de1435&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 7
2026-05-17 23:59:39 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=f002e4bc-81ef-43fa-882b-f0e0dc2c1690&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 6
2026-05-17 23:59:40 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=6862b74c-0947-4b7e-8965-87577aa33a30&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 8
2026-05-17 23:59:41 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=0952ba5e-74cd-44ac-8234-c461ab8aae42&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 6
2026-05-17 23:59:42 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=2f40b17c-2d06-4177-8ee7-8d7021c6dae0&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 7
2026-05-17 23:59:43 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=c21fe428-5e1f-429e-b4bb-ef745ea93b35&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 6
2026-05-17 23:59:44 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=e9c6de33-3e5b-4b3f-b18c-f1991278647e&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 8
2026-05-17 23:59:45 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=50b1bca1-a8e5-4d0f-921d-297f50bbce52&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 8
2026-05-17 23:59:46 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=37db7ee2-6d0c-4aa0-8339-cb2f3e8e8d25&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 9
2026-05-17 23:59:47 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=4321cfe5-d60f-4344-aa33-afdfb36205d9&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 6
2026-05-17 23:59:48 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=28a75e18-3011-452e-a091-4ed63a8c87c6&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 9
2026-05-17 23:59:49 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=65782178-2bba-4417-a2b9-5185279db76f&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 10
2026-05-17 23:59:50 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=485b841d-68b7-45e0-ba03-eaa43443759d&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 10
2026-05-17 23:59:51 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=917df80b-8acd-44a6-acb8-ac48a8239d72&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 10
2026-05-17 23:59:52 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=8d5d8737-c117-45cb-8271-9e2ff7595f72&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 10
2026-05-17 23:59:53 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=6b66c5f5-3c63-4ea0-a3fe-90ac0cd121bc&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 11
2026-05-17 23:59:54 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=aef25a11-e9ee-402b-a05e-8852bfd997b6&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 6
2026-05-17 23:59:55 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=2f3877d0-5257-47d9-ac6d-b08c20149bb5&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 9
2026-05-17 23:59:56 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=a39307b7-4974-427b-8ede-a9d4b977d1a2&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 7
2026-05-17 23:59:57 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=075cdb78-ed53-4069-853f-a1ccb50a5085&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 9
2026-05-17 23:59:59 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=b526f3f9-0965-4db8-b0ca-7aa1a9603f1b&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 11
2026-05-17 23:59:59 172.27.15.6 GET /lake/admin/mcp X-ARR-CACHE-HIT=0&X-ARR-LOG-ID=abb683ad-9238-49b5-9bec-4042d2c21347&SERVER-STATUS=200 443 - 172.31.171.82 node - 200 0 0 538 476 6
```

---
*Auto-generated 2026-05-19 03:00 by `server-b/refresh-server-b-logs.ps1`*

