# exam/chatbot — Multi-Tenant Chatbot Platform

**Path:** `C:\inetpub\wwwroot\exam\chatbot`
**Stack:** PHP 8.1 · PSR-4 Autoload · Composer · MySQL · RAG
**Tool:** Claude Code

---

## Timeline

- **2026-04-03** — สร้างระบบทั้งหมดในวันเดียว: `db.php`, `auth_middleware.php`, `rag.php`, `chat_helpers.php`, `index.php`
- **2026-04-12** — Final refinements

## Features

- Framework chatbot รองรับหลาย tenant (white-label)
- RAG pipeline (`rag.php`)
- Auth middleware
- PSR-4 autoloading (Composer)

## Status

**Completed** — โครงสร้างพร้อม ใช้เป็น base สำหรับ deploy หลาย tenant

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\wwwroot\exam\chatbot`
- Stack: PHP
- Entry points: index.php
- Config files: web.config, config.php, schema.sql, CLAUDE.md
- DB hints: mysql/pdo

### Recent Files

- `CLAUDE.md` 2026-04-12 17:37
- `api\chat.php` 2026-04-12 09:54
- `assets\js\chat-widget.js` 2026-04-12 09:54
- `chat\index.html` 2026-04-12 09:53
- `admin\portal.html` 2026-04-12 09:53
- `admin\chatbot-setup.html` 2026-04-12 09:43
- `api\documents.php` 2026-04-12 09:42
- `lib\doc_parser.php` 2026-04-12 09:42
- `config.php` 2026-04-12 09:42
- `lib\llm_client.php` 2026-04-12 09:30

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

<!-- AUTO_SECTION_END -->
