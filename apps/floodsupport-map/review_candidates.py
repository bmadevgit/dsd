#!/usr/bin/env python3
"""Create an operator-only AI review report for locations without verified pins.

This script never edits the public snapshot or verified-locations.json.
"""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
import json
from pathlib import Path
import re

import requests

from sync import POI_URL, STATE_DIR, OUTPUT, valid_point, write_json_atomic

REPORT = STATE_DIR / "candidate-review.json"
KEY = STATE_DIR / "gateway-key.txt"
GATEWAY = "http://100.99.107.27:8000/v1/chat/completions"
MODEL = "Qwen/Qwen3.8-27B-FP8"


def search_term(name: str) -> str:
    clean = re.sub(r"\([^)]*\)|（[^）]*）", "", name).strip()
    for prefix in ("โรงเรียน", "สำนักงานเขต", "ศูนย์บริการ", "ศูนย์นันทนาการ", "อาคารจอดแล้วจร", "รพ."):
        if clean.startswith(prefix) and len(clean) - len(prefix) >= 5:
            clean = clean[len(prefix):].strip()
            break
    return clean[:70]


def candidates(row: dict) -> dict:
    term = search_term(row["name"])
    quote = lambda value: value.replace("'", "''")
    result = {"id": row["id"], "name": row["name"], "district": row["district"], "category": row["category"], "term": term, "candidates": [], "aiSuggestion": None}
    if len(term) < 4:
        return result
    try:
        response = requests.get(POI_URL, params={
            "where": f"NAME LIKE '%{quote(term)}%' AND DISTRICT='{quote(row['district'])}'",
            "outFields": "OBJECTID,NAME,DISTRICT,SUB_DISTRICT,STREET",
            "returnGeometry": "true", "outSR": "4326", "resultRecordCount": 12, "f": "json",
        }, timeout=20)
        response.raise_for_status()
        body = response.json()
        for feature in body.get("features", []):
            attrs, geometry = feature.get("attributes") or {}, feature.get("geometry") or {}
            if attrs.get("DISTRICT") != row["district"] or not valid_point(geometry.get("y"), geometry.get("x")):
                continue
            result["candidates"].append({"objectId": attrs.get("OBJECTID"), "name": attrs.get("NAME"), "subDistrict": attrs.get("SUB_DISTRICT"), "street": attrs.get("STREET"), "lat": geometry["y"], "lon": geometry["x"]})
    except Exception as exc:
        result["lookupError"] = type(exc).__name__
    return result


def ask_ai(batch: list[dict], api_key: str) -> None:
    input_rows = [{"sourceId": row["id"], "name": row["name"], "district": row["district"], "candidates": [{"objectId": c["objectId"], "name": c["name"], "subDistrict": c["subDistrict"], "street": c["street"]} for c in row["candidates"]]} for row in batch]
    prompt = "For each sourceId, suggest one candidateObjectId only if the name and district clearly match the same real place; otherwise null. This is for human review only. Never invent IDs. Return ONLY JSON array of {sourceId,candidateObjectId,reason}."
    try:
        response = requests.post(GATEWAY, headers={"Authorization": "Bearer " + api_key}, json={
            "model": MODEL, "temperature": 0, "max_tokens": 800,
            "chat_template_kwargs": {"enable_thinking": False},
            "messages": [{"role": "system", "content": prompt}, {"role": "user", "content": json.dumps(input_rows, ensure_ascii=False)}],
        }, timeout=25)
        response.raise_for_status()
        content = response.json()["choices"][0]["message"]["content"]
        start, end = content.find("["), content.rfind("]")
        suggestions = json.loads(content[start:end + 1]) if start >= 0 and end >= start else []
        by_id = {item.get("sourceId"): item for item in suggestions if isinstance(item, dict)}
        for row in batch:
            choice = by_id.get(row["id"], {})
            allowed = {c["objectId"] for c in row["candidates"]}
            candidate_id = choice.get("candidateObjectId")
            if candidate_id in allowed:
                row["aiSuggestion"] = {"candidateObjectId": candidate_id, "reason": str(choice.get("reason", ""))[:250]}
    except Exception as exc:
        for row in batch:
            row["aiError"] = type(exc).__name__


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=100, help="maximum unmatched records to inspect")
    args = parser.parse_args()
    snapshot = json.loads(OUTPUT.read_text(encoding="utf-8"))
    unmatched = [row for row in snapshot["facilities"] if row["location"] is None][:max(0, args.limit)]
    with ThreadPoolExecutor(max_workers=5) as executor:
        rows = list(executor.map(candidates, unmatched))
    key = KEY.read_text(encoding="ascii").strip()
    with_candidates = [row for row in rows if row["candidates"]]
    for index in range(0, len(with_candidates), 5):
        ask_ai(with_candidates[index:index + 5], key)
    report = {
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "note": "Suggestions require manual verification; this report is never published as map pins.",
        "sourceSnapshotAt": snapshot["lastFetchedAt"],
        "reviewed": len(rows),
        "withCandidates": len(with_candidates),
        "aiSuggestions": sum(row["aiSuggestion"] is not None for row in rows),
        "items": rows,
    }
    write_json_atomic(REPORT, report)
    print(f"Reviewed {len(rows)} unmatched records; {len(with_candidates)} have POI candidates; {report['aiSuggestions']} AI suggestions")


if __name__ == "__main__":
    main()
