# Realtime Thai Meeting Transcription — Frontend (`realtime`)

- **Path:** `C:\inetpub\wwwroot\realtime`
- **URL:** `http://172.27.15.6/realtime`
- **Stack:** Static HTML + vanilla JS (ไม่มี build, ไม่มี framework)

> [realtime/README.md](C:/inetpub/wwwroot/realtime/README.md) มีคู่มือใช้งาน

## หน้าที่

Frontend สำหรับระบบถอดเสียงประชุมแบบเรียลไทม์ (on-prem) — เปิดไมค์ → downsample 16kHz mono PCM Int16 → ส่งเข้า WebSocket binary frame → แสดง partial/final transcript + summary

## Files

| ไฟล์ | บทบาท |
|---|---|
| `index.html` | โครงหน้า (สถานะ connection, panel transcript, summary) |
| `styles.css` | theme + responsive |
| `audio-utils.js` | downsample → 16kHz mono PCM Int16 |
| `app.js` | mic, websocket, transcript, summary, auto-reconnect |

## Backend ที่เรียก

- WebSocket default: `ws://<host>/ws/audio`
- จริงบนเครื่องนี้ ชี้ไป backend port 9120 (ดู [realtime-backend.md](realtime-backend.md))

## Message protocol (JSON ที่รับจาก WS)

| `type` | ฟิลด์ที่ใช้ |
|---|---|
| `partial_transcript` | `text` (fallback `partial`) |
| `final_transcript` | `text` (fallback `final`) |
| `summary_update` | `summary`, `key_points[]`, `decisions[]`, `action_items[]`, `risks_or_followups[]` |
| `error` | `message` |

## ข้อจำกัด

- **ไม่เรียก vLLM โดยตรงจาก browser** (ไม่มี OpenAI client ฝั่ง client)
- Audio ส่งเป็น binary frame (`ArrayBuffer`) ไม่ใช่ base64
- มี auto-reconnect เมื่อ WebSocket หลุดระหว่างกำลังอัด
