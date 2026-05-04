# Realtime Thai Transcribe — Backend (Machine A)

- **Path:** `C:\apps\realtime-thai-transcribe`
- **Stack:** Python + FastAPI + uvicorn (in `.venv`)
- **Entry:** `app.main:app` ([app/main.py](C:/apps/realtime-thai-transcribe/app/main.py))
- **Port:** `9120` (TLS เปิดอยู่ → WSS)
- **WebSocket:** `wss://172.27.15.6:9120/ws/audio`
- **Health:** `https://127.0.0.1:9120/health`

> [realtime-thai-transcribe/README.md](C:/apps/realtime-thai-transcribe/README.md)

## หน้าที่

รับ audio binary frame จาก [realtime frontend](realtime-frontend.md), ทำ VAD → ASR (faster-whisper) → ส่ง partial/final transcript กลับ + เรียก vLLM ทำ summary เป็นช่วง

## Start / Stop

```powershell
powershell -ExecutionPolicy Bypass -File C:\apps\realtime-thai-transcribe\scripts\start-backend.ps1
powershell -ExecutionPolicy Bypass -File C:\apps\realtime-thai-transcribe\scripts\stop-backend.ps1
```

## Logs

- `C:\apps\realtime-thai-transcribe\logs\backend.out.log`
- `C:\apps\realtime-thai-transcribe\logs\backend.err.log`

## Environment (จาก .env.example)

| Group | คีย์สำคัญ |
|---|---|
| Server | `HOST=0.0.0.0`, `PORT=9120` |
| Session | `SESSION_TTL_SEC=900`, `CLEANUP_INTERVAL_SEC=30` |
| Audio | `AUDIO_SAMPLE_RATE=16000`, `AUDIO_CHANNELS=1` |
| VAD | `VAD_AGGRESSIVENESS=2`, `VAD_FRAME_MS=30`, `VAD_ENDPOINT_SILENCE_SEC=1.0`, `MIN_UTTERANCE_SEC=0.7` |
| ASR | `ASR_MODEL_SIZE=small`, `ASR_DEVICE=cpu`, `ASR_COMPUTE_TYPE=int8`, `ASR_LANGUAGE=th`, `PARTIAL_INTERVAL_SEC=1.6` |
| Summary | `SUMMARY_ENABLED=true`, `SUMMARY_INTERVAL_SEC=12`, `SUMMARY_MIN_NEW_CHARS=120`, `SUMMARY_MIN_TOTAL_CHARS=80`, `SUMMARY_MODEL=Qwen/Qwen3-14B` |
| vLLM | `VLLM_BASE_URL=http://172.27.15.60:8000/v1`, `VLLM_API_KEY=EMPTY`, `SUMMARY_REQUEST_TIMEOUT_SEC=35` |
| TLS | `ENABLE_WSS_TLS=true`, `TLS_CERT_FILE=C:\apps\realtime-thai-transcribe\certs\realtime-172.27.15.6-cert.pem`, `TLS_KEY_FILE=...key.pem` |

## Migration bundle

`C:\codex\migration-realtime-172.27.15.59` + `migration-realtime-172.27.15.59.zip` — bundle ย้ายไปเครื่อง `172.27.15.59` (Ubuntu, ดูได้จาก SSH workspace ใน VS Code)

ดู `C:\codex\tmp_realtime_ubuntu_bundle*` สำหรับ Linux deploy
