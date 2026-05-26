# exam-z

**Path:** $(@{slug=exam-z; path=C:\inetpub\wwwroot\exam\z; exists=True; source=discovery; markers=System.Object[]; stack=PHP; entrypoints=System.Object[]; config_files=System.Object[]; db_hints=System.Object[]; recent_files=System.Object[]; git_commits=System.Object[]; ai_summary=1) **Summary**
- โครงสร้างโปรเจกต์ `exam-z` เป็น PHP แบบดั้งเดิม (Vanilla) โดยใช้ `index.php` เป็นจุดเข้าใช้งานหลัก
- มีการจัดการ Layout และ Configuration แยกไฟล์ในโฟลเดอร์ `lib/` เพื่อความสะอาดของโค้ด
- ไฟล์ `brain.php` น่าจะเป็น Core Logic หรือ Controller หลักที่เพิ่งถูกแก้ไขล่าสุด
- ยังไม่มีการใช้งาน Git ในการควบคุมเวอร์ชัน (No git lines)

2) **Risks**
- ความเสี่ยงด้านความปลอดภัยสูงหากไฟล์ `.env` ถูก commit เข้า repository หรือเข้าถึงได้ผ่านเว็บ
- การไม่มี Git ทำให้ยากต่อการติดตามการเปลี่ยนแปลงและกู้คืนโค้ดหากเกิดข้อผิดพลาด
- โครงสร้างแบบ Monolithic อาจทำให้การบำรุงรักษายากขึ้นเมื่อโปรเจกต์ขยายขนาด
- ไฟล์ `web.config` บ่งชี้ว่ารันบน IIS ต้องตรวจสอบการตั้งค่า URL Rewrite ให้ถูกต้อง

3) **Next Step**
- ตั้งค่า Git repository ทันที และเพิ่ม `.env` เข้า `.gitignore` เพื่อป้องกันข้อมูลรั่วไหล
- ตรวจสอบเนื้อหาใน `brain.php` และ `lib/config.php` ว่ามีการจัดการ Error Handling อย่างเหมาะสมหรือไม่
- ทดสอบการเข้าถึง `index.php` ผ่านเบราว์เซอร์เพื่อยืนยันว่า Layout และ Config โหลดถูกต้อง
- ตรวจสอบสิทธิ์การอ่าน/เขียนของโฟลเดอร์ `tasks/` สำหรับไฟล์ log

*(model: Qwen/Qwen3-14B)*; risks=System.Object[]}.path)
**Tool:** Claude Code / Codex

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\exam\z`
- Stack: PHP
- Entry points: index.php
- Config files: .env, .env.example, web.config, README.md
- DB hints: mysql/pdo

### AI Summary (24h)

1) **Summary**
- โครงสร้างโปรเจกต์ `exam-z` เป็น PHP แบบดั้งเดิม (Vanilla) โดยใช้ `index.php` เป็นจุดเข้าใช้งานหลัก
- มีการจัดการ Layout และ Configuration แยกไฟล์ในโฟลเดอร์ `lib/` เพื่อความสะอาดของโค้ด
- ไฟล์ `brain.php` น่าจะเป็น Core Logic หรือ Controller หลักที่เพิ่งถูกแก้ไขล่าสุด
- ยังไม่มีการใช้งาน Git ในการควบคุมเวอร์ชัน (No git lines)

2) **Risks**
- ความเสี่ยงด้านความปลอดภัยสูงหากไฟล์ `.env` ถูก commit เข้า repository หรือเข้าถึงได้ผ่านเว็บ
- การไม่มี Git ทำให้ยากต่อการติดตามการเปลี่ยนแปลงและกู้คืนโค้ดหากเกิดข้อผิดพลาด
- โครงสร้างแบบ Monolithic อาจทำให้การบำรุงรักษายากขึ้นเมื่อโปรเจกต์ขยายขนาด
- ไฟล์ `web.config` บ่งชี้ว่ารันบน IIS ต้องตรวจสอบการตั้งค่า URL Rewrite ให้ถูกต้อง

3) **Next Step**
- ตั้งค่า Git repository ทันที และเพิ่ม `.env` เข้า `.gitignore` เพื่อป้องกันข้อมูลรั่วไหล
- ตรวจสอบเนื้อหาใน `brain.php` และ `lib/config.php` ว่ามีการจัดการ Error Handling อย่างเหมาะสมหรือไม่
- ทดสอบการเข้าถึง `index.php` ผ่านเบราว์เซอร์เพื่อยืนยันว่า Layout และ Config โหลดถูกต้อง
- ตรวจสอบสิทธิ์การอ่าน/เขียนของโฟลเดอร์ `tasks/` สำหรับไฟล์ log

*(model: Qwen/Qwen3-14B)*

### Recent Files

- `README.md` 2026-05-26 20:10
- `.env.example` 2026-05-26 20:10
- `brain.php` 2026-05-26 20:09
- `lib\layout.php` 2026-05-26 20:08
- `lib\config.php` 2026-05-26 20:08
- `tasks\survey-apps.log` 2026-05-26 01:00
- `.env` 2026-05-21 05:48
- `api\ping.php` 2026-05-20 22:04
- `index.php` 2026-05-20 22:01
- `web.config` 2026-05-20 18:57

### Git Commits

- (no git commits found)

<!-- AUTO_SECTION_END -->
