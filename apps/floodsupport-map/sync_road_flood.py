"""Fetch and publish the latest BMA road flood sensor readings."""

from __future__ import annotations

from datetime import datetime, timezone
import json
import logging
import os
from pathlib import Path
import tempfile
from urllib.request import Request, urlopen


SOURCE_URL = "https://bmaapi.bangkok.go.th/gw-api/fetch-and-save-data/sensor-flood-latest-record"
OUTPUT = Path(r"C:\inetpub\wwwroot\now\road-flood-data.json")
KEY_PATH = Path(r"C:\ProgramData\BMANowMap\road-flood-key.txt")


def timestamp() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def validate(payload: object) -> list[dict]:
    if not isinstance(payload, dict) or not isinstance(payload.get("data"), list):
        raise ValueError("Missing sensor data")
    rows = payload["data"]
    if not rows or not isinstance(payload.get("meta"), dict) or payload["meta"].get("total") != len(rows):
        raise ValueError("Incomplete sensor response")
    sensors: list[dict] = []
    ids: set[str] = set()
    for row in rows:
        profile = row.get("sensor_profile") or {}
        sensor_id = str(row.get("sensor_profile_id") or "")
        if not sensor_id or sensor_id in ids:
            raise ValueError(f"Duplicate or missing sensor ID {sensor_id}")
        ids.add(sensor_id)
        lat, lon = float(profile["lat"]), float(profile["long"])
        if not (13.3 <= lat <= 14.2 and 100.1 <= lon <= 101.2):
            raise ValueError(f"Invalid coordinates for sensor {sensor_id}")
        observed = datetime.fromtimestamp(int(row["timestamp"]) / 1000, timezone.utc)
        raw_value = row.get("value")
        try:
            value = float(raw_value) if raw_value is not None and raw_value != "" else None
        except (TypeError, ValueError):
            value = None
        sensors.append({
            "id": sensor_id, "code": str(row.get("sensor_name") or ""),
            "name": str(row.get("name") or ""), "road": str(profile.get("road") or ""),
            "district": str(row.get("district") or ""), "lat": lat, "lon": lon,
            "status": str(row.get("device_status") or ""), "valueCm": value,
            "observedAt": observed.isoformat(timespec="seconds").replace("+00:00", "Z"),
        })
    return sensors


def write_atomic(path: Path, snapshot: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temp = tempfile.mkstemp(prefix=".road-flood-", suffix=".tmp", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as file:
            json.dump(snapshot, file, ensure_ascii=False, separators=(",", ":"), allow_nan=False)
            file.flush()
            os.fsync(file.fileno())
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def sync(output: Path = OUTPUT, key_path: Path = KEY_PATH, source_url: str = SOURCE_URL) -> bool:
    old = None
    if output.exists():
        try:
            old = json.loads(output.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            logging.exception("Existing road flood snapshot unreadable")
    now = timestamp()
    try:
        key = key_path.read_text(encoding="utf-8").strip()
        if not key:
            raise ValueError("Road flood API key is empty")
        request = Request(source_url, headers={"KeyId": key, "Accept": "application/json", "User-Agent": "BMA-Now-Map/1.0"})
        with urlopen(request, timeout=35) as response:
            sensors = validate(json.load(response))
        write_atomic(output, {"lastAttemptAt": now, "lastFetchedAt": now,
                              "fetchFailed": False, "total": len(sensors), "sensors": sensors})
        logging.info("Fetched %s road flood sensors", len(sensors))
        return True
    except Exception:
        logging.exception("Road flood fetch failed; retaining last valid snapshot")
        if old and isinstance(old.get("sensors"), list):
            old.update({"lastAttemptAt": now, "fetchFailed": True})
            write_atomic(output, old)
        return False
