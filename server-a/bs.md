# bs — LINE Chatbot (Hybrid RAG)

**Path:** `C:\inetpub\wwwroot\bs`
**Stack:** PHP 8 · Python 3.11 · MySQL · Qdrant · Ollama (Qwen) · Gemini API
**Tool:** Claude Code

---

## Timeline

- **2025-12-05** — เริ่มโปรเจกต์ ตั้งค่า logger และ project structure
- **2025-12-29 – 2026-01-10** — scaffold หลัก: LINE webhook, config, database bootstrap, logging framework
- **2026-01-07 – 2026-01-30** — พัฒนา admin dashboard (`Dashboard.php`, `Dashboard_all.php`), สร้าง `mana/` directory (queue, docs, chats, settings, health)
- **2026-02-01 – 2026-02-14** — ระบบ Hybrid RAG: Python worker, PDF ingestion, chunking, LLM router (Qwen → Gemini fallback)
- **2026-03 – 2026-04-30** — ปรับปรุง iterative: health check, security hardening, admin UI, logging
- **2026-05-02** — **Major deployment** — รัน migration `20260502_hybrid_rag.sql`, ติดตั้ง Python venv (5,640 files), finalize config
- **2026-05-03** — ทดสอบ acceptance (`ACCEPTANCE_20260503.md`), ส่งมอบระบบ

## Features

- LINE webhook รับข้อความ → async job queue → Python RAG worker
- Hybrid RAG: ใช้ Qwen (local) ก่อน, escalate ไป Gemini ถ้าไม่ผ่าน threshold
- PDF upload + chunking + vector search (Qdrant)
- คำตอบ 5 ส่วน: short answer · evidence · opinion · source docs · confidence score
- Admin dashboard: job status, worker heartbeat, document manager, LLM call history
- Google Sheets integration, dry-run mode, settings persistence

## Status

**Production** — ใช้งานจริง ส่งมอบแล้ว 2026-05-03
