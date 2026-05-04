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
