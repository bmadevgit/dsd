# exam/server — Server Analytics Dashboard

**Path:** `C:\inetpub\wwwroot\exam\server`
**Stack:** Python 3.11 · Streamlit · Pandas · Plotly · MySQL · Qwen2.5-32B
**Tool:** Claude Code

---

## Timeline

- **2026-04-04** — เริ่มโปรเจกต์: Gemini config notes (`GEMINI.md`), Streamlit app (`app.py`), analyzer (`analyzer.py`), db updater (`db_update.py`)
- **2026-04-17** — เพิ่ม service monitor scripts: `keep_streamlit_alive.ps1` (Windows), `.sh` (Linux), `run_streamlit.bat`, `run_analyzer.bat`
- **2026-04-18** — Streamlit service running (log active)

## Features

- Dashboard วิเคราะห์ log ของ server:
  - IIS request logs (top IPs, status codes, hourly traffic)
  - MySQL slow query monitoring
  - Windows Security Event tracking
- Traffic visualization ด้วย Plotly
- Vulnerability detection (suspicious URIs, attack patterns)
- AI insights ด้วย Qwen2.5-32B
- Auto-restart service (PowerShell + bash watchdog)

## Tables (MySQL)

`iis_status_summary` · `iis_top_ips` · `mysql_slow_queries` · `iis_vulnerabilities` · `iis_error_uris` · `iis_traffic_hourly` · `windows_event_summary`

## Status

**Active** — Streamlit service กำลัง run อยู่, ต้องตั้ง IIS reverse proxy
