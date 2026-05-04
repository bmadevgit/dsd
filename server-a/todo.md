# Server A — สรุป Web Applications ทั้งหมด

> สำรวจเมื่อ 2026-05-03 · Working directory: `C:\inetpub\`
> VSCode Workspace: `inetpub.code-workspace` (folders: `.` + `wwwroot/car2`)

---

## ภาพรวม

| หมวด | จำนวน App |
|------|-----------|
| wwwroot (root-level) | 16 |
| wwwroot/exam (sub-apps) | 15 |
| vibe-ide | 1 |
| **รวม** | **32** |

Stack หลัก: PHP 8, Python 3, React/Vite, ASP.NET Core 8, MySQL, SQLite, IIS

---

## wwwroot — Root-level Apps

### bs — LINE Chatbot (Hybrid RAG)
**Path:** `C:\inetpub\wwwroot\bs`
**Stack:** PHP 8 + Python 3.11 + MySQL
- LINE Webhook รับข้อความ → queue งาน → Python worker ประมวลผล RAG
- ค้นหาเอกสาร PDF ด้วย Hybrid RAG (Typhoon 2.5 / Ollama)
- Admin dashboard จัดการ documents, job queue, logs, settings, health check
- Google Sheets integration + Gemini API fallback
- Tables: `line_data`, `bot_jobs`, `bot_answers`, `enriched_alerts`, `llm_calls`, `admin_users`

---

### bmapoll — Traffy Bangkok Data Explorer
**Path:** `C:\inetpub\wwwroot\bmapoll`
**Stack:** PHP 8 + MySQL + Tailwind CSS + marked.js
- แสดงข้อมูลเรื่องร้องเรียน Traffy Fondue ของกรุงเทพฯ
- ค้นหาด้วย keyword, วันที่, เขต / Google Maps markers / CSV export
- AI Chat วิเคราะห์ข้อมูลด้วย Ollama (Typhoon 2.5)
- Table: `traffy_bangkok` (ticket_id, type, state, district, lat, lng, photo...)

---

### car — Fleet Management (Reference)
**Path:** `C:\inetpub\wwwroot\car`
**Stack:** PHP + Bootstrap 3.3.5 + Ionicons
- โครงสร้างพื้นฐาน UI ระบบจัดการยานพาหนะ (ไม่ fully implemented)
- มีแค่ library files + phpinfo

---

### car2 — ระบบบริหารจัดการยานพาหนะ BMA
**Path:** `C:\inetpub\wwwroot\car2`
**Stack:** PHP 8 + MySQL + PHPSpreadsheet
- จัดการรถยนต์ราชการ: ข้อมูลรถ, คนขับ, ประวัติซ่อม, น้ำมัน
- ระบบขอยืมรถ (borrow workflow: request → approve → return)
- GPS tracking map แบบ real-time
- Export Excel + ERP integration (SAP?)
- Tables: cars, drivers, maintenance, borrowing records, ERP sync

---

### cpud — QR Code Generator Library
**Path:** `C:\inetpub\wwwroot\cpud`
**Stack:** PHP + phpqrcode + TCPDF
- Library สร้าง QR Code + embed ลงใน PDF
- มี cache สำหรับ QR code ที่สร้างแล้ว

---

### eva — Task Tracker (React SPA)
**Path:** `C:\inetpub\wwwroot\eva`
**Stack:** React 19 + Vite + Tailwind CSS + PHP backend
- ระบบติดตาม task และ project management บน browser
- แนบไฟล์ได้ (PDF, รูป, XLSX)
- เก็บข้อมูลใน `tasks_data.json`

---

### now — Digital Bureau Task Tracker
**Path:** `C:\inetpub\wwwroot\now`
**Stack:** React 19 + Vite + Tailwind CSS + PHP backend
- ระบบ task management สำหรับสำนักดิจิทัล BMA
- คล้าย EVA แต่ branded สำหรับทีม digital bureau
- เก็บข้อมูลใน `tasks_data.json`

---

### hid — AdminLTE UI Template
**Path:** `C:\inetpub\wwwroot\hid`
**Stack:** Node.js + Bootstrap + AdminLTE 4.x
- Template / reference UI สำหรับ admin dashboard
- มี widgets, charts, kanban, calendar, gallery pages
- ไม่ใช่ production app — ใช้เป็น UI reference

---

### lake — Data Dashboard (Template)
**Path:** `C:\inetpub\wwwroot\lake`
**Stack:** PHP + Bootstrap + Ionicons
- Template dashboard สำหรับ data visualization
- ยังไม่ fully implemented

---

### open — Hospital Case Management
**Path:** `C:\inetpub\wwwroot\open`
**Stack:** PHP 8 + MySQL
- ระบบตรวจสอบสถานะเคส/ใบแจ้งหนี้ระหว่างโรงพยาบาลกับหน่วยงาน
- ค้นหาด้วยเลขใบแจ้งหนี้ + เลขอ้างอิง + เลขทะเบียนนิติบุคคล
- Admin จัดการเคส + AI วิเคราะห์ KPI (Qwen2.5-32B)
- Tables: hospitals, admins, cases, case_status_logs, sync_logs

---

### org — Org Data Dashboard (Template)
**Path:** `C:\inetpub\wwwroot\org`
**Stack:** PHP + Bootstrap + Ionicons
- หน้า dashboard โครงสร้างองค์กรหรือบุคลากร
- ยังไม่ fully implemented

---

### q — Foreign Worker Queue & Email System
**Path:** `C:\inetpub\wwwroot\q`
**Stack:** PHP + Bootstrap + PHPMailer + TCPDF + XLSXWriter + MySQL
- ระบบจองคิวแรงงานต่างด้าว 3 สัญชาติ
- จัดการ request + ส่ง email อัตโนมัติ (PHPMailer)
- Export PDF รายงาน (TCPDF) + Excel (XLSXWriter) + CSV
- รองรับภาษาไทย

---

### reportb — PDF Report Generator Library
**Path:** `C:\inetpub\wwwroot\reportb`
**Stack:** PHP + TCPDF 6.2.13
- Library สร้าง PDF รองรับฟอนต์ภาษาไทย (Cordia, AngsanaUPC)
- ใช้ร่วมกับ app อื่น ๆ ใน server

---

### reportc — Report Dashboard (Template)
**Path:** `C:\inetpub\wwwroot\reportc`
**Stack:** PHP + Bootstrap + Ionicons
- Template สำหรับ dashboard รายงาน
- ยังไม่ fully implemented

---

### u — QR Code Utility
**Path:** `C:\inetpub\wwwroot\u`
**Stack:** PHP + phpqrcode
- คล้าย `cpud` — สร้าง QR code + cache
- utility ขนาดเล็ก

---

### videoconference — Video Conference (Placeholder)
**Path:** `C:\inetpub\wwwroot\videoconference`
**Stack:** IIS config only
- Placeholder / stub สำหรับ video conference integration
- มีแค่ `web.config`

---

## wwwroot/exam — Sub-applications Suite

### exam/a — BMA Alert Data Explorer
**Stack:** PHP + PDO + MySQL
- ค้นหาและดู LINE messages จาก BMA Alert
- filter ด้วย keyword, วันที่, ประเภทข้อความ + pagination + สถิติ
- Tables: `line_data`, `enriched_alerts`

---

### exam/ai — .NET 8 RESTful API
**Stack:** ASP.NET Core 8 + Entity Framework Core + SQLite + JWT
- API backend สำหรับ exam modules อื่น ๆ
- มี Swagger/OpenAPI, JWT Bearer auth, PDF parsing (UglyToad.PdfPig)
- Database: SQLite

---

### exam/ar1 — Augmented Reality (QR Marker)
**Stack:** JavaScript + WebGL + MindAR
- Web AR ด้วย QR marker tracking
- real-time camera + 3D model rendering บน browser

---

### exam/ar2 — Augmented Reality (NFT Marker)
**Stack:** JavaScript + AR.js + NFT compiler
- Web AR ขั้นสูงด้วย Natural Feature Tracking
- ไม่ต้องใช้ QR code — จำรูปภาพจริงได้
- มี Node.js compiler สำหรับ train marker

---

### exam/bike — BMA Bikeshare Dashboard
**Stack:** PHP + Google Maps API + MySQL + JavaScript
- dashboard วิเคราะห์การใช้งาน bikeshare ของกรุงเทพฯ
- Heatmap การเดินทาง, utilization rate, block grid visualization
- Tables: bike stations, trips

---

### exam/chatbot — Multi-Tenant Chatbot Platform
**Stack:** PHP 8.1+ (PSR-4 autoload) + Composer
- Framework chatbot รองรับหลาย tenant (white-label)
- โครงสร้างรองรับ multi-org deployment

---

### exam/diaper — (Placeholder)
- ยังไม่มีเนื้อหา

---

### exam/disc — Discipline Record Management
**Stack:** PHP + SQLite
- ระบบบันทึกประวัติทางวินัย
- มี user auth (role: admin), CRUD records
- Database: SQLite (`disc.db`)

---

### exam/h — Medical Records System
**Stack:** PHP + APIs
- ระบบข้อมูลสุขภาพ/การแพทย์
- มี private data, API endpoints — ยังไม่ fully implemented

---

### exam/map — Pin Survey & Location Mapping
**Stack:** PHP + Google Maps API + MySQL
- ระบบปักหมุดและสำรวจพื้นที่ชุมชน
- Import จาก Google Sheet + AI-powered URL parser
- District admin interface + needs_review workflow
- Tables: locations, districts, imports, reviews

---

### exam/na — Task App Frontend (React/Vite)
**Stack:** React 19 + Vite + Tailwind CSS
- Frontend SPA สำหรับ task management
- (คล้าย EVA/NOW — อาจเป็น experimental build)

---

### exam/open — Case Management
**Stack:** PHP 8 + MySQL
- ระบบเดียวกับ `wwwroot/open` (อาจเป็น dev copy หรือ exam subdomain)

---

### exam/project — Project Management (Placeholder)
**Stack:** Node.js toolchain
- ยังไม่ fully implemented

---

### exam/server — Server Analytics Dashboard
**Stack:** Python 3.11 + Streamlit + Pandas + Plotly + MySQL
- Dashboard วิเคราะห์ log ของ server: IIS requests, MySQL slow queries, Windows Security events
- traffic visualization, vulnerability detection, hourly traffic graphs
- AI insights ด้วย Qwen2.5-32B (OpenAI-compatible API)
- Tables: iis_status_summary, iis_top_ips, mysql_slow_queries, iis_vulnerabilities, iis_error_uris, iis_traffic_hourly, windows_event_summary

---

### exam/vhv — ระบบจัดการ อสส. (Volunteer Health Worker)
**Stack:** PHP 8 + MySQL + Bootstrap 5 + Chart.js + Composer
- ฐานข้อมูลอาสาสมัครสาธารณสุข (VHV) กรุงเทพฯ
- บทบาท: admin, nurse, center staff, VHV
- E-card ดิจิทัลพร้อม QR code
- ส่งรายงานประจำเดือน, dashboard Chart.js, AI chat ค้นข้อมูล
- Import Excel, role-based access
- Tables: vhv, users, reports, uploads

---

## vibe-ide — AI-Powered Code Editor API

**Path:** `C:\inetpub\vibe-ide`
**Stack:** ASP.NET Core 8 + C# + Entity Framework Core + SQLite + JWT + Swagger
- Web-based IDE backend API พร้อม AI วิเคราะห์โค้ด
- JWT authentication, Swagger/OpenAPI documentation
- อ่าน PDF และ Office files (UglyToad.PdfPig, DocumentFormat.OpenXml)
- Frontend: React/Web UI ใน `frontend/`
- Database: SQLite

---

## TODO / Notes

- [ ] **car** — ดูว่าจะ merge หรือ archive ทิ้ง (ซ้อนกับ car2)
- [ ] **lake, org, reportc** — ยัง template เปล่า — ตัดสินใจว่าจะ implement หรือลบ
- [ ] **videoconference** — ยังแค่ IIS stub — ถ้าไม่ใช้ควรลบ
- [ ] **exam/diaper, exam/h, exam/project** — incomplete — ติดตามความคืบหน้า
- [ ] **exam/open vs wwwroot/open** — ตรวจสอบว่า duplicate หรือเป็น staging copy
- [ ] **hid** — AdminLTE template — ถ้าไม่ได้ใช้ active ควร archive
- [ ] **exam/server** — Streamlit app วิ่งบน port ไหน? ต้องตั้ง IIS reverse proxy
- [ ] **bs Python worker** — ต้องตรวจสอบ service/process management (auto-restart?)
- [ ] **vibe-ide** — frontend ใน vibe-ide/frontend/ deploy แยก หรือ serve จาก .NET?
