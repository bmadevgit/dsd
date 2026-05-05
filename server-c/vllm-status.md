# vLLM Monitoring Status

**Generated at:** 2026-05-05 13:00:06 +07

## Server Metrics

| Metric | Value |
|---|---|
| CPU Load (1m / 5m / 15m) | 0.49 / 0.49 / 0.45 |
| RAM (Used / Total) | 11345 MiB / 64300 MiB |
| RAM Free | 17001 MiB |
| Disk / (Used / Total) | 247G / 489G |
| Disk / Available | 217G |
| Disk / Usage | 54% |

## GPU Metrics

| GPU | Name | VRAM Used (MiB) | VRAM Total (MiB) | GPU Util (%) | Temp (C) |\n|---|---|---:|---:|---:|---:|\n| 0 | NVIDIA A40-48Q | 43770 | 49152 | 0 | [N/A] |\n

## vLLM API Health

| Check | Status | Detail |
|---|---|---|
| GET /v1/models or port :8000 | **Degraded** | Port 8000 is listening, but endpoint returned HTTP 401 |
