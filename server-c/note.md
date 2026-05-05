# Server-C Setup Timeline

## 2026-05-05

| Time (UTC+7) | Event | Detail |
|---|---|---|
| 12:59 | Initial vLLM monitor automation completed | `monitor_vllm.sh` successfully generated report and pushed to `main`. |
| 13:00 | Report path moved to `server-c/` | Output changed to `server-c/vllm-status.md` and directory auto-create was added. |
| 13:02 | Network visibility data added | Added `All IP Addresses` and `Listening Services and Ports` sections. |
| 13:05 | API access metadata added | Added hostname, kernel, uptime, default interface, primary IP, and API access guide for other machines. |
| 13:08 | Markdown tables improved | Reworked `All IP Addresses`, `Listening Services and Ports`, and `API Access Guide` into cleaner table format. |
| 13:15 | Operations docs added | Created `server-c/note.md` and `server-c/Error.md` timeline docs. |
| 13:15 | Daily auto-push scheduled design | Prepared daily `04:00` auto-push for `server-c/` changes. |

## Current Operational Components

| Component | Path | Purpose |
|---|---|---|
| Monitor script | `/home/administrator/monitor_vllm.sh` | Collects host, GPU, vLLM health, ports, API guide and pushes report. |
| Status report | `/home/administrator/dsd/server-c/vllm-status.md` | Latest generated monitoring snapshot in Markdown. |
| Daily push script | `/home/administrator/push_server_c_daily.sh` | Commits/pushes only `server-c/` changes at scheduled time. |
