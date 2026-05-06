# exam/ar1 & exam/ar2 — Augmented Reality (Web AR)

**Path:** `C:\inetpub\wwwroot\exam\ar1` / `ar2`
**Stack:** JavaScript · WebGL · MindAR (ar1) · AR.js + NFT compiler (ar2)
**Tool:** Claude Code / Codex

---

## Timeline

- **2026-03-27** — สร้างทั้ง ar1 และ ar2 พร้อมกัน: HTML interface, marker files, compile scripts
- **2026-03-28** — ar2 feature expansion: NFT training data, marker.html, `fset`/`fset3`/`iset` files

## ar1 — QR Marker Tracking

- Web AR ด้วย QR/image marker tracking (MindAR library)
- Real-time camera + 3D model rendering บน browser
- ไม่ต้องติดตั้ง app ใด ๆ

## ar2 — Natural Feature Tracking (NFT)

- Web AR ขั้นสูงด้วย Natural Feature Tracking
- จำรูปภาพจริงได้โดยไม่ต้องใช้ QR code
- Node.js NFT compiler สำหรับ train marker จากรูปภาพ

## Status

**Proof of Concept** — ทำงานได้ ยังไม่ผ่าน production deployment

---

## Recent Activity

_auto-updated 

### Files changed recently

- `index.html` 2026-03-28 11:06
- `target.mind` 2026-03-27 21:55
- `compile.js` 2026-03-27 21:55
