"""Fetch Bangkok district nowcast every 15 minutes via Task Scheduler."""

from __future__ import annotations

from datetime import datetime, timezone
import json
import logging
import os
from pathlib import Path
import tempfile
from urllib.request import Request, urlopen


SOURCE_URL = "https://nowcast.bangkok.go.th/api/zonal"
OUTPUT = Path(r"C:\inetpub\wwwroot\now\nowcast-data.json")
LOG = Path(r"C:\ProgramData\BMAFloodSupport\nowcast-sync.log")


def timestamp() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def validate(payload: object) -> dict:
    if not isinstance(payload, dict) or not isinstance(payload.get("districts"), dict):
        raise ValueError("Missing district data")
    districts = payload["districts"]
    if len(districts) != 50 or any(not isinstance(v, dict) or v.get("district_i") != k or
                                not isinstance(v.get("district_t"), str) or not v["district_t"]
                                for k, v in districts.items()):
        raise ValueError("Expected 50 coded districts with Thai names")
    if not payload.get("run_id") or not payload.get("generated_at"):
        raise ValueError("Missing forecast run metadata")
    return payload


def write_atomic(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, name = tempfile.mkstemp(prefix=".nowcast-", suffix=".tmp", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as file:
            json.dump(data, file, ensure_ascii=False, separators=(",", ":"))
            file.flush()
            os.fsync(file.fileno())
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def sync(output: Path = OUTPUT, source_url: str = SOURCE_URL) -> bool:
    old = None
    if output.exists():
        try:
            old = json.loads(output.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            logging.exception("Existing nowcast snapshot is unreadable")
    now = timestamp()
    try:
        request = Request(source_url, headers={"Accept": "application/json", "User-Agent": "BMA-Now-Map/1.0"})
        with urlopen(request, timeout=25) as response:
            payload = validate(json.load(response))
        snapshot = {"lastAttemptAt": now, "lastFetchedAt": now, "fetchFailed": False, "payload": payload}
        write_atomic(output, snapshot)
        logging.info("Nowcast run %s fetched", payload["run_id"])
        return True
    except Exception:
        logging.exception("Nowcast fetch failed; retaining last valid payload")
        if old and isinstance(old.get("payload"), dict):
            old.update({"lastAttemptAt": now, "fetchFailed": True})
            write_atomic(output, old)
        return False


if __name__ == "__main__":
    LOG.parent.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(filename=LOG, level=logging.INFO,
                        format="%(asctime)s %(levelname)s %(message)s", encoding="utf-8")
    raise SystemExit(0 if sync() else 1)
