"""Fetch and publish the latest BMA canal water-level readings."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
import json
import logging
import os
from pathlib import Path
import tempfile
from urllib.request import Request, urlopen


SOURCE_URL = "https://bmaapi.bangkok.go.th/gw-api/dds_webservices/api/water/lastupdate"
INFO_URL = "https://bmaapi.bangkok.go.th/gw-api/dds_webservices/api/water/info"
OUTPUT = Path(r"C:\inetpub\wwwroot\now\canal-water-data.json")
KEY_PATH = Path(r"C:\ProgramData\BMANowMap\road-flood-key.txt")
BANGKOK = timezone(timedelta(hours=7))


def timestamp() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def number(value: object) -> float | None:
    try:
        return float(value) if value is not None and value != "" else None
    except (TypeError, ValueError):
        return None


def observed_at(value: object) -> str | None:
    try:
        parsed = datetime.fromisoformat(str(value))
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=BANGKOK)
        return parsed.isoformat(timespec="seconds")
    except (TypeError, ValueError):
        return None


def validate(payload: object, station_info: object) -> tuple[list[dict], int]:
    if not isinstance(payload, list) or len(payload) < 200:
        raise ValueError("Incomplete canal water response")
    if not isinstance(station_info, list) or len(station_info) < 200:
        raise ValueError("Incomplete canal station information response")
    metadata = {str(row.get("code") or ""): row for row in station_info}
    if len(metadata) < 200:
        raise ValueError("Incomplete canal station information")
    seen: set[str] = set()
    stations: list[dict] = []
    for row in payload:
        code = str(row.get("code") or "")
        if not code or code in seen:
            raise ValueError(f"Duplicate or missing canal station code {code}")
        seen.add(code)
        location = metadata.get(code)
        if not location:
            continue
        latitude = number(location.get("latitude"))
        longitude = number(location.get("longitude"))
        if latitude is None or longitude is None or not (-90 <= latitude <= 90) or not (-180 <= longitude <= 180):
            continue
        stations.append({
            "code": code, "name": str(location.get("name") or "").strip(),
            "river": str(location.get("river") or "").strip(),
            "district": str(location.get("district") or "").strip(),
            "lat": latitude, "lng": longitude,
            "status": str(row.get("status") or ""), "levelM": number(row.get("wl_in")),
            "outsideLevelM": number(row.get("wl_out01")),
            "outsideLevel2M": number(row.get("wl_out02")),
            "observedAt": observed_at(row.get("site_time")),
        })
    if len(stations) < 200:
        raise ValueError(f"Only {len(stations)} canal stations matched coordinates")
    return stations, len(payload)


def write_atomic(path: Path, snapshot: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temp = tempfile.mkstemp(prefix=".canal-water-", suffix=".tmp", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as file:
            json.dump(snapshot, file, ensure_ascii=False, separators=(",", ":"), allow_nan=False)
            file.flush()
            os.fsync(file.fileno())
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def sync(output: Path = OUTPUT, key_path: Path = KEY_PATH,
         source_url: str = SOURCE_URL, info_url: str = INFO_URL) -> bool:
    old = None
    if output.exists():
        try:
            old = json.loads(output.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            logging.exception("Existing canal water snapshot unreadable")
    now = timestamp()
    try:
        key = key_path.read_text(encoding="utf-8").strip()
        if not key:
            raise ValueError("BMA API key is empty")
        headers = {
            "KeyId": key, "Accept": "application/json", "User-Agent": "BMA-Now-Map/1.0",
        }
        with urlopen(Request(info_url, headers=headers), timeout=35) as response:
            station_info = json.load(response)
        with urlopen(Request(source_url, headers=headers), timeout=35) as response:
            readings = json.load(response)
        stations, source_total = validate(readings, station_info)
        write_atomic(output, {
            "lastAttemptAt": now, "lastFetchedAt": now, "fetchFailed": False,
            "sourceTotal": source_total, "mappedTotal": len(stations),
            "unmappedTotal": source_total - len(stations),
            "coordinateSource": "BMA water/info", "stations": stations,
        })
        logging.info("Fetched %s canal levels; %s have coordinates", source_total, len(stations))
        return True
    except Exception:
        logging.exception("Canal water fetch failed; retaining last valid snapshot")
        if old and isinstance(old.get("stations"), list):
            old.update({"lastAttemptAt": now, "fetchFailed": True})
            write_atomic(output, old)
        return False


if __name__ == "__main__":
    raise SystemExit(0 if sync() else 1)
