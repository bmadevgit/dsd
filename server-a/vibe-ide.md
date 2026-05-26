# vibe-ide — AI-Powered Web IDE

**Path:** `C:\inetpub\vibe-ide`
**Stack:** ASP.NET Core 8 · C# · EF Core · SQLite · React 19 · TypeScript · Vite · Monaco Editor · SignalR · JWT
**Tool:** Claude Code / Codex / Vibe Coding

---

## Timeline

- **2023-06-05 – 2023-10-15** — Phase 1-3: พัฒนา backend หลัก
  - Auth system (JWT + BCrypt + RBAC)
  - SQLite schema + EF Core migrations
  - Project CRUD, workspace file APIs
  - Monaco Editor integration
  - Qwen LLM chat, token tracking
  - PDF/document parsing (UglyToad.PdfPig)
- **2024-02 – 2024-11** — Phase 4: เพิ่ม features ขั้นสูง
  - Preview endpoint + SignalR real-time updates
  - Publish/deploy to IIS folder (`wwwroot/exam/ai/<slug>`)
  - Security library updates (JWT, Identity)
- **2026-02-03 – 2026-03-15** — maintenance และ updates
- **2026-04-22** — **Major Release** — npm build frontend ครบ (8,630 files)
  - Node.js build + dependency resolution
  - Vite build artifacts
  - Full stack compilation สมบูรณ์
- **2026-04-23** — post-deployment verification (81 files)

## Features

- Multi-user system (Admin / User roles)
- AI website builder ด้วย Qwen LLM (local inference)
- Monaco code editor + preview iframe real-time
- Chat กับ LLM พร้อม attachment (txt, md, json, pdf, docx, audio)
- Publish project → deploy ไปที่ IIS folder อัตโนมัติ
- SignalR real-time preview updates
- Token usage analytics
- Admin dashboard จัดการ user

## TODO (ค้างอยู่)

- [ ] Streaming chat rendering
- [ ] Visual diff modal
- [ ] Drag-drop file tree
- [ ] Background job queue
- [ ] External transcription providers

## Status

**Production (Phase 5)** — ใช้งานได้เต็มรูปแบบ

<!-- AUTO_SECTION_START -->

## AI Dev Memory

_auto-updated 2026-05-26 20:18:09_

### Snapshot

- Path: `C:\inetpub\vibe-ide`
- Stack: Unknown
- Entry points: (none)
- Config files: .env.example, README.md, AGENTS.md
- DB hints: sqlite

### Recent Files

- `frontend\src\index.css` 2026-04-23 05:59
- `frontend\src\pages\WorkspacePage.tsx` 2026-04-23 05:59
- `frontend\src\components\WorkspaceStatusBanner.tsx` 2026-04-23 05:59
- `frontend\src\hooks\useWorkspaceChat.ts` 2026-04-23 05:59
- `frontend\src\hooks\useWorkspaceFiles.ts` 2026-04-23 05:59
- `frontend\src\components\WorkspaceChatPanel.tsx` 2026-04-23 05:08
- `frontend\src\components\WorkspaceEditorPanel.tsx` 2026-04-23 05:07
- `frontend\src\hooks\useWorkspacePreview.ts` 2026-04-23 05:05
- `frontend\src\types\workspace.ts` 2026-04-23 05:05
- `frontend\src\components\WorkspacePreviewPanel.tsx` 2026-04-23 05:00

### Git Commits

- 2026-05-18 fb174d487 fix: restore history/ and wwwroot/ gitignore rules to hide IIS config snapshots

<!-- AUTO_SECTION_END -->
