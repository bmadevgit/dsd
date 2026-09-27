#!/usr/bin/env python3
"""Build the public flood support snapshot from the public API and BMA POIs."""

from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import json
import logging
import math
import os
from pathlib import Path
import re
import sys
import time
from urllib.parse import urlsplit
from uuid import uuid4

import requests


SOURCE_URL = "https://floodsupport.awarehouse.tech/api/data"
POI_URL = (
    "https://citymap.bangkok.go.th/citymap/rest/services/"
    "Basemap_Service/Basemap1000_32647_H/MapServer/0/query"
)
WEBROOT = Path(r"C:\inetpub\wwwroot\now")
STATE_DIR = Path(r"C:\ProgramData\BMAFloodSupport")
OUTPUT = WEBROOT / "floodsupport-data.json"
POI_CACHE = STATE_DIR / "poi-cache.json"
OVERRIDES = STATE_DIR / "verified-locations.json"
LOG = STATE_DIR / "sync.log"
CURL_CFFI_PACKAGES = Path(r"C:\ProgramData\BMAFloodAlert\python-packages")


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def write_json_atomic(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + "." + uuid4().hex + ".tmp")
    try:
        with temp.open("w", encoding="utf-8", newline="\n") as stream:
            json.dump(value, stream, ensure_ascii=False, separators=(",", ":"))
            stream.write("\n")
        os.replace(temp, path)
    finally:
        temp.unlink(missing_ok=True)


def read_json(path: Path, default: object) -> object:
    if not path.is_file():
        return default
    with path.open(encoding="utf-8") as stream:
        return json.load(stream)


def cached_point(entry: object) -> dict | None:
    value = entry.get("point") if isinstance(entry, dict) and "checkedAt" in entry else entry
    return value if isinstance(value, dict) and valid_point(value.get("lat"), value.get("lon")) else None


def cache_expired(entry: object) -> bool:
    if not isinstance(entry, dict) or not isinstance(entry.get("checkedAt"), str):
        return True
    try:
        checked = datetime.fromisoformat(entry["checkedAt"].replace("Z", "+00:00"))
        age = (datetime.now(timezone.utc) - checked).total_seconds()
        return age < 0 or age > (86400 if entry.get("point") is None else 7 * 86400)
    except ValueError:
        return True


def valid_point(lat: object, lon: object) -> bool:
    try:
        a, b = float(lat), float(lon)
    except (TypeError, ValueError):
        return False
    return math.isfinite(a) and math.isfinite(b) and 13.4 <= a <= 14.2 and 100.25 <= b <= 100.95


def google_target(link: object) -> dict | None:
    """Only a place's explicit !3d/!4d target is a coordinate, never @ viewport."""
    if not isinstance(link, str):
        return None
    parts = urlsplit(link.strip())
    if parts.hostname not in {"google.com", "www.google.com"} or not parts.path.startswith("/maps/place/"):
        return None
    pairs = set(re.findall(r"!3d(-?\d+(?:\.\d+)?)!4d(-?\d+(?:\.\d+)?)", link))
    if len(pairs) != 1:
        return None
    lat, lon = next(iter(pairs))
    if not valid_point(lat, lon):
        return None
    return {"lat": float(lat), "lon": float(lon), "method": "google-place-target"}


def point_distance_m(a: dict, b: dict) -> float:
    la, lb = math.radians(a["lat"]), math.radians(b["lat"])
    dlat = lb - la
    dlon = math.radians(b["lon"] - a["lon"])
    h = math.sin(dlat / 2) ** 2 + math.cos(la) * math.cos(lb) * math.sin(dlon / 2) ** 2
    return 6371000 * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h))


def query_poi(name: str, district: str) -> dict | None:
    quote = lambda value: value.replace("'", "''")
    response = requests.get(
        POI_URL,
        params={
            "where": f"NAME='{quote(name)}' AND DISTRICT='{quote(district)}'",
            "outFields": "OBJECTID,NAME,DISTRICT",
            "returnGeometry": "true",
            "outSR": "4326",
            "f": "json",
        },
        timeout=20,
    )
    response.raise_for_status()
    payload = response.json()
    if payload.get("error"):
        raise RuntimeError(str(payload["error"]))
    features = payload.get("features")
    if not isinstance(features, list):
        raise ValueError("POI response has no features")
    if len(features) != 1:
        return None
    feature = features[0]
    attrs = feature.get("attributes") or {}
    geometry = feature.get("geometry") or {}
    lat, lon = geometry.get("y"), geometry.get("x")
    if attrs.get("NAME") != name or attrs.get("DISTRICT") != district or not valid_point(lat, lon):
        return None
    return {
        "lat": float(lat),
        "lon": float(lon),
        "method": "bma-poi-exact",
        "poiObjectId": attrs.get("OBJECTID"),
    }


def load_overrides() -> dict:
    value = read_json(OVERRIDES, {})
    if not isinstance(value, dict):
        raise ValueError("verified-locations.json must be an object")
    clean = {}
    for facility_id, point in value.items():
        if not isinstance(point, dict) or not valid_point(point.get("lat"), point.get("lon")):
            raise ValueError(f"Invalid verified coordinate for {facility_id}")
        if not all(isinstance(point.get(key), str) and point[key].strip() for key in ("verifiedBy", "verifiedAt", "source")):
            raise ValueError(f"Missing verification provenance for {facility_id}")
        clean[facility_id] = {
            "lat": float(point["lat"]),
            "lon": float(point["lon"]),
            "method": "manual-verified",
        }
    return clean


def validate_source(payload: object) -> tuple[list[dict], list[str]]:
    if not isinstance(payload, dict) or not isinstance(payload.get("facilities"), list):
        raise ValueError("Source payload has no facilities array")
    if not isinstance(payload.get("categories"), list) or not all(isinstance(c, str) for c in payload["categories"]):
        raise ValueError("Source payload has no categories array")
    facilities = payload["facilities"]
    ids = set()
    for row in facilities:
        if not isinstance(row, dict) or not all(isinstance(row.get(key), str) and row[key].strip() for key in ("id", "name", "district", "category", "status")):
            raise ValueError("Invalid source facility")
        if row["id"] in ids:
            raise ValueError("Duplicate source facility ID")
        ids.add(row["id"])
    return facilities, payload["categories"]


def fetch_source() -> dict:
    last_error = None
    if CURL_CFFI_PACKAGES.is_dir():
        sys.path.insert(0, str(CURL_CFFI_PACKAGES))
        try:
            from curl_cffi import requests as browser_requests
            response = browser_requests.get(SOURCE_URL, timeout=15, impersonate="chrome136")
            response.raise_for_status()
            return response.json()
        except Exception as exc:
            last_error = exc
            logging.warning("Browser TLS source request failed: %s", exc)
    for delay in (0, 2, 4):
        if delay:
            time.sleep(delay)
        try:
            response = requests.get(SOURCE_URL, timeout=15, headers={"Accept": "application/json"})
            response.raise_for_status()
            return response.json()
        except (requests.RequestException, ValueError) as exc:
            last_error = exc
            logging.warning("Source fetch retry after %s: %s", delay, exc)
    raise RuntimeError("Source API could not be fetched") from last_error


def prune_rate_files() -> None:
    rate_dir = STATE_DIR / "rate"
    if not rate_dir.is_dir():
        return
    cutoff = time.time() - 2 * 86400
    for path in rate_dir.glob("*.json"):
        if re.fullmatch(r"[0-9a-f]{64}\.json", path.name) and path.stat().st_mtime < cutoff:
            path.unlink(missing_ok=True)


def run() -> dict:
    source = fetch_source()
    facilities, categories = validate_source(source)
    cache = read_json(POI_CACHE, {})
    if not isinstance(cache, dict):
        cache = {}
    overrides = load_overrides()
    keys = {(row["name"], row["district"]) for row in facilities}
    missing = [(name, district) for name, district in keys if cache_expired(cache.get(json.dumps([name, district], ensure_ascii=False)))]
    if missing:
        with ThreadPoolExecutor(max_workers=6) as executor:
            futures = {executor.submit(query_poi, name, district): (name, district) for name, district in missing}
            for future in as_completed(futures):
                name, district = futures[future]
                try:
                    cache[json.dumps([name, district], ensure_ascii=False)] = {"checkedAt": utc_now(), "point": future.result()}
                except Exception as exc:
                    logging.warning("POI lookup failed for %r, %r: %s", name, district, exc)
        write_json_atomic(POI_CACHE, cache)

    output_rows = []
    conflict_count = 0
    for row in facilities:
        key = json.dumps([row["name"], row["district"]], ensure_ascii=False)
        poi = cached_point(cache.get(key))
        direct = google_target(row.get("link"))
        location = overrides.get(row["id"])
        if location is None:
            if poi and direct and point_distance_m(poi, direct) > 1500:
                conflict_count += 1
                location = None
            else:
                location = direct or poi
        output_rows.append({
            "id": row["id"],
            "name": row["name"],
            "district": row["district"],
            "category": row["category"],
            "status": row["status"],
            "capacity": row.get("capacity"),
            "occupied": row.get("occupied"),
            "available": row.get("available"),
            "unitType": row.get("unitType"),
            "routeDetails": row.get("routeDetails"),
            "additionalDetails": row.get("additionalDetails"),
            "sourceLink": row.get("link"),
            "updatedAt": row.get("updatedAt"),
            "location": location,
        })
    timestamps = [row.get("updatedAt") for row in facilities if isinstance(row.get("updatedAt"), str)]
    snapshot = {
        "source": SOURCE_URL,
        "sourceGeneratedAt": source.get("generatedAt"),
        "lastFetchedAt": utc_now(),
        "latestRecordUpdatedAt": max(timestamps, default=None),
        "upstreamStale": bool(source.get("stale")),
        "categories": categories,
        "total": len(output_rows),
        "mapped": sum(row["location"] is not None for row in output_rows),
        "unmapped": sum(row["location"] is None for row in output_rows),
        "coordinateConflicts": conflict_count,
        "facilities": output_rows,
    }
    write_json_atomic(OUTPUT, snapshot)
    try:
        prune_rate_files()
    except OSError as exc:
        logging.warning("Could not prune old AI rate files: %s", exc)
    return snapshot


if __name__ == "__main__":
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(filename=LOG, level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s", encoding="utf-8")
    try:
        result = run()
        logging.info("Synced %s facilities: %s mapped, %s unmapped, %s conflicts", result["total"], result["mapped"], result["unmapped"], result["coordinateConflicts"])
        print(f"Synced {result['total']} facilities: {result['mapped']} mapped, {result['unmapped']} unmapped")
    except Exception:
        logging.exception("Sync failed; existing snapshot retained")
        raise
