# todo - server-b

> สรุป Web App ทั้งหมดที่เจอบนเครื่องนี้ (172.27.15.6, Windows Server 2019)
> สำรวจเมื่อ: 2026-05-04

## ภาพรวม

- **IIS** เป็น reverse proxy / host หลัก (Default Web Site, ทุกอย่างรันบน HTTPS)
- **PM2** รัน Node app ตัวเดียว: `bma-lake` (id 0, port 3000)
- LLM ที่ใช้ร่วมกัน: Qwen ผ่าน vLLM ที่ `http://100.99.107.27:8000/v1` (Qwen3-14B / Qwen2.5-32B-Instruct-AWQ)
- WhisperX endpoint: `http://localhost:9000`

---

## 1. BMA Data Lake Portal — `/lake/`

- Path: `C:\inetpub\wwwroot\lake`
- Stack: **Next.js 14** + React 18 + Tailwind, PM2 (`bma-lake`, port 3000) ผ่าน IIS ARR
- Public URL: `https://172.27.15.6/lake/`
- DB: dual — CKAN PostgreSQL (read-only) + lake MySQL (write) ผ่าน `pg` และ `mysql2`
- Auth: NextAuth + bcrypt
- หน้าที่: portal สำหรับ dataset ของกรุงเทพฯ (public datasets + admin จัดการ dataset)
- ดูไฟล์: [lake/package.json](C:/inetpub/wwwroot/lake/package.json), [lake/web.config](C:/inetpub/wwwroot/lake/web.config)

## 2. BMA Chatbot Platform — `/chatbot/`

- Path: `C:\inetpub\wwwroot\chatbot`
- Stack: **PHP 8.5** + MySQL 8 + IIS (พบ [CLAUDE.md](C:/inetpub/wwwroot/chatbot/CLAUDE.md) อธิบายระบบครบ)
- Public URL: `https://exam.bangkok.go.th/chatbot`
- หน้าที่: ระบบ Chatbot multi-org สำหรับหน่วยงาน กทม. — RAG จากเอกสารที่ admin upload (PDF/DOCX/TXT/Audio), LLM = Qwen ผ่าน vLLM, ถอดเสียงด้วย WhisperX
- Roles: `superadmin` (ดูทุก org) / `admin` (org เดียว)
- Modules:
  - `api/` (auth, chat, documents, org, stats, transcribe, voice)
  - `lib/` (rag, llm_client, doc_parser, audio_splitter)
  - `admin/` (portal, chatbot-setup, logs, stats, transcribe)
  - `chat/index.html` (public chat UI)
- Upload base: `C:\inetpub\chatbot-data`
- มี design doc สำหรับ upgrade RAG → pgvector ที่ [chatbot-vector-rag-technical-design.md](C:/codex/chatbot-vector-rag-technical-design.md) (status: design only)

## 3. BMA Early-Childhood Data Hub / API Gateway — `/link/`

- Path: `C:\inetpub\wwwroot\link`
- Stack: **PHP** (custom, ไม่ใช้ framework) + MySQL + Bootstrap admin UI
- หน้าที่: ระบบกลางสำหรับข้อมูลเด็กปฐมวัย — รวม core fields, mapping ของแต่ละสำนัก, ingestion จาก CSV/XLSX, validation, data-quality, masking, audit log
- ส่วนสำคัญ: `FieldPolicyEngine`, `MaskingService`, `ValidationService`, `IngestionService`, `MappingService`, `ApiGateway`, `AuditLogger`, `ChildIndexService`
- Tables: `core_fields`, `agencies`, `source_systems`, `child_records`, `audit_logs`, `data_quality_errors`
- Entrypoint: [index.php](C:/inetpub/wwwroot/link/index.php) → redirect ไป `/admin/login.php`
- Sensitivity tiers: `Sensitive Personal Data` / `Confidential` / `Internal`
- Mapping ต้นทาง: [BMA_EarlyChildhood_CoreDataset_Mapping.xlsx](C:/codex/BMA_EarlyChildhood_CoreDataset_Mapping.xlsx)

## 4. OPEN — Hospital Case Status Tracker — `/open/`

- Path: `C:\inetpub\wwwroot\open`
- Stack: **PHP** (no framework, mysqli) + MariaDB/MySQL — มี [PROJECT_HANDOFF.md](C:/inetpub/wwwroot/open/PROJECT_HANDOFF.md) ครบ
- Public URL: `https://exam.bangkok.go.th/open/`
- หน้าที่: Public site ค้นหาสถานะเคส/เอกสาร/การเงินจาก invoice_no หรือ ref_no + 4 หลักท้าย TAX ID (filter ตามโรงพยาบาล); Admin site จัดการเคส, KPI dashboard, sync log placeholder ไป MIS, **AI analysis** (ยิงไป Qwen2.5-32B-Instruct-AWQ ที่ vLLM)
- Default admin: `admin` / `1234` (ควรเปลี่ยน)
- Install: `install.php` (สร้าง DB, seed 11 รพ., dummy 100+ เคส)
- มี [UAT_TEST_DOCUMENT.md](C:/inetpub/wwwroot/open/UAT_TEST_DOCUMENT.md)

## 5. Realtime Thai Meeting Transcription (frontend) — `/realtime/`

- Path: `C:\inetpub\wwwroot\realtime`
- Stack: **Static HTML/JS** (no build) — `index.html`, `app.js`, `audio-utils.js`, `styles.css`
- URL: `http://172.27.15.6/realtime`
- หน้าที่: Frontend สำหรับถอดเสียงประชุมเรียลไทม์ (downsample เป็น 16kHz mono PCM Int16 → ส่งเข้า WebSocket binary frame)
- Backend WebSocket: `ws://<host>/ws/audio` (default ดูตัวเลือกได้ในหน้า)
- Message types ที่รองรับ: `partial_transcript`, `final_transcript`, `summary_update` (มี key_points/decisions/action_items/risks_or_followups), `error`
- ดู: [realtime/README.md](C:/inetpub/wwwroot/realtime/README.md)

## 6. Realtime Thai Transcribe Backend (Machine A) — `C:\apps\realtime-thai-transcribe`

- Stack: **Python (FastAPI/uvicorn) + .venv** — entry `app.main:app`, port **9120**
- WebSocket: `ws://172.27.15.6:9120/ws/audio` (ที่ `/realtime/` frontend เรียก)
- Start/stop: `scripts\start-backend.ps1`, `scripts\stop-backend.ps1`
- vLLM ที่ backend ใช้: `http://172.27.15.60:8000/v1` (จาก `.env`)
- Logs: `logs\backend.out.log`, `logs\backend.err.log`
- Health: `GET http://127.0.0.1:9120/health`
- ดู: [realtime-thai-transcribe/README.md](C:/apps/realtime-thai-transcribe/README.md)

## 7. Chat (placeholder/stub) — `/chat/`

- Path: `C:\inetpub\wwwroot\chat`
- มีแค่ `index.html` ที่บอกว่า `Use /chat/{slug}` + `web.config` (default doc) — เป็น stub/placeholder, ไม่ใช่แอป production
- มี dir `smoke-local-20260412210402/` (ไฟล์ smoke-test เก่า)

## 8. BMA HouseID Reverse Proxy — `/bma-houseid` (IIS Application)

- Path: `C:\inetpub\bma-houseid-proxy` (ไม่ใช่ในอยู่ wwwroot)
- ไม่ใช่แอป — เป็น **URL Rewrite reverse proxy** ไปที่ `https://gidapp.bangkok.go.th/bma-houseid/{R:1}`
- หน้าที่: ทำให้ของจริงเข้าถึงได้ผ่าน hostname ของเครื่องนี้
- Tooling/data ที่เกี่ยวข้องอยู่ใน `C:\codex\` (`export_bma_houseid_full.ps1`, `run_bma_houseid_chunked.ps1`, ไฟล์ CSV หลายชุด)

---

## ส่วนเสริม / ไม่ใช่ web app เต็มตัว

- `C:\codex\` — working dir ของ user (CSV, scripts, ไฟล์ migration, design docs, log probes, tmp_*.php debug scripts) **ไม่ใช่ web app**
- `C:\codex\migration-realtime-172.27.15.59` + `migration-realtime-172.27.15.59.zip` — bundle ย้าย realtime backend ไปอีกเครื่อง
- `C:\codex\tmp_realtime_ubuntu_bundle*` — bundle deploy ฝั่ง Ubuntu
- `C:\erp` — มีแค่ `config.php` กับ `networklogon.inf` (ไม่ใช่ web app บนเครื่องนี้)
- `C:\bg`, `C:\chatbot` (ระดับ root) — ว่าง / ไม่มี
- `C:\tools` — ffmpeg, poppler, downloads (รองรับ chatbot/realtime)
- `C:\SSIS\APISource`, `C:\SSIS\Assembly` — SSIS components (ETL, ไม่ใช่ web app)
- `C:\notes` — Obsidian vault (มี `inetpub.code-workspace` สำหรับเปิด wwwroot ใน VS Code)

## VS Code workspaces ที่จำได้

- `c:\codex` (เปิดล่าสุดใน VS Code, มี `workspace.code-workspace`)
- `c:\codex\workspace.code-workspace`
- Remote SSH: `ssh-remote+172.27.15.59` → `/home/administrator/workspace.code-workspace` (เครื่อง A — น่าจะเป็นที่รัน realtime backend Ubuntu)

## สรุปเร็ว: web app ที่ "เป็นแอปจริง" บนเครื่องนี้

| # | App | URL/Endpoint | Stack | บทบาท |
|---|---|---|---|---|
| 1 | bma-lake | `/lake/` (Next 3000) | Next.js 14 | Data Lake portal (CKAN+MySQL) |
| 2 | chatbot | `/chatbot` | PHP 8 + MySQL | Multi-org RAG chatbot + meeting transcribe |
| 3 | link | `/link/` | PHP + MySQL | Early-childhood data hub / API gateway / audit |
| 4 | open | `/open/` | PHP + MySQL | Hospital case status tracker + AI analysis |
| 5 | realtime (FE) | `/realtime/` | Static JS | Realtime transcription UI |
| 6 | realtime (BE) | `:9120/ws/audio` | Python | Realtime transcription server |
| 7 | bma-houseid | `/bma-houseid` | IIS rewrite | Reverse proxy → gidapp.bangkok.go.th |
