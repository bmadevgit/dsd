#!/usr/bin/env python3
"""Refresh both flood-support sources and publish one public map snapshot."""

from __future__ import annotations

from collections import Counter
from datetime import datetime, timezone
import json
import logging
from pathlib import Path
import requests

import sheet_sync
import sheet_parser
from sync import (OUTPUT, POI_CACHE, SOURCE_URL, STATE_DIR, cached_point,
                  google_target, load_overrides, point_distance_m, read_json, utc_now, validate_source, write_json_atomic)

API_CACHE = STATE_DIR / "api-source.json"
SHEET_CACHE = STATE_DIR / "sheet-source.json"
LOG = STATE_DIR / "merged-sync.log"


def freshness(fetched_at: str | None, failed: bool) -> dict:
    try:
        age = (datetime.now(timezone.utc) - datetime.fromisoformat(fetched_at.replace("Z", "+00:00"))).total_seconds()
    except (AttributeError, ValueError):
        age = float("inf")
    return {"fetchedAt": fetched_at, "fetchFailed": failed, "stale": age > 900}


def source_key(row: dict) -> tuple[str, str, str]:
    return (row["category"].strip(), " ".join(row["name"].strip().split()), row["district"].strip().removeprefix("เขต"))


def read_api() -> tuple[dict | None, bool]:
    try:
        logging.info("Fetching Flood Support API")
        response = requests.get(SOURCE_URL, timeout=(5, 12), headers={"Accept": "application/json"})
        response.raise_for_status()
        payload = response.json()
        validate_source(payload)
        result = {"lastFetchedAt": utc_now(), "payload": payload}
        write_json_atomic(API_CACHE, result)
        logging.info("Flood Support API fetched: %s facilities", len(payload["facilities"]))
        return result, False
    except Exception as exc:
        logging.warning("Flood Support API failed; using latest valid cache: %s", exc)
        cache = read_json(API_CACHE, None)
        return (cache if isinstance(cache, dict) and isinstance(cache.get("payload"), dict) else None), True


def read_sheets() -> tuple[dict | None, bool]:
    try:
        logging.info("Fetching Google Sheets workbook")
        workbook, raw = sheet_sync.download_workbook()
        try:
            public, staff, counts = sheet_parser.parse_workbook(workbook)
        finally:
            workbook.close()
        points = sheet_sync.coordinate_map(public["facilities"], counts)
        for row in public["facilities"]:
            if not row.get("location") and counts[(row["category"], row["name"], row["district"])] == 1:
                row["location"] = points.get((row["name"], row["district"]))
        result = {"lastFetchedAt": public["lastFetchedAt"], "places": public["facilities"], "staff": staff}
        write_json_atomic(SHEET_CACHE, result)
        sheet_sync.write_bytes_atomic(sheet_sync.RAW_OUTPUT, raw)
        logging.info("Google Sheets fetched: %s public places", len(public["facilities"]))
        return result, False
    except Exception as exc:
        logging.warning("Google Sheets failed; using latest valid cache: %s", exc)
        cache = read_json(SHEET_CACHE, None)
        return (cache if isinstance(cache, dict) and isinstance(cache.get("places"), list) else None), True


def api_places(payload: dict) -> list[dict]:
    facilities, _ = validate_source(payload)
    cache = read_json(POI_CACHE, {})
    if not isinstance(cache, dict):
        cache = {}
    overrides = load_overrides()
    output = []
    for row in facilities:
        key = json.dumps([row["name"], row["district"]], ensure_ascii=False)
        poi = cached_point(cache.get(key))
        direct = google_target(row.get("link"))
        point = overrides.get(row["id"]) or direct or poi
        if not overrides.get(row["id"]) and direct and poi and point_distance_m(direct, poi) > 1500:
            point = None
        output.append({"id": row["id"], "name": row["name"], "district": row["district"],
                       "category": row["category"], "status": row["status"], "capacity": row.get("capacity"),
                       "occupied": row.get("occupied"), "available": row.get("available"),
                       "unitType": row.get("unitType"), "routeDetails": row.get("routeDetails"),
                       "additionalDetails": row.get("additionalDetails"), "sourceLink": row.get("link"),
                       "updatedAt": row.get("updatedAt"), "location": point, "sources": ["Flood Support"]})
    return output


def merge(api: dict | None, sheets: dict | None, api_failed: bool, sheets_failed: bool) -> tuple[dict, dict | None]:
    if not api and not sheets:
        raise RuntimeError("Neither source has a valid snapshot")
    api_rows = api_places(api["payload"]) if api else []
    sheet_rows = sheets["places"] if sheets else []
    api_counts = Counter(source_key(row) for row in api_rows)
    sheet_counts = Counter(source_key(row) for row in sheet_rows)
    unique_sheets = {source_key(row): row for row in sheet_rows if sheet_counts[source_key(row)] == 1}
    merged, used = [], set()
    for row in api_rows:
        key = source_key(row)
        other = unique_sheets.get(key) if api_counts[key] == 1 else None
        if other:
            used.add(key)
            row = {**row, "sources": ["Flood Support", "Google Sheets"],
                   "phone": other.get("phone"), "conditions": other.get("conditions"),
                   "subdistrict": other.get("subdistrict")}
            if other.get("location"):
                row["location"] = other["location"]
        merged.append(row)
    for row in sheet_rows:
        if source_key(row) in used:
            continue
        merged.append({**row, "sources": ["Google Sheets"]})
    health = {"api": freshness(api.get("lastFetchedAt") if api else None, api_failed),
              "sheets": freshness(sheets.get("lastFetchedAt") if sheets else None, sheets_failed)}
    result = {"source": "Flood Support + Google Sheets", "sourceHealth": health,
              "lastFetchedAt": utc_now(), "sourceGeneratedAt": api["payload"].get("generatedAt") if api else None,
              "latestRecordUpdatedAt": max((row.get("updatedAt") for row in api_rows if isinstance(row.get("updatedAt"), str)), default=None),
              "upstreamStale": any(item["stale"] or item["fetchFailed"] for item in health.values()),
              "categories": list(dict.fromkeys([row["category"] for row in merged])),
              "total": len(merged), "mapped": sum(row.get("location") is not None for row in merged),
              "unmapped": sum(row.get("location") is None for row in merged), "facilities": merged}
    staff = None
    if sheets and isinstance(sheets.get("staff"), dict):
        staff = {**sheets["staff"], "sourceHealth": health}
        shelter_counts = Counter(source_key({"category": sheet_sync.SHELTER, "name": row.get("name", ""),
                                             "district": row.get("district", "")}) for row in staff.get("shelterNeeds", []))
        unique_api = {source_key(row): row for row in api_rows if api_counts[source_key(row)] == 1}
        shelter_needs = []
        for original in staff.get("shelterNeeds", []):
            row = {**original, "requestSource": "Google Sheets", "capacitySource": "Google Sheets"}
            key = source_key({"category": sheet_sync.SHELTER, "name": row.get("name", ""),
                              "district": row.get("district", "")})
            api_match = unique_api.get(key) if shelter_counts[key] == 1 else None
            if api_match:
                row["floodSupport"] = {field: api_match.get(field) for field in
                                       ("capacity", "occupied", "available", "status", "updatedAt")}
            shelter_needs.append(row)
        staff["shelterNeeds"] = shelter_needs
        staff["districtNeeds"] = [{**row, "source": "Google Sheets"} for row in staff.get("districtNeeds", [])]
    return result, staff


def run() -> dict:
    api, api_failed = read_api()
    sheets, sheets_failed = read_sheets()
    public, staff = merge(api, sheets, api_failed, sheets_failed)
    if staff:
        write_json_atomic(sheet_sync.STAFF_OUTPUT, staff)
    write_json_atomic(OUTPUT, public)
    return public


if __name__ == "__main__":
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(filename=LOG, level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s", encoding="utf-8")
    try:
        result = run()
        logging.info("Merged %s places, %s mapped; API %s, Sheets %s", result["total"], result["mapped"],
                     result["sourceHealth"]["api"], result["sourceHealth"]["sheets"])
        print(f"Merged {result['total']} places; {result['mapped']} mapped")
    except Exception:
        logging.exception("Merged sync failed; public snapshot retained")
        raise
