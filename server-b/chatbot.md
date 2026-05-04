# BMA Chatbot Platform (`chatbot`)

- **Path:** `C:\inetpub\wwwroot\chatbot`
- **Public URL:** `https://exam.bangkok.go.th/chatbot`
- **Stack:** PHP 8.5 (no framework) · MySQL 8 · IIS · Windows Server 2025
- **LLM:** Qwen ผ่าน vLLM (OpenAI-compat) — `http://100.99.107.27:8000/v1`, model `Qwen/Qwen3-14B`
- **Transcribe:** WhisperX `http://localhost:9000`
- **Upload base:** `C:\inetpub\chatbot-data` (ต้องให้ IIS_IUSRS เขียนได้)

> มีคู่มือฉบับเต็มที่ [chatbot/CLAUDE.md](C:/inetpub/wwwroot/chatbot/CLAUDE.md) — อ้างอิงเป็น source of truth

## หน้าที่

ระบบ Chatbot **multi-org** สำหรับหน่วยงาน กทม. — แต่ละ org มี chatbot + เอกสาร RAG ของตัวเอง รองรับถอดเสียงประชุม (audio → WhisperX → chunks)

## Structure

```
chatbot/
├── api/          # auth · chat · documents · org · stats · transcribe · voice
├── lib/          # db · llm_client · doc_parser · rag · audio_splitter · auth_middleware · chat_helpers
├── admin/        # portal · chatbot-setup · orgs · logs · stats · transcribe (login.html)
├── chat/         # public chatbot UI (chat-widget.js)
├── assets/js/    # chat-widget.js · audio-recorder.js
├── config.php    # DB · LLM · RAG · WhisperX
├── schema.sql
└── web.config
```

## RAG pipeline

1. Admin upload (PDF/DOCX/TXT/Audio) → `api/documents.php?action=upload`
2. `doc_parser::extract_text()` (audio → WhisperX)
3. `rag::chunk_text()` (500 words, 50 overlap)
4. `rag::store_chunks()` → MySQL `doc_chunks` (FULLTEXT ngram)
5. ตอบ user → `rag::build_rag_context()` → top-3 chunks inject เข้า system prompt

## Tables

`users` · `organizations` · `documents` · `doc_chunks` · `chat_sessions` · `chat_messages` · `conversation_summaries` · `daily_stats` · `rate_limits` (20 msg/min) · `transcription_jobs` · `transcription_chunks`

## Auth

Session-based · roles `superadmin` / `admin` (org เดียว) · default `superadmin / 1234` (เปลี่ยนหลัง deploy)

## TODO/Pending (จาก CLAUDE.md)

- [ ] streaming response (SSE)
- [ ] Vector search (embeddings) แทน FULLTEXT — มี [design doc](C:/codex/chatbot-vector-rag-technical-design.md) (pgvector, status: design only)
- [ ] reset password user อื่นจาก portal
- [ ] notification เมื่อ transcription error
- [ ] export chat logs CSV
- [ ] Phase 3: สลับเป็น Typhoon `typhoon-v2-70b-instruct`

## Quick ref

```powershell
# PHP
C:\PHP\php-8.5.0\php.exe -l api\chat.php

# Reset superadmin
C:\PHP\php-8.5.0\php.exe -r "echo password_hash('newpass', PASSWORD_BCRYPT, ['cost'=>12]);"

# Test LLM
curl http://100.99.107.27:8000/v1/models
```
