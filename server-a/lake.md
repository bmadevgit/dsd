# lake

**Path:** $(@{slug=lake; path=C:\inetpub\wwwroot\lake; exists=True; source=discovery; markers=System.Object[]; stack=PHP; entrypoints=System.Object[]; config_files=System.Object[]; db_hints=System.Object[]; recent_files=System.Object[]; git_commits=System.Object[]; ai_summary=1) **Summary**
- โครงสร้างโปรเจกต์ lake ใช้ PHP บน IIS โดยมี `index.php` เป็นจุดเข้าใช้งานหลัก
- มีการจัดการไฟล์คอนฟิกผ่าน `web.config` และ `config.php` เพื่อตั้งค่าสภาพแวดล้อม
- อัปเดตล่าสุดเป็นการแก้ไข `.gitignore` เพื่อซ่อนไฟล์สแนปช็อตของ IIS Config
- ไฟล์ที่เปลี่ยนแปลงล่าสุดคือ `favicon.ico` ซึ่งไม่กระทบต่อตรรกะหลักของระบบ

2) **Risks**
- การซ่อนไฟล์ IIS Config ใน Git อาจทำให้การตรวจสอบความแตกต่างของคอนฟิกเซิร์ฟเวอร์ทำได้ยากขึ้น
- ต้องตรวจสอบว่า `config.php` ไม่มีการเก็บข้อมูลลับ (Secrets) ไว้ในโค้ดโดยตรง
- โครงสร้างโฟลเดอร์ `wwwroot/` ควรสอดคล้องกับ Root Directory ของ IIS เพื่อป้องกัน Error 404
- การแก้ไข `.gitignore` อาจส่งผลต่อประวัติ Git หากมีไฟล์สำคัญถูกตัดออกโดยไม่ตั้งใจ

3) **Next Step**
- ตรวจสอบเนื้อหาใน `web.config` เพื่อให้แน่ใจว่า Routing และ Handler Mapping ถูกต้องสำหรับ PHP
- ทดสอบการเข้าถึง `index.php` ผ่านเบราว์เซอร์เพื่อยืนยันว่าระบบทำงานปกติ
- ตรวจสอบว่าไฟล์ `config.php` มีการโหลด Environment Variables อย่างปลอดภัย
- ยืนยันว่า `.gitignore` ทำงานถูกต้องโดยตรวจสอบสถานะ Git ว่าไม่มีการติดตามไฟล์ที่ไม่ต้องการ

*(model: Qwen/Qwen3-14B)*; risks=System.Object[]}.path)
**Tool:** Claude Code / Codex

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\lake`
- Stack: PHP
- Entry points: index.php
- Config files: web.config, config.php
- DB hints: mysql/pdo

### AI Summary (24h)

1) **Summary**
- โครงสร้างโปรเจกต์ lake ใช้ PHP บน IIS โดยมี `index.php` เป็นจุดเข้าใช้งานหลัก
- มีการจัดการไฟล์คอนฟิกผ่าน `web.config` และ `config.php` เพื่อตั้งค่าสภาพแวดล้อม
- อัปเดตล่าสุดเป็นการแก้ไข `.gitignore` เพื่อซ่อนไฟล์สแนปช็อตของ IIS Config
- ไฟล์ที่เปลี่ยนแปลงล่าสุดคือ `favicon.ico` ซึ่งไม่กระทบต่อตรรกะหลักของระบบ

2) **Risks**
- การซ่อนไฟล์ IIS Config ใน Git อาจทำให้การตรวจสอบความแตกต่างของคอนฟิกเซิร์ฟเวอร์ทำได้ยากขึ้น
- ต้องตรวจสอบว่า `config.php` ไม่มีการเก็บข้อมูลลับ (Secrets) ไว้ในโค้ดโดยตรง
- โครงสร้างโฟลเดอร์ `wwwroot/` ควรสอดคล้องกับ Root Directory ของ IIS เพื่อป้องกัน Error 404
- การแก้ไข `.gitignore` อาจส่งผลต่อประวัติ Git หากมีไฟล์สำคัญถูกตัดออกโดยไม่ตั้งใจ

3) **Next Step**
- ตรวจสอบเนื้อหาใน `web.config` เพื่อให้แน่ใจว่า Routing และ Handler Mapping ถูกต้องสำหรับ PHP
- ทดสอบการเข้าถึง `index.php` ผ่านเบราว์เซอร์เพื่อยืนยันว่าระบบทำงานปกติ
- ตรวจสอบว่าไฟล์ `config.php` มีการโหลด Environment Variables อย่างปลอดภัย
- ยืนยันว่า `.gitignore` ทำงานถูกต้องโดยตรวจสอบสถานะ Git ว่าไม่มีการติดตามไฟล์ที่ไม่ต้องการ

*(model: Qwen/Qwen3-14B)*

### Recent Files

- `favicon.ico` 2076-11-29 15:54
- `city.csv` 2026-05-22 14:30
- `sw.csv` 2026-04-16 17:16
- `api_chat.php` 2026-03-16 14:39
- `chat_api.php` 2026-03-16 07:11
- `config_options.json` 2026-03-13 17:10
- `req_admin.php` 2026-03-13 17:10
- `data_requests_gov.csv` 2026-03-13 17:07
- `doc\REQ-202603-7741\1773396462_อพ.pdf` 2026-03-13 17:07
- `req.php` 2026-03-13 17:06

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

### Risks

- future timestamps detected in recent files

<!-- AUTO_SECTION_END -->
