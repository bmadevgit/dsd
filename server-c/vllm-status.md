# vLLM Monitoring Status

**Generated at:** 2026-05-05 13:08:20 +07
**Hostname:** DGTSSPAIA01.tail1f61dd.ts.net  
**Kernel:** 6.8.0-107-generic  
**Uptime:** up 3 weeks, 5 days, 17 hours, 14 minutes  
**Default Interface:** ens33  
**Primary IP:** 172.27.15.60

## Server Metrics

| Metric | Value |
|---|---|
| CPU Load (1m / 5m / 15m) | 0.57 / 0.46 / 0.45 |
| RAM (Used / Total) | 11357 MiB / 64300 MiB |
| RAM Free | 16985 MiB |
| Disk / (Used / Total) | 247G / 489G |
| Disk / Available | 217G |
| Disk / Usage | 54% |

## GPU Metrics

| GPU | Name | VRAM Used (MiB) | VRAM Total (MiB) | GPU Util (%) | Temp (C) |\n|---|---|---:|---:|---:|---:|\n| 0 | NVIDIA A40-48Q | 43770 | 49152 | 0 | [N/A] |\n

## All IP Addresses

| Interface | Family | Address |
|---|---|---|
| ens33 | inet | 172.27.15.60/24 |
| tailscale0 | inet | 100.99.107.27/32 |
| tailscale0 | inet6 | fd7a:115c:a1e0::5f01:6bb1/128 |
| docker0 | inet | 172.17.0.1/16 |
| br-a035af8c183a | inet | 172.18.0.1/16 |

## Listening Services and Ports

| Port | Protocol | Listen IP | Access | Process |
|---:|---|---|---|---|
| 22 | tcp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 22 | tcp | :: | All interfaces | [::]:* |
| 53 | tcp | 127.0.0.53%lo | Specific interface | 0.0.0.0:* |
| 53 | tcp | 127.0.0.54 | Specific interface | 0.0.0.0:* |
| 53 | udp | 127.0.0.53%lo | Specific interface | 0.0.0.0:* |
| 53 | udp | 127.0.0.54 | Specific interface | 0.0.0.0:* |
| 80 | tcp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 80 | tcp | :: | All interfaces | [::]:* |
| 81 | tcp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 81 | tcp | :: | All interfaces | [::]:* |
| 443 | tcp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 443 | tcp | :: | All interfaces | [::]:* |
| 631 | tcp | 127.0.0.1 | Localhost only | 0.0.0.0:* |
| 631 | tcp | ::1 | Localhost only | [::]:* |
| 3350 | tcp | ::1 | Localhost only | [::]:* |
| 3389 | tcp | * | All interfaces | *:* |
| 5353 | udp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 5353 | udp | :: | All interfaces | [::]:* |
| 8000 | tcp | 0.0.0.0 | All interfaces | python3 |
| 8001 | tcp | 0.0.0.0 | All interfaces | python3 |
| 8002 | tcp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 8002 | tcp | :: | All interfaces | [::]:* |
| 9004 | tcp | 0.0.0.0 | All interfaces | python3 |
| 9090 | tcp | 0.0.0.0 | All interfaces | python3 |
| 9091 | tcp | 0.0.0.0 | All interfaces | python3 |
| 9092 | tcp | 0.0.0.0 | All interfaces | python |
| 9093 | tcp | 0.0.0.0 | All interfaces | python |
| 9443 | tcp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 9443 | tcp | :: | All interfaces | [::]:* |
| 11435 | tcp | 0.0.0.0 | All interfaces | python3 |
| 18003 | tcp | 127.0.0.1 | Localhost only | 0.0.0.0:* |
| 25535 | tcp | 127.0.0.1 | Localhost only | node |
| 32768 | tcp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 32768 | tcp | :: | All interfaces | [::]:* |
| 32769 | tcp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 32769 | tcp | :: | All interfaces | [::]:* |
| 33363 | tcp | fd7a:115c:a1e0::5f01:6bb1 | Specific interface | [::]:* |
| 36985 | tcp | * | All interfaces | VLLM::EngineCor |
| 39125 | tcp | 100.99.107.27 | Specific interface | VLLM::EngineCor |
| 39417 | tcp | 100.99.107.27 | Specific interface | VLLM::EngineCor |
| 41616 | udp | :: | All interfaces | [::]:* |
| 41641 | udp | 0.0.0.0 | All interfaces | 0.0.0.0:* |
| 41641 | udp | :: | All interfaces | [::]:* |
| 41855 | tcp | 127.0.0.1 | Localhost only | node |
| 42145 | tcp | 100.99.107.27 | Specific interface | VLLM::EngineCor |
| 42235 | tcp | 100.99.107.27 | Specific interface | VLLM::EngineCor |
| 42331 | tcp | 127.0.0.1 | Localhost only | code-034f571df5 |
| 44239 | tcp | 100.99.107.27 | Specific interface | VLLM::EngineCor |
| 44465 | tcp | 100.99.107.27 | Specific interface | VLLM::EngineCor |
| 44525 | tcp | 127.0.0.1 | Localhost only | node |
| 47825 | tcp | * | All interfaces | node |
| 47826 | tcp | * | All interfaces | node |
| 55275 | tcp | 100.99.107.27 | Specific interface | 0.0.0.0:* |
| 57466 | udp | 0.0.0.0 | All interfaces | 0.0.0.0:* |

## API Access Guide (For Other Machines)

| Service | Port | Reachability | Example URL from Other Machine |
|---|---:|---|---|
| 0.0.0.0:* | 22 | All interfaces | http://172.27.15.60:22/ |
| [::]:* | 22 | All interfaces | http://172.27.15.60:22/ |
| 0.0.0.0:* | 53 | Specific interface | http://127.0.0.53%lo:53/ |
| 0.0.0.0:* | 53 | Specific interface | http://127.0.0.54:53/ |
| 0.0.0.0:* | 80 | All interfaces | http://172.27.15.60:80/ |
| [::]:* | 80 | All interfaces | http://172.27.15.60:80/ |
| 0.0.0.0:* | 81 | All interfaces | http://172.27.15.60:81/ |
| [::]:* | 81 | All interfaces | http://172.27.15.60:81/ |
| 0.0.0.0:* | 443 | All interfaces | http://172.27.15.60:443/ |
| [::]:* | 443 | All interfaces | http://172.27.15.60:443/ |
| 0.0.0.0:* | 631 | Localhost only | http://127.0.0.1:631/ |
| [::]:* | 631 | Localhost only | http://127.0.0.1:631/ |
| [::]:* | 3350 | Localhost only | http://127.0.0.1:3350/ |
| *:* | 3389 | All interfaces | http://172.27.15.60:3389/ |
| python3 | 8000 | All interfaces | http://172.27.15.60:8000/ |
| vLLM API | 8000 | All interfaces | http://172.27.15.60:8000/v1/models |
| python3 | 8001 | All interfaces | http://172.27.15.60:8001/ |
| 0.0.0.0:* | 8002 | All interfaces | http://172.27.15.60:8002/ |
| [::]:* | 8002 | All interfaces | http://172.27.15.60:8002/ |
| python3 | 9004 | All interfaces | http://172.27.15.60:9004/ |
| python3 | 9090 | All interfaces | http://172.27.15.60:9090/ |
| python3 | 9091 | All interfaces | http://172.27.15.60:9091/ |
| python | 9092 | All interfaces | http://172.27.15.60:9092/ |
| python | 9093 | All interfaces | http://172.27.15.60:9093/ |
| 0.0.0.0:* | 9443 | All interfaces | http://172.27.15.60:9443/ |
| [::]:* | 9443 | All interfaces | http://172.27.15.60:9443/ |
| python3 | 11435 | All interfaces | http://172.27.15.60:11435/ |
| 0.0.0.0:* | 18003 | Localhost only | http://127.0.0.1:18003/ |
| node | 25535 | Localhost only | http://127.0.0.1:25535/ |
| 0.0.0.0:* | 32768 | All interfaces | http://172.27.15.60:32768/ |
| [::]:* | 32768 | All interfaces | http://172.27.15.60:32768/ |
| 0.0.0.0:* | 32769 | All interfaces | http://172.27.15.60:32769/ |
| [::]:* | 32769 | All interfaces | http://172.27.15.60:32769/ |
| [::]:* | 33363 | Specific interface | http://fd7a:115c:a1e0::5f01:6bb1:33363/ |
| VLLM::EngineCor | 36985 | All interfaces | http://172.27.15.60:36985/ |
| VLLM::EngineCor | 39125 | Specific interface | http://100.99.107.27:39125/ |
| VLLM::EngineCor | 39417 | Specific interface | http://100.99.107.27:39417/ |
| node | 41855 | Localhost only | http://127.0.0.1:41855/ |
| VLLM::EngineCor | 42145 | Specific interface | http://100.99.107.27:42145/ |
| VLLM::EngineCor | 42235 | Specific interface | http://100.99.107.27:42235/ |
| code-034f571df5 | 42331 | Localhost only | http://127.0.0.1:42331/ |
| VLLM::EngineCor | 44239 | Specific interface | http://100.99.107.27:44239/ |
| VLLM::EngineCor | 44465 | Specific interface | http://100.99.107.27:44465/ |
| node | 44525 | Localhost only | http://127.0.0.1:44525/ |
| node | 47825 | All interfaces | http://172.27.15.60:47825/ |
| node | 47826 | All interfaces | http://172.27.15.60:47826/ |
| 0.0.0.0:* | 55275 | Specific interface | http://100.99.107.27:55275/ |

## vLLM API Health

| Check | Status | Detail |
|---|---|---|
| GET /v1/models or port :8000 | **Degraded** | Port 8000 is listening, but endpoint returned HTTP 401 |
