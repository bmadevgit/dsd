# vLLM Monitoring Status

**Generated at:** 2026-05-05 13:02:27 +07

## Server Metrics

| Metric | Value |
|---|---|
| CPU Load (1m / 5m / 15m) | 0.57 / 0.47 / 0.45 |
| RAM (Used / Total) | 11363 MiB / 64300 MiB |
| RAM Free | 16981 MiB |
| Disk / (Used / Total) | 247G / 489G |
| Disk / Available | 217G |
| Disk / Usage | 54% |

## GPU Metrics

| GPU | Name | VRAM Used (MiB) | VRAM Total (MiB) | GPU Util (%) | Temp (C) |\n|---|---|---:|---:|---:|---:|\n| 0 | NVIDIA A40-48Q | 43770 | 49152 | 0 | [N/A] |\n

## All IP Addresses

| Interface | Family | Address |\n|---|---|---|\n| ens33 | inet | 172.27.15.60/24 |\n| tailscale0 | inet | 100.99.107.27/32 |\n| tailscale0 | inet6 | fd7a:115c:a1e0::5f01:6bb1/128 |\n| docker0 | inet | 172.17.0.1/16 |\n| br-a035af8c183a | inet | 172.18.0.1/16 |\n

## Listening Services and Ports

| Protocol | Listen IP | Port | Process |\n|---|---|---:|---|\n| udp | 127.0.0.54 | 53 | 0.0.0.0:* |\n| udp | 127.0.0.53%lo | 53 | 0.0.0.0:* |\n| udp | 0.0.0.0 | 5353 | 0.0.0.0:* |\n| udp | 0.0.0.0 | 41641 | 0.0.0.0:* |\n| udp | 0.0.0.0 | 57466 | 0.0.0.0:* |\n| udp | :: | 5353 | [::]:* |\n| udp | :: | 41616 | [::]:* |\n| udp | :: | 41641 | [::]:* |\n| tcp | 100.99.107.27 | 39125 | users:(("VLLM::EngineCor",pid=1776695,fd=79)) |\n| tcp | 100.99.107.27 | 39417 | users:(("VLLM::EngineCor",pid=1776695,fd=83)) |\n| tcp | 127.0.0.1 | 18003 | 0.0.0.0:* |\n| tcp | 100.99.107.27 | 44239 | users:(("VLLM::EngineCor",pid=1776695,fd=71)) |\n| tcp | 100.99.107.27 | 44465 | users:(("VLLM::EngineCor",pid=1776695,fd=87)) |\n| tcp | 100.99.107.27 | 42235 | users:(("VLLM::EngineCor",pid=1776695,fd=75)) |\n| tcp | 100.99.107.27 | 42145 | users:(("VLLM::EngineCor",pid=1776695,fd=67)) |\n| tcp | 127.0.0.1 | 25535 | users:(("node",pid=3299122,fd=58)) |\n| tcp | 0.0.0.0 | 11435 | users:(("python3",pid=1775747,fd=3)) |\n| tcp | 0.0.0.0 | 9443 | 0.0.0.0:* |\n| tcp | 127.0.0.1 | 631 | 0.0.0.0:* |\n| tcp | 127.0.0.54 | 53 | 0.0.0.0:* |\n| tcp | 100.99.107.27 | 55275 | 0.0.0.0:* |\n| tcp | 0.0.0.0 | 9004 | users:(("python3",pid=174209,fd=3)) |\n| tcp | 0.0.0.0 | 9093 | users:(("python",pid=1775753,fd=3)) |\n| tcp | 0.0.0.0 | 9092 | users:(("python",pid=1775752,fd=3)) |\n| tcp | 0.0.0.0 | 9091 | users:(("python3",pid=1776935,fd=3)) |\n| tcp | 0.0.0.0 | 9090 | users:(("python3",pid=1775747,fd=4)) |\n| tcp | 0.0.0.0 | 8002 | 0.0.0.0:* |\n| tcp | 0.0.0.0 | 8001 | users:(("python3",pid=1775835,fd=25)) |\n| tcp | 0.0.0.0 | 8000 | users:(("python3",pid=184055,fd=3)) |\n| tcp | 127.0.0.1 | 44525 | users:(("node",pid=3299122,fd=56)) |\n| tcp | 127.0.0.1 | 41855 | users:(("node",pid=3299540,fd=27)) |\n| tcp | 127.0.0.53%lo | 53 | 0.0.0.0:* |\n| tcp | 0.0.0.0 | 81 | 0.0.0.0:* |\n| tcp | 0.0.0.0 | 80 | 0.0.0.0:* |\n| tcp | 0.0.0.0 | 22 | 0.0.0.0:* |\n| tcp | 0.0.0.0 | 32769 | 0.0.0.0:* |\n| tcp | 0.0.0.0 | 32768 | 0.0.0.0:* |\n| tcp | 0.0.0.0 | 443 | 0.0.0.0:* |\n| tcp | 127.0.0.1 | 42331 | users:(("code-034f571df5",pid=3299078,fd=9)) |\n| tcp | ::1 | 631 | [::]:* |\n| tcp | ::1 | 3350 | [::]:* |\n| tcp | * | 47826 | users:(("node",pid=3299122,fd=49)) |\n| tcp | * | 47825 | users:(("node",pid=3299122,fd=43)) |\n| tcp | fd7a:115c:a1e0::5f01:6bb1 | 33363 | [::]:* |\n| tcp | :: | 9443 | [::]:* |\n| tcp | :: | 8002 | [::]:* |\n| tcp | * | 36985 | users:(("VLLM::EngineCor",pid=1776695,fd=59)) |\n| tcp | * | 3389 | *:* |\n| tcp | :: | 81 | [::]:* |\n| tcp | :: | 80 | [::]:* |\n| tcp | :: | 22 | [::]:* |\n| tcp | :: | 32769 | [::]:* |\n| tcp | :: | 32768 | [::]:* |\n| tcp | :: | 443 | [::]:* |\n

## vLLM API Health

| Check | Status | Detail |
|---|---|---|
| GET /v1/models or port :8000 | **Degraded** | Port 8000 is listening, but endpoint returned HTTP 401 |
