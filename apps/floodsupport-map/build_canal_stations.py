"""Build the public canal station coordinate catalogue from the DDS plan PDF."""

from __future__ import annotations

import json
from pathlib import Path
import re

from pypdf import PdfReader


PDF = Path("tmp/pdfs/dds-water-stations.pdf")
OUTPUT = Path("data/canal-stations.json")
SOURCE_URL = "https://dds.bangkok.go.th/public_content/files/001/0008491_1.pdf"

# Nine rows have their district text on the same PDF line, which prevents the
# generic table-row extraction from recognizing the coordinate pair reliably.
MANUAL_ROWS = {
    "WL.KTY.01": (13.70635, 100.58779),
    "WL.STR.01": (13.71839, 100.51496),
    "WL.BTY.01": (13.80650, 100.64899),
    "WL.KDN.01": (13.67071, 100.54018),
    "WL.LBK.03": (13.74974, 100.70291),
    "WL.STR.02": (13.72592, 100.54402),
    "WL.SRE.01": (13.70671, 100.49647),
    "WL.JRN.01": (13.67634, 100.52111),
    "WL.PSC.04": (13.68142, 100.35040),
}


def build(pdf: Path = PDF, output: Path = OUTPUT) -> list[dict]:
    reader = PdfReader(pdf)
    stations: dict[str, dict] = {}
    for page_index in range(260, 267):
        for line in (reader.pages[page_index].extract_text() or "").splitlines():
            match = re.search(r"(WL\.[A-Z0-9.]+).*?(1[23]\.\d{4,})\s+(100\.\d{4,})", line)
            if match:
                stations[match.group(1)] = {
                    "code": match.group(1), "lat": float(match.group(2)),
                    "lng": float(match.group(3)), "sourcePage": page_index + 1,
                }
    for code, (lat, lng) in MANUAL_ROWS.items():
        stations[code] = {"code": code, "lat": lat, "lng": lng, "sourcePage": None}
    if len(stations) != 255:
        raise ValueError(f"Expected 255 station coordinates, found {len(stations)}")
    rows = sorted(stations.values(), key=lambda row: row["code"])
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({
        "source": SOURCE_URL, "coordinateCount": len(rows), "stations": rows,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return rows


if __name__ == "__main__":
    build()
