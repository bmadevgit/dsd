# Log analysis: lake

> Snapshot: 2026-05-21 03:00  ·  log files modified in last 24h: **3**

## AI Analysis

1) **สถานะรวม**  
ระบบดูปกติจาก watchdog.log ที่บันทึก "health ok" ต่อเนื่อง แต่มี error สำคัญใน bma-lake-error-0.log ที่บ่งชี้ปัญหาการเรียกใช้โมดูล  

2) **Error/Warning ที่ต้องสนใจ**  
- **Error**: `Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'` (เกิดที่ `bma-lake-error-0.log` เวลา 2026-05-20 08:52:27)  
  - **ความเสี่ยงสูง**: โมดูลหลักที่จำเป็นสำหรับการเริ่มต้นเซิร์ฟเวอร์หายไป อาจทำให้ระบบไม่ทำงาน  

3) **คำแนะนำเบื้องต้น**  
- ตรวจสอบว่าไฟล์ `server.js` ใน `C:\inetpub\wwwroot\lake\.next\standalone\` มีอยู่จริงหรือไม่  
- ตรวจสอบกระบวนการ build ของ Next.js ว่าสำเร็จสมบูรณ์หรือไม่  
- ตรวจสอบ path ที่ใช้ใน PM2 หรือ config ที่เกี่ยวข้องว่าถูกต้องหรือไม่  
- ลอง restart บริการหรือ rebuild โปรเจกต์ใหม่หากจำเป็น

*(model: Qwen/Qwen3-14B, 3 log files analyzed)*

## Log files seen (24h)

- `C:\inetpub\lake-data\watchdog.log` (2026-05-21 03:00, 714,539 bytes)
- `C:\inetpub\lake-data\bma-lake-out-0.log` (2026-05-20 09:51, 14,520 bytes)
- `C:\inetpub\lake-data\bma-lake-error-0.log` (2026-05-20 08:52, 174,665 bytes)

## Raw log excerpts

### `C:\inetpub\lake-data\watchdog.log`

```
... [truncated head]
53:02] health ok
[2026-05-20 23:54:02] health ok
[2026-05-20 23:55:02] health ok
[2026-05-20 23:56:02] health ok
[2026-05-20 23:57:02] health ok
[2026-05-20 23:58:02] health ok
[2026-05-20 23:59:02] health ok
[2026-05-21 00:00:02] health ok
[2026-05-21 00:01:02] health ok
[2026-05-21 00:02:02] health ok
[2026-05-21 00:03:02] health ok
[2026-05-21 00:04:02] health ok
[2026-05-21 00:05:02] health ok
[2026-05-21 00:06:02] health ok
[2026-05-21 00:07:02] health ok
[2026-05-21 00:08:02] health ok
[2026-05-21 00:09:02] health ok
[2026-05-21 00:10:02] health ok
[2026-05-21 00:11:02] health ok
[2026-05-21 00:12:02] health ok
[2026-05-21 00:13:02] health ok
[2026-05-21 00:14:02] health ok
[2026-05-21 00:15:02] health ok
[2026-05-21 00:16:02] health ok
[2026-05-21 00:17:02] health ok
[2026-05-21 00:18:02] health ok
[2026-05-21 00:19:02] health ok
[2026-05-21 00:20:02] health ok
[2026-05-21 00:21:02] health ok
[2026-05-21 00:22:02] health ok
[2026-05-21 00:23:02] health ok
[2026-05-21 00:24:02] health ok
[2026-05-21 00:25:02] health ok
[2026-05-21 00:26:02] health ok
[2026-05-21 00:27:02] health ok
[2026-05-21 00:28:02] health ok
[2026-05-21 00:29:02] health ok
[2026-05-21 00:30:02] health ok
[2026-05-21 00:31:02] health ok
[2026-05-21 00:32:02] health ok
[2026-05-21 00:33:02] health ok
[2026-05-21 00:34:01] health ok
[2026-05-21 00:35:01] health ok
[2026-05-21 00:36:01] health ok
[2026-05-21 00:37:01] health ok
[2026-05-21 00:38:01] health ok
[2026-05-21 00:39:01] health ok
[2026-05-21 00:40:01] health ok
[2026-05-21 00:41:01] health ok
[2026-05-21 00:42:01] health ok
[2026-05-21 00:43:01] health ok
[2026-05-21 00:44:01] health ok
[2026-05-21 00:45:01] health ok
[2026-05-21 00:46:01] health ok
[2026-05-21 00:47:01] health ok
[2026-05-21 00:48:01] health ok
[2026-05-21 00:49:01] health ok
[2026-05-21 00:50:01] health ok
[2026-05-21 00:51:01] health ok
[2026-05-21 00:52:01] health ok
[2026-05-21 00:53:01] health ok
[2026-05-21 00:54:01] health ok
[2026-05-21 00:55:01] health ok
[2026-05-21 00:56:01] health ok
[2026-05-21 00:57:01] health ok
[2026-05-21 00:58:01] health ok
[2026-05-21 00:59:01] health ok
[2026-05-21 01:00:01] health ok
[2026-05-21 01:01:01] health ok
[2026-05-21 01:02:01] health ok
[2026-05-21 01:03:01] health ok
[2026-05-21 01:04:01] health ok
[2026-05-21 01:05:01] health ok
[2026-05-21 01:06:01] health ok
[2026-05-21 01:07:01] health ok
[2026-05-21 01:08:01] health ok
[2026-05-21 01:09:01] health ok
[2026-05-21 01:10:01] health ok
[2026-05-21 01:11:01] health ok
[2026-05-21 01:12:01] health ok
[2026-05-21 01:13:01] health ok
[2026-05-21 01:14:01] health ok
[2026-05-21 01:15:01] health ok
[2026-05-21 01:16:01] health ok
[2026-05-21 01:17:01] health ok
[2026-05-21 01:18:01] health ok
[2026-05-21 01:19:01] health ok
[2026-05-21 01:20:01] health ok
[2026-05-21 01:21:01] health ok
[2026-05-21 01:22:01] health ok
[2026-05-21 01:23:01] health ok
[2026-05-21 01:24:02] health ok
[2026-05-21 01:25:02] health ok
[2026-05-21 01:26:01] health ok
[2026-05-21 01:27:01] health ok
[2026-05-21 01:28:01] health ok
[2026-05-21 01:29:01] health ok
[2026-05-21 01:30:02] health ok
[2026-05-21 01:31:02] health ok
[2026-05-21 01:32:02] health ok
[2026-05-21 01:33:02] health ok
[2026-05-21 01:34:02] health ok
[2026-05-21 01:35:02] health ok
[2026-05-21 01:36:02] health ok
[2026-05-21 01:37:02] health ok
[2026-05-21 01:38:02] health ok
[2026-05-21 01:39:02] health ok
[2026-05-21 01:40:02] health ok
[2026-05-21 01:41:02] health ok
[2026-05-21 01:42:02] health ok
[2026-05-21 01:43:02] health ok
[2026-05-21 01:44:02] health ok
[2026-05-21 01:45:02] health ok
[2026-05-21 01:46:02] health ok
[2026-05-21 01:47:02] health ok
[2026-05-21 01:48:02] health ok
[2026-05-21 01:49:02] health ok
[2026-05-21 01:50:02] health ok
[2026-05-21 01:51:02] health ok
[2026-05-21 01:52:02] health ok
[2026-05-21 01:53:02] health ok
[2026-05-21 01:54:02] health ok
[2026-05-21 01:55:02] health ok
[2026-05-21 01:56:02] health ok
[2026-05-21 01:57:02] health ok
[2026-05-21 01:58:02] health ok
[2026-05-21 01:59:02] health ok
[2026-05-21 02:00:02] health ok
[2026-05-21 02:01:02] health ok
[2026-05-21 02:02:02] health ok
[2026-05-21 02:03:02] health ok
[2026-05-21 02:04:02] health ok
[2026-05-21 02:05:02] health ok
[2026-05-21 02:06:02] health ok
[2026-05-21 02:07:02] health ok
[2026-05-21 02:08:02] health ok
[2026-05-21 02:09:02] health ok
[2026-05-21 02:10:02] health ok
[2026-05-21 02:11:02] health ok
[2026-05-21 02:12:02] health ok
[2026-05-21 02:13:02] health ok
[2026-05-21 02:14:01] health ok
[2026-05-21 02:15:01] health ok
[2026-05-21 02:16:01] health ok
[2026-05-21 02:17:01] health ok
[2026-05-21 02:18:01] health ok
[2026-05-21 02:19:01] health ok
[2026-05-21 02:20:01] health ok
[2026-05-21 02:21:01] health ok
[2026-05-21 02:22:01] health ok
[2026-05-21 02:23:01] health ok
[2026-05-21 02:24:01] health ok
[2026-05-21 02:25:01] health ok
[2026-05-21 02:26:01] health ok
[2026-05-21 02:27:01] health ok
[2026-05-21 02:28:01] health ok
[2026-05-21 02:29:01] health ok
[2026-05-21 02:30:01] health ok
[2026-05-21 02:31:01] health ok
[2026-05-21 02:32:01] health ok
[2026-05-21 02:33:01] health ok
[2026-05-21 02:34:01] health ok
[2026-05-21 02:35:01] health ok
[2026-05-21 02:36:01] health ok
[2026-05-21 02:37:01] health ok
[2026-05-21 02:38:01] health ok
[2026-05-21 02:39:01] health ok
[2026-05-21 02:40:01] health ok
[2026-05-21 02:41:01] health ok
[2026-05-21 02:42:01] health ok
[2026-05-21 02:43:01] health ok
[2026-05-21 02:44:01] health ok
[2026-05-21 02:45:01] health ok
[2026-05-21 02:46:01] health ok
[2026-05-21 02:47:01] health ok
[2026-05-21 02:48:01] health ok
[2026-05-21 02:49:01] health ok
[2026-05-21 02:50:01] health ok
[2026-05-21 02:51:01] health ok
[2026-05-21 02:52:01] health ok
[2026-05-21 02:53:01] health ok
[2026-05-21 02:54:01] health ok
[2026-05-21 02:55:01] health ok
[2026-05-21 02:56:01] health ok
[2026-05-21 02:57:01] health ok
[2026-05-21 02:58:01] health ok
[2026-05-21 02:59:01] health ok
[2026-05-21 03:00:02] health ok
```

### `C:\inetpub\lake-data\bma-lake-out-0.log`

```
... [truncated head]
al:        http://localhost:3000
2026-05-11 21:41:31:   - Network:      http://0.0.0.0:3000
2026-05-11 21:41:31: 
2026-05-11 21:41:31:  âœ“ Starting...
2026-05-11 21:41:32:  âœ“ Ready in 128ms
2026-05-11 21:43:24:   â–² Next.js 14.2.29
2026-05-11 21:43:24:   - Local:        http://localhost:3000
2026-05-11 21:43:24:   - Network:      http://0.0.0.0:3000
2026-05-11 21:43:24: 
2026-05-11 21:43:24:  âœ“ Starting...
2026-05-11 21:43:24:  âœ“ Ready in 161ms
2026-05-12 05:15:47:   â–² Next.js 14.2.29
2026-05-12 05:15:47:   - Local:        http://localhost:3000
2026-05-12 05:15:47:   - Network:      http://0.0.0.0:3000
2026-05-12 05:15:47: 
2026-05-12 05:15:47:  âœ“ Starting...
2026-05-12 05:15:47:  âœ“ Ready in 122ms
2026-05-12 05:23:43:   â–² Next.js 14.2.29
2026-05-12 05:23:43:   - Local:        http://localhost:3000
2026-05-12 05:23:43:   - Network:      http://0.0.0.0:3000
2026-05-12 05:23:43: 
2026-05-12 05:23:43:  âœ“ Starting...
2026-05-12 05:23:44:  âœ“ Ready in 165ms
2026-05-12 05:25:50:   â–² Next.js 14.2.29
2026-05-12 05:25:50:   - Local:        http://localhost:3000
2026-05-12 05:25:50:   - Network:      http://0.0.0.0:3000
2026-05-12 05:25:50: 
2026-05-12 05:25:50:  âœ“ Starting...
2026-05-12 05:25:50:  âœ“ Ready in 110ms
2026-05-12 05:32:02:   â–² Next.js 14.2.29
2026-05-12 05:32:02:   - Local:        http://localhost:3000
2026-05-12 05:32:02:   - Network:      http://0.0.0.0:3000
2026-05-12 05:32:02: 
2026-05-12 05:32:02:  âœ“ Starting...
2026-05-12 05:32:02:  âœ“ Ready in 143ms
2026-05-13 10:05:51:   â–² Next.js 14.2.29
2026-05-13 10:05:51:   - Local:        http://localhost:3000
2026-05-13 10:05:51:   - Network:      http://0.0.0.0:3000
2026-05-13 10:05:51: 
2026-05-13 10:05:51:  âœ“ Starting...
2026-05-13 10:05:51:  âœ“ Ready in 137ms
2026-05-13 10:08:56:   â–² Next.js 14.2.29
2026-05-13 10:08:56:   - Local:        http://localhost:3000
2026-05-13 10:08:56:   - Network:      http://0.0.0.0:3000
2026-05-13 10:08:56: 
2026-05-13 10:08:56:  âœ“ Starting...
2026-05-13 10:08:56:  âœ“ Ready in 127ms
2026-05-13 10:30:28:   â–² Next.js 14.2.29
2026-05-13 10:30:28:   - Local:        http://localhost:3000
2026-05-13 10:30:28:   - Network:      http://0.0.0.0:3000
2026-05-13 10:30:28: 
2026-05-13 10:30:28:  âœ“ Starting...
2026-05-13 10:30:28:  âœ“ Ready in 177ms
2026-05-13 10:50:23:   â–² Next.js 14.2.29
2026-05-13 10:50:23:   - Local:        http://localhost:3000
2026-05-13 10:50:23:   - Network:      http://0.0.0.0:3000
2026-05-13 10:50:23: 
2026-05-13 10:50:23:  âœ“ Starting...
2026-05-13 10:50:23:  âœ“ Ready in 133ms
2026-05-13 10:50:24:   â–² Next.js 14.2.29
2026-05-13 10:50:24:   - Local:        http://localhost:3000
2026-05-13 10:50:24:   - Network:      http://0.0.0.0:3000
2026-05-13 10:50:24: 
2026-05-13 10:50:24:  âœ“ Starting...
2026-05-13 10:50:24:  âœ“ Ready in 108ms
2026-05-14 22:33:04:   â–² Next.js 14.2.29
2026-05-14 22:33:04:   - Local:        http://localhost:3000
2026-05-14 22:33:04:   - Network:      http://0.0.0.0:3000
2026-05-14 22:33:04: 
2026-05-14 22:33:04:  âœ“ Starting...
2026-05-14 22:33:04:  âœ“ Ready in 159ms
2026-05-15 05:13:05:   â–² Next.js 14.2.29
2026-05-15 05:13:05:   - Local:        http://localhost:3000
2026-05-15 05:13:05:   - Network:      http://0.0.0.0:3000
2026-05-15 05:13:05: 
2026-05-15 05:13:05:  âœ“ Starting...
2026-05-15 05:13:05:  âœ“ Ready in 113ms
2026-05-16 23:59:31:   â–² Next.js 14.2.29
2026-05-16 23:59:31:   - Local:        http://localhost:3000
2026-05-16 23:59:31:   - Network:      http://0.0.0.0:3000
2026-05-16 23:59:31: 
2026-05-16 23:59:31:  âœ“ Starting...
2026-05-16 23:59:31:  âœ“ Ready in 273ms
2026-05-17 11:03:37:   â–² Next.js 14.2.29
2026-05-17 11:03:37:   - Local:        http://localhost:3000
2026-05-17 11:03:37:   - Network:      http://0.0.0.0:3000
2026-05-17 11:03:37: 
2026-05-17 11:03:37:  âœ“ Starting...
2026-05-17 11:03:37:  âœ“ Ready in 207ms
2026-05-19 14:47:42:   â–² Next.js 14.2.29
2026-05-19 14:47:42:   - Local:        http://localhost:3000
2026-05-19 14:47:42:   - Network:      http://0.0.0.0:3000
2026-05-19 14:47:42: 
2026-05-19 14:47:42:  âœ“ Starting...
2026-05-19 14:47:42:  âœ“ Ready in 158ms
2026-05-19 15:08:14:   â–² Next.js 14.2.29
2026-05-19 15:08:14:   - Local:        http://localhost:3000
2026-05-19 15:08:14:   - Network:      http://0.0.0.0:3000
2026-05-19 15:08:14: 
2026-05-19 15:08:14:  âœ“ Starting...
2026-05-19 15:08:14:  âœ“ Ready in 124ms
2026-05-19 18:03:11:   â–² Next.js 14.2.29
2026-05-19 18:03:11:   - Local:        http://localhost:3000
2026-05-19 18:03:11:   - Network:      http://0.0.0.0:3000
2026-05-19 18:03:11: 
2026-05-19 18:03:11:  âœ“ Starting...
2026-05-19 18:03:11:  âœ“ Ready in 131ms
2026-05-20 08:52:04:   â–² Next.js 14.2.29
2026-05-20 08:52:04:   - Local:        http://localhost:3000
2026-05-20 08:52:04:   - Network:      http://0.0.0.0:3000
2026-05-20 08:52:04: 
2026-05-20 08:52:04:  âœ“ Starting...
2026-05-20 08:52:05:  âœ“ Ready in 130ms
2026-05-20 08:52:47:   â–² Next.js 14.2.29
2026-05-20 08:52:47:   - Local:        http://localhost:3000
2026-05-20 08:52:47:   - Network:      http://0.0.0.0:3000
2026-05-20 08:52:47: 
2026-05-20 08:52:47:  âœ“ Starting...
2026-05-20 08:52:47:  âœ“ Ready in 147ms
2026-05-20 09:51:36:   â–² Next.js 14.2.29
2026-05-20 09:51:36:   - Local:        http://localhost:3000
2026-05-20 09:51:36:   - Network:      http://0.0.0.0:3000
2026-05-20 09:51:36: 
2026-05-20 09:51:36:  âœ“ Starting...
2026-05-20 09:51:36:  âœ“ Ready in 141ms
2026-05-20 09:51:55:   â–² Next.js 14.2.29
2026-05-20 09:51:55:   - Local:        http://localhost:3000
2026-05-20 09:51:55:   - Network:      http://0.0.0.0:3000
2026-05-20 09:51:55: 
2026-05-20 09:51:55:  âœ“ Starting...
2026-05-20 09:51:55:  âœ“ Ready in 161ms
2026-05-20 09:52:17:   â–² Next.js 14.2.29
2026-05-20 09:52:17:   - Local:        http://localhost:3000
2026-05-20 09:52:17:   - Network:      http://0.0.0.0:3000
2026-05-20 09:52:17: 
2026-05-20 09:52:17:  âœ“ Starting...
2026-05-20 09:52:17:  âœ“ Ready in 130ms
```

### `C:\inetpub\lake-data\bma-lake-error-0.log`

```
... [truncated head]
b\ProcessContainerFork.js:33:23)
2026-05-20 08:52:27:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-20 08:52:27:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-20 08:52:27:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-20 08:52:27:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-20 08:52:27:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-20 08:52:27:     at node:internal/main/run_main_module:28:49 {
2026-05-20 08:52:27:   code: 'MODULE_NOT_FOUND',
2026-05-20 08:52:27:   requireStack: []
2026-05-20 08:52:27: }
2026-05-20 08:52:30: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-20 08:52:30:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-20 08:52:30:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-20 08:52:30:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-20 08:52:30:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-20 08:52:30:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-20 08:52:30:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-20 08:52:30:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-20 08:52:30:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-20 08:52:30:     at node:internal/main/run_main_module:28:49 {
2026-05-20 08:52:30:   code: 'MODULE_NOT_FOUND',
2026-05-20 08:52:30:   requireStack: []
2026-05-20 08:52:30: }
2026-05-20 08:52:34: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-20 08:52:34:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-20 08:52:34:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-20 08:52:34:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-20 08:52:34:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-20 08:52:34:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-20 08:52:34:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-20 08:52:34:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-20 08:52:34:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-20 08:52:34:     at node:internal/main/run_main_module:28:49 {
2026-05-20 08:52:34:   code: 'MODULE_NOT_FOUND',
2026-05-20 08:52:34:   requireStack: []
2026-05-20 08:52:34: }
2026-05-20 08:52:37: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-20 08:52:37:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-20 08:52:37:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-20 08:52:37:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-20 08:52:37:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-20 08:52:37:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-20 08:52:37:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-20 08:52:37:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-20 08:52:37:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-20 08:52:37:     at node:internal/main/run_main_module:28:49 {
2026-05-20 08:52:37:   code: 'MODULE_NOT_FOUND',
2026-05-20 08:52:37:   requireStack: []
2026-05-20 08:52:37: }
2026-05-20 08:52:40: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-20 08:52:40:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-20 08:52:40:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-20 08:52:40:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-20 08:52:40:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-20 08:52:40:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-20 08:52:40:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-20 08:52:40:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-20 08:52:40:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-20 08:52:40:     at node:internal/main/run_main_module:28:49 {
2026-05-20 08:52:40:   code: 'MODULE_NOT_FOUND',
2026-05-20 08:52:40:   requireStack: []
2026-05-20 08:52:40: }
2026-05-20 08:52:43: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-20 08:52:43:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-20 08:52:43:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-20 08:52:43:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-20 08:52:43:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-20 08:52:43:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-20 08:52:43:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-20 08:52:43:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-20 08:52:43:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-20 08:52:43:     at node:internal/main/run_main_module:28:49 {
2026-05-20 08:52:43:   code: 'MODULE_NOT_FOUND',
2026-05-20 08:52:43:   requireStack: []
2026-05-20 08:52:43: }
```

---
*Auto-generated 2026-05-21 03:00 by `server-b/refresh-server-b-logs.ps1`*

