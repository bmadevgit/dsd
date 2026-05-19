# Log analysis: lake

> Snapshot: 2026-05-20 03:00  ·  log files modified in last 24h: **3**

## AI Analysis

1) **สถานะรวม**  
ระบบดูปกติจาก watchdog.log ที่บันทึก "health ok" ตลอดเวลา แต่มี error สำคัญใน bma-lake-error-0.log ที่อาจส่งผลต่อการทำงาน

2) **Error/Warning ที่ต้องสนใจ**  
- **[2026-05-19 15:08:04]**: `Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'`  
  ไฟล์: `bma-lake-error-0.log`  
  ความเสี่ยง: สูง อาจทำให้แอปไม่สามารถเริ่มต้นได้ เนื่องจากหาไฟล์ server.js ไม่เจอ  
- **[2026-05-15 08:56:40]**: `Connection terminated unexpectedly`  
  ไฟล์: `bma-lake-error-0.log`  
  ความเสี่ยง: ปานกลาง อาจเกี่ยวข้องกับปัญหาฐานข้อมูล PostgreSQL ชั่วคราว

3) **คำแนะนำเบื้องต้น**  
- ตรวจสอบว่าไฟล์ `server.js` ใน `C:\inetpub\wwwroot\lake\.next\standalone\` มีอยู่จริงและไม่ถูกลบ/ย้าย  
- รีสตาร์ทบริการหรือ rebuild โปรเจกต์หากมีการเปลี่ยนแปลงโครงสร้าง  
- ตรวจสอบการเชื่อมต่อฐานข้อมูล PostgreSQL ว่ามีปัญหาซ้ำหรือไม่

*(model: Qwen/Qwen3-14B, 3 log files analyzed)*

## Log files seen (24h)

- `C:\inetpub\lake-data\watchdog.log` (2026-05-20 03:00, 666,450 bytes)
- `C:\inetpub\lake-data\bma-lake-error-0.log` (2026-05-19 18:03, 160,714 bytes)
- `C:\inetpub\lake-data\bma-lake-out-0.log` (2026-05-19 15:08, 13,200 bytes)

## Raw log excerpts

### `C:\inetpub\lake-data\watchdog.log`

```
... [truncated head]
53:01] health ok
[2026-05-19 23:54:01] health ok
[2026-05-19 23:55:01] health ok
[2026-05-19 23:56:01] health ok
[2026-05-19 23:57:01] health ok
[2026-05-19 23:58:01] health ok
[2026-05-19 23:59:01] health ok
[2026-05-20 00:00:01] health ok
[2026-05-20 00:01:02] health ok
[2026-05-20 00:02:01] health ok
[2026-05-20 00:03:01] health ok
[2026-05-20 00:04:01] health ok
[2026-05-20 00:05:01] health ok
[2026-05-20 00:06:01] health ok
[2026-05-20 00:07:01] health ok
[2026-05-20 00:08:02] health ok
[2026-05-20 00:09:02] health ok
[2026-05-20 00:10:01] health ok
[2026-05-20 00:11:02] health ok
[2026-05-20 00:12:02] health ok
[2026-05-20 00:13:02] health ok
[2026-05-20 00:14:02] health ok
[2026-05-20 00:15:02] health ok
[2026-05-20 00:16:02] health ok
[2026-05-20 00:17:02] health ok
[2026-05-20 00:18:02] health ok
[2026-05-20 00:19:02] health ok
[2026-05-20 00:20:02] health ok
[2026-05-20 00:21:02] health ok
[2026-05-20 00:22:02] health ok
[2026-05-20 00:23:02] health ok
[2026-05-20 00:24:02] health ok
[2026-05-20 00:25:02] health ok
[2026-05-20 00:26:02] health ok
[2026-05-20 00:27:02] health ok
[2026-05-20 00:28:02] health ok
[2026-05-20 00:29:02] health ok
[2026-05-20 00:30:02] health ok
[2026-05-20 00:31:02] health ok
[2026-05-20 00:32:02] health ok
[2026-05-20 00:33:02] health ok
[2026-05-20 00:34:02] health ok
[2026-05-20 00:35:02] health ok
[2026-05-20 00:36:02] health ok
[2026-05-20 00:37:02] health ok
[2026-05-20 00:38:02] health ok
[2026-05-20 00:39:02] health ok
[2026-05-20 00:40:02] health ok
[2026-05-20 00:41:02] health ok
[2026-05-20 00:42:02] health ok
[2026-05-20 00:43:02] health ok
[2026-05-20 00:44:02] health ok
[2026-05-20 00:45:02] health ok
[2026-05-20 00:46:02] health ok
[2026-05-20 00:47:02] health ok
[2026-05-20 00:48:02] health ok
[2026-05-20 00:49:02] health ok
[2026-05-20 00:50:02] health ok
[2026-05-20 00:51:02] health ok
[2026-05-20 00:52:02] health ok
[2026-05-20 00:53:02] health ok
[2026-05-20 00:54:02] health ok
[2026-05-20 00:55:02] health ok
[2026-05-20 00:56:02] health ok
[2026-05-20 00:57:02] health ok
[2026-05-20 00:58:02] health ok
[2026-05-20 00:59:02] health ok
[2026-05-20 01:00:02] health ok
[2026-05-20 01:01:02] health ok
[2026-05-20 01:02:02] health ok
[2026-05-20 01:03:02] health ok
[2026-05-20 01:04:02] health ok
[2026-05-20 01:05:02] health ok
[2026-05-20 01:06:02] health ok
[2026-05-20 01:07:02] health ok
[2026-05-20 01:08:02] health ok
[2026-05-20 01:09:02] health ok
[2026-05-20 01:10:01] health ok
[2026-05-20 01:11:01] health ok
[2026-05-20 01:12:01] health ok
[2026-05-20 01:13:01] health ok
[2026-05-20 01:14:01] health ok
[2026-05-20 01:15:01] health ok
[2026-05-20 01:16:01] health ok
[2026-05-20 01:17:01] health ok
[2026-05-20 01:18:01] health ok
[2026-05-20 01:19:01] health ok
[2026-05-20 01:20:01] health ok
[2026-05-20 01:21:01] health ok
[2026-05-20 01:22:01] health ok
[2026-05-20 01:23:01] health ok
[2026-05-20 01:24:01] health ok
[2026-05-20 01:25:01] health ok
[2026-05-20 01:26:01] health ok
[2026-05-20 01:27:01] health ok
[2026-05-20 01:28:01] health ok
[2026-05-20 01:29:01] health ok
[2026-05-20 01:30:01] health ok
[2026-05-20 01:31:01] health ok
[2026-05-20 01:32:01] health ok
[2026-05-20 01:33:01] health ok
[2026-05-20 01:34:01] health ok
[2026-05-20 01:35:01] health ok
[2026-05-20 01:36:01] health ok
[2026-05-20 01:37:01] health ok
[2026-05-20 01:38:01] health ok
[2026-05-20 01:39:01] health ok
[2026-05-20 01:40:01] health ok
[2026-05-20 01:41:01] health ok
[2026-05-20 01:42:01] health ok
[2026-05-20 01:43:01] health ok
[2026-05-20 01:44:01] health ok
[2026-05-20 01:45:01] health ok
[2026-05-20 01:46:01] health ok
[2026-05-20 01:47:01] health ok
[2026-05-20 01:48:01] health ok
[2026-05-20 01:49:01] health ok
[2026-05-20 01:50:01] health ok
[2026-05-20 01:51:01] health ok
[2026-05-20 01:52:01] health ok
[2026-05-20 01:53:01] health ok
[2026-05-20 01:54:02] health ok
[2026-05-20 01:55:01] health ok
[2026-05-20 01:56:01] health ok
[2026-05-20 01:57:01] health ok
[2026-05-20 01:58:01] health ok
[2026-05-20 01:59:01] health ok
[2026-05-20 02:00:01] health ok
[2026-05-20 02:01:02] health ok
[2026-05-20 02:02:02] health ok
[2026-05-20 02:03:02] health ok
[2026-05-20 02:04:02] health ok
[2026-05-20 02:05:02] health ok
[2026-05-20 02:06:02] health ok
[2026-05-20 02:07:02] health ok
[2026-05-20 02:08:02] health ok
[2026-05-20 02:09:02] health ok
[2026-05-20 02:10:02] health ok
[2026-05-20 02:11:02] health ok
[2026-05-20 02:12:02] health ok
[2026-05-20 02:13:02] health ok
[2026-05-20 02:14:02] health ok
[2026-05-20 02:15:02] health ok
[2026-05-20 02:16:02] health ok
[2026-05-20 02:17:02] health ok
[2026-05-20 02:18:02] health ok
[2026-05-20 02:19:02] health ok
[2026-05-20 02:20:02] health ok
[2026-05-20 02:21:02] health ok
[2026-05-20 02:22:02] health ok
[2026-05-20 02:23:02] health ok
[2026-05-20 02:24:02] health ok
[2026-05-20 02:25:02] health ok
[2026-05-20 02:26:02] health ok
[2026-05-20 02:27:02] health ok
[2026-05-20 02:28:02] health ok
[2026-05-20 02:29:02] health ok
[2026-05-20 02:30:02] health ok
[2026-05-20 02:31:02] health ok
[2026-05-20 02:32:02] health ok
[2026-05-20 02:33:02] health ok
[2026-05-20 02:34:02] health ok
[2026-05-20 02:35:02] health ok
[2026-05-20 02:36:02] health ok
[2026-05-20 02:37:02] health ok
[2026-05-20 02:38:02] health ok
[2026-05-20 02:39:02] health ok
[2026-05-20 02:40:02] health ok
[2026-05-20 02:41:02] health ok
[2026-05-20 02:42:02] health ok
[2026-05-20 02:43:02] health ok
[2026-05-20 02:44:02] health ok
[2026-05-20 02:45:02] health ok
[2026-05-20 02:46:02] health ok
[2026-05-20 02:47:02] health ok
[2026-05-20 02:48:02] health ok
[2026-05-20 02:49:02] health ok
[2026-05-20 02:50:02] health ok
[2026-05-20 02:51:02] health ok
[2026-05-20 02:52:02] health ok
[2026-05-20 02:53:02] health ok
[2026-05-20 02:54:02] health ok
[2026-05-20 02:55:01] health ok
[2026-05-20 02:56:01] health ok
[2026-05-20 02:57:01] health ok
[2026-05-20 02:58:01] health ok
[2026-05-20 02:59:01] health ok
[2026-05-20 03:00:01] health ok
```

### `C:\inetpub\lake-data\bma-lake-error-0.log`

```
... [truncated head]
 Connection terminated unexpectedly
2026-05-15 08:56:40:       at Connection.<anonymous> (C:\inetpub\wwwroot\lake\.next\standalone\node_modules\pg\lib\client.js:180:73)
2026-05-15 08:56:40:       at Object.onceWrapper (node:events:638:28)
2026-05-15 08:56:40:       at Connection.emit (node:events:524:28)
2026-05-15 08:56:40:       at Socket.<anonymous> (C:\inetpub\wwwroot\lake\.next\standalone\node_modules\pg\lib\connection.js:61:12)
2026-05-15 08:56:40:       at Socket.emit (node:events:524:28)
2026-05-15 08:56:40:       at TCP.<anonymous> (node:net:343:12)
2026-05-15 08:56:40:       at TCP.callbackTrampoline (node:internal/async_hooks:130:17)
2026-05-15 08:56:40: }
2026-05-19 15:08:04: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-19 15:08:04:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-19 15:08:04:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-19 15:08:04:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-19 15:08:04:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-19 15:08:04:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-19 15:08:04:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-19 15:08:04:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-19 15:08:04:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-19 15:08:04:     at node:internal/main/run_main_module:28:49 {
2026-05-19 15:08:04:   code: 'MODULE_NOT_FOUND',
2026-05-19 15:08:04:   requireStack: []
2026-05-19 15:08:04: }
2026-05-19 15:08:07: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-19 15:08:07:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-19 15:08:07:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-19 15:08:07:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-19 15:08:07:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-19 15:08:07:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-19 15:08:07:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-19 15:08:07:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-19 15:08:07:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-19 15:08:07:     at node:internal/main/run_main_module:28:49 {
2026-05-19 15:08:07:   code: 'MODULE_NOT_FOUND',
2026-05-19 15:08:07:   requireStack: []
2026-05-19 15:08:07: }
2026-05-19 15:08:11: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-19 15:08:11:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-19 15:08:11:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-19 15:08:11:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-19 15:08:11:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-19 15:08:11:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-19 15:08:11:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-19 15:08:11:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-19 15:08:11:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-19 15:08:11:     at node:internal/main/run_main_module:28:49 {
2026-05-19 15:08:11:   code: 'MODULE_NOT_FOUND',
2026-05-19 15:08:11:   requireStack: []
2026-05-19 15:08:11: }
2026-05-19 18:03:04: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-19 18:03:04:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-19 18:03:04:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-19 18:03:04:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-19 18:03:04:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-19 18:03:04:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-19 18:03:04:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-19 18:03:04:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-19 18:03:04:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-19 18:03:04:     at node:internal/main/run_main_module:28:49 {
2026-05-19 18:03:04:   code: 'MODULE_NOT_FOUND',
2026-05-19 18:03:04:   requireStack: []
2026-05-19 18:03:04: }
2026-05-19 18:03:07: Error: Cannot find module 'C:\inetpub\wwwroot\lake\.next\standalone\server.js'
2026-05-19 18:03:07:     at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
2026-05-19 18:03:07:     at Module._load (node:internal/modules/cjs/loader:1043:27)
2026-05-19 18:03:07:     at Object.<anonymous> (C:\Users\Administrator\AppData\Roaming\npm\node_modules\pm2\lib\ProcessContainerFork.js:33:23)
2026-05-19 18:03:07:     at Module._compile (node:internal/modules/cjs/loader:1529:14)
2026-05-19 18:03:07:     at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
2026-05-19 18:03:07:     at Module.load (node:internal/modules/cjs/loader:1275:32)
2026-05-19 18:03:07:     at Module._load (node:internal/modules/cjs/loader:1096:12)
2026-05-19 18:03:07:     at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12)
2026-05-19 18:03:07:     at node:internal/main/run_main_module:28:49 {
2026-05-19 18:03:07:   code: 'MODULE_NOT_FOUND',
2026-05-19 18:03:07:   requireStack: []
2026-05-19 18:03:07: }
```

### `C:\inetpub\lake-data\bma-lake-out-0.log`

```
... [truncated head]
al:        http://localhost:3000
2026-05-11 21:29:11:   - Network:      http://0.0.0.0:3000
2026-05-11 21:29:11: 
2026-05-11 21:29:11:  âœ“ Starting...
2026-05-11 21:29:11:  âœ“ Ready in 170ms
2026-05-11 21:29:12:   â–² Next.js 14.2.29
2026-05-11 21:29:12:   - Local:        http://localhost:3000
2026-05-11 21:29:12:   - Network:      http://0.0.0.0:3000
2026-05-11 21:29:12: 
2026-05-11 21:29:12:  âœ“ Starting...
2026-05-11 21:29:12:  âœ“ Ready in 130ms
2026-05-11 21:33:37:   â–² Next.js 14.2.29
2026-05-11 21:33:37:   - Local:        http://localhost:3000
2026-05-11 21:33:37:   - Network:      http://0.0.0.0:3000
2026-05-11 21:33:37: 
2026-05-11 21:33:37:  âœ“ Starting...
2026-05-11 21:33:37:  âœ“ Ready in 172ms
2026-05-11 21:33:39:   â–² Next.js 14.2.29
2026-05-11 21:33:39:   - Local:        http://localhost:3000
2026-05-11 21:33:39:   - Network:      http://0.0.0.0:3000
2026-05-11 21:33:39: 
2026-05-11 21:33:39:  âœ“ Starting...
2026-05-11 21:33:39:  âœ“ Ready in 148ms
2026-05-11 21:39:25:   â–² Next.js 14.2.29
2026-05-11 21:39:25:   - Local:        http://localhost:3000
2026-05-11 21:39:25:   - Network:      http://0.0.0.0:3000
2026-05-11 21:39:25: 
2026-05-11 21:39:25:  âœ“ Starting...
2026-05-11 21:39:25:  âœ“ Ready in 121ms
2026-05-11 21:41:31:   â–² Next.js 14.2.29
2026-05-11 21:41:31:   - Local:        http://localhost:3000
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
```

---
*Auto-generated 2026-05-20 03:00 by `server-b/refresh-server-b-logs.ps1`*

