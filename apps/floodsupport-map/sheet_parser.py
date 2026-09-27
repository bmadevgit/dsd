"""Parse the changing Google workbook by header labels, not column positions."""

from __future__ import annotations

from collections import Counter
import math

from sheet_sync import SHEET_URL, SHELTER, PARKING, district_name, number, stable_id, text, utc_now, valid_point


def tab(book, prefix):
    matches = [s for s in book.worksheets if s.title.startswith(prefix)]
    if len(matches) != 1:
        raise ValueError(f"Worksheet {prefix!r} is missing or ambiguous")
    return matches[0]


def col(sheet, header_row, label, *, required=True):
    cells = next(sheet.iter_rows(min_row=header_row, max_row=header_row, values_only=True), ())
    matches = [i for i, cell in enumerate(cells) if label in text(cell).replace("\n", " ")]
    if len(matches) == 1 or (label == "เขต" and matches):
        return matches[0]
    if required:
        raise ValueError(f"Expected header {label!r} once in {sheet.title} row {header_row}")
    return None


def at(row, index):
    return row[index] if index is not None and index < len(row) else None


def need_col(sheet, label):
    headers = next(sheet.iter_rows(min_row=4, max_row=4, values_only=True))
    matches = [(i, text(cell).replace("\n", " ")) for i, cell in enumerate(headers) if label in text(cell)]
    requested = [i for i, heading in matches if "ขอเพิ่มเติม" in heading or "ขาด" in heading]
    if len(requested) == 1:
        return requested[0]
    if len(matches) == 1:
        return matches[0][0]
    # Some categories have a merged heading in row 1 with several detailed
    # columns in row 4. Water was changed from one column to this layout.
    groups = next(sheet.iter_rows(min_row=1, max_row=1, values_only=True))
    starts = [i for i, cell in enumerate(groups) if label in text(cell)]
    if len(starts) == 1:
        start = starts[0]
        end = next((i for i in range(start + 1, len(groups)) if text(groups[i])), len(headers))
        remaining = [i for i in range(start, end) if "คงเหลือ" in text(headers[i]) and "สนับสนุนเพิ่มเติม" in text(headers[i])]
        if len(remaining) == 1:
            return remaining[0]
    raise ValueError(f"Cannot identify requested {label!r} column in {sheet.title}")


def coordinates(row, lat_col, lon_col):
    try:
        lat, lon = float(at(row, lat_col)), float(at(row, lon_col))
    except (TypeError, ValueError):
        return None
    if not valid_point(lat, lon):
        return None
    return {"lat": lat, "lon": lon, "method": "google-sheet-coordinate"}


def deduplicate_places(places):
    """Collapse identical site keys only when their populated values agree."""
    by_id = {}
    for place in places:
        previous = by_id.get(place["id"])
        if previous is None:
            by_id[place["id"]] = place
            continue
        for field in ("capacity", "occupied", "available"):
            if previous[field] is not None and place[field] is not None and previous[field] != place[field]:
                raise ValueError(f"Conflicting duplicate place {place['id']} {field}")
        if previous["location"] and place["location"] and previous["location"] != place["location"]:
            raise ValueError(f"Conflicting duplicate place {place['id']} location")
        score = lambda row: sum(row[field] is not None for field in ("capacity", "occupied", "available", "location"))
        chosen = place if score(place) > score(previous) else previous
        chosen["duplicateSourceRows"] = previous.get("duplicateSourceRows", 1) + 1
        by_id[place["id"]] = chosen
    return list(by_id.values())


def parse_workbook(book):
    district_sheet = tab(book, "รายชื่อเขต")
    dcol = col(district_sheet, 1, "รายชื่อเขต")
    districts = {text(at(row, dcol)) for row in district_sheet.iter_rows(min_row=2, values_only=True) if text(at(row, dcol))}
    if len(districts) < 45:
        raise ValueError(f"Only {len(districts)} districts found")

    shelter_sheet = tab(book, "รายละเอียดศูนย์พักพิง")
    sh = {key: col(shelter_sheet, 5, label, required=required) for key, label, required in [
        ("district", "สำนักงานเขต", True), ("subdistrict", "แขวง", True),
        ("status", "ศูนย์พักพิงผู้ประสบภัย", True), ("name", "ชื่อสถานที่ตั้งศูนย์พักพิง", True),
        ("phone", "เบอร์โทรติดต่อศูนย์พักพิง", False), ("capacity", "จำนวนที่สามารถ", True),
        ("occupied", "จำนวนผู้ประสบภัย", True), ("conditions", "เงื่อนไข", False),
        ("request", "ความต้องการของศูนย์พักพิง", False), ("lat", "ละติจูด", False),
        ("lon", "ลองจิจูด", False),
    ]}
    parking_sheet = tab(book, "รายละเอียดสถานที่จอดรถ")
    ph = {key: col(parking_sheet, 1, label, required=required) for key, label, required in [
        ("district", "เขต", True), ("name", "ชื่ออาคาร/สถานที่จอดรถ", True),
        ("phone", "เบอร์โทรติดต่อ", False), ("capacity", "จำนวนรถที่ รองรับได้", False),
        ("occupied", "จำนวนรถที่ เข้าจอดแล้ว", False), ("conditions", "ในการเข้าจอด", False),
        ("lat", "ละติจูด", False), ("lon", "ลองจิจูด", False),
    ]}
    # The parking headers contain line breaks and changing spaces. Resolve the
    # two numeric fields by stable wording if the exact labels above changed.
    if ph["capacity"] is None:
        ph["capacity"] = col(parking_sheet, 1, "รองรับได้")
    if ph["occupied"] is None:
        ph["occupied"] = col(parking_sheet, 1, "เข้าจอดแล้ว")
    needs_sheet = tab(book, "รายละเอียดผลกระทบและความต้องการ")
    nh = {"district": col(needs_sheet, 4, "เขต"), "note": col(needs_sheet, 4, "หมายเหตุ", required=False)}
    for key, label in (("reliefBags", "ถุงยังชีพ"), ("water", "น้ำดื่ม"), ("cookedMeals", "อาหารปรุงสุก"),
                       ("gmc", "รถ GMC"), ("highClearance", "รถยกสูง"), ("buses", "รถเมล์"),
                       ("bedridden", "ผู้ป่วยติดเตียง"), ("fiberglassBoats", "เรือไฟเบอร์"),
                       ("flatBoats", "เรือท้องแบน")):
        nh[key] = need_col(needs_sheet, label)
    nh["families"] = col(needs_sheet, 5, "จำนวนครอบครัว")
    nh["people"] = col(needs_sheet, 5, "จำนวนผู้ประสบภัย")
    declaration_sheet = tab(book, "ข้อมูลการประกาศ")
    dh = {key: col(declaration_sheet, 1, label) for key, label in [
        ("district", "เขต"), ("subdistrict", "แขวง"), ("submission", "สถานะการส่งข้อมูล"),
        ("declaration", "สถานะการประกาศ"),
    ]}

    places, shelter_needs, closed_shelters, district_needs, declarations = [], [], [], [], []
    names = Counter()
    district = ""
    for row in shelter_sheet.iter_rows(min_row=6, values_only=True):
        district = district_name(at(row, sh["district"]), districts) or district
        name, status = text(at(row, sh["name"])), text(at(row, sh["status"]))
        if not district or not name or status not in ("เปิดศูนย์พักพิง", "ยังไม่มีการเปิดศูนย์ฯ"):
            continue
        subdistrict = text(at(row, sh["subdistrict"])).removeprefix("แขวง").strip()
        capacity, occupied = number(at(row, sh["capacity"])), number(at(row, sh["occupied"]))
        available = max(capacity - occupied, 0) if capacity is not None and occupied is not None else None
        request = text(at(row, sh["request"]))
        if request and request not in ("-", "ไม่มี", "ไม่มีความต้องการ"):
            shelter_needs.append({"id": stable_id("need", district, subdistrict, name), "district": district,
                                  "subdistrict": subdistrict, "name": name, "status": status,
                                  "request": request, "capacity": capacity, "occupied": occupied, "available": available})
        names[(SHELTER, name, district)] += 1
        if status != "เปิดศูนย์พักพิง":
            closed_shelters.append({"district": district, "subdistrict": subdistrict, "name": name,
                                    "status": status, "capacity": capacity})
        if status == "เปิดศูนย์พักพิง":
            places.append({"id": stable_id(SHELTER, district, subdistrict, name), "name": name,
                           "district": district, "subdistrict": subdistrict, "category": SHELTER,
                           "status": "เต็ม" if available == 0 else "เปิดให้บริการ", "capacity": capacity,
                           "occupied": occupied, "available": available, "unitType": "คน",
                           "phone": text(at(row, sh["phone"])), "conditions": text(at(row, sh["conditions"])),
                           "sourceLink": SHEET_URL, "location": coordinates(row, sh["lat"], sh["lon"])})

    district = ""
    for row in parking_sheet.iter_rows(min_row=2, values_only=True):
        district = district_name(at(row, ph["district"]), districts) or district
        name = text(at(row, ph["name"]))
        if not district or not name or name.startswith(("รวม", "จำนวน")):
            continue
        capacity, occupied = number(at(row, ph["capacity"])), number(at(row, ph["occupied"]))
        available = max(capacity - occupied, 0) if capacity is not None and occupied is not None else None
        names[(PARKING, name, district)] += 1
        places.append({"id": stable_id(PARKING, district, "", name), "name": name, "district": district,
                       "subdistrict": "", "category": PARKING, "status": "เต็ม" if available == 0 else "เปิดให้บริการ",
                       "capacity": capacity, "occupied": occupied, "available": available, "unitType": "คัน",
                       "phone": text(at(row, ph["phone"])), "conditions": text(at(row, ph["conditions"])),
                       "sourceLink": SHEET_URL, "location": coordinates(row, ph["lat"], ph["lon"])})

    for row in needs_sheet.iter_rows(min_row=6, values_only=True):
        district = district_name(at(row, nh["district"]), districts)
        if not district:
            continue
        needs = {key: number(at(row, nh[key])) for key in ("reliefBags", "water", "cookedMeals", "gmc",
                                                       "highClearance", "buses", "bedridden", "fiberglassBoats", "flatBoats")}
        district_needs.append({"district": district, "affectedFamilies": number(at(row, nh["families"])),
                               "affectedPeople": number(at(row, nh["people"])), "needs": needs,
                               "note": text(at(row, nh["note"])),
                               "hasNeed": any(v is not None and v > 0 for v in needs.values())})

    district = ""
    for row in declaration_sheet.iter_rows(min_row=2, values_only=True):
        district = district_name(at(row, dh["district"]), districts) or district
        subdistrict = text(at(row, dh["subdistrict"])).removeprefix("แขวง").strip()
        if district and subdistrict:
            declarations.append({"district": district, "subdistrict": subdistrict,
                                 "submissionStatus": text(at(row, dh["submission"])),
                                 "declarationStatus": text(at(row, dh["declaration"]))})

    # An optional auxiliary coordinate sheet may come and go or be renamed.
    # Accept points only when its row identifies the exact shelter.
    for extra in book.worksheets:
        if extra in (shelter_sheet, parking_sheet):
            continue
        for header_row in range(1, 4):
            lat = col(extra, header_row, "ละติจูด", required=False)
            lon = col(extra, header_row, "ลองจิจูด", required=False)
            name_col = col(extra, header_row, "ชื่อสถานที่ตั้งศูนย์พักพิง", required=False)
            district_col = col(extra, header_row, "สำนักงานเขต", required=False)
            sub_col = col(extra, header_row, "แขวง", required=False)
            if None in (lat, lon, name_col, district_col):
                continue
            candidates = {}
            for row in extra.iter_rows(min_row=header_row + 1, values_only=True):
                point = coordinates(row, lat, lon)
                if point:
                    key = (text(at(row, district_col)).removeprefix("เขต").strip(),
                           text(at(row, sub_col)).removeprefix("แขวง").strip(), text(at(row, name_col)))
                    candidates.setdefault(key, []).append(point)
            for place in places:
                if place["category"] == SHELTER and not place["location"]:
                    match = candidates.get((place["district"], place["subdistrict"], place["name"]))
                    if match and len(match) == 1:
                        place["location"] = match[0]
            break

    # Editors sometimes repeat the same named site in the same subdistrict,
    # leaving one row without the numeric fields. Keep the richer row only
    # when every populated numeric value agrees; conflicting rows fail safely.
    places = deduplicate_places(places)
    if len(places) < 30 or len(district_needs) < 40 or len(declarations) < 100:
        raise ValueError("Workbook has too few place, need, or declaration rows")
    density = sorted(({"district": p["district"], "name": p["name"], "capacity": p["capacity"],
                       "occupied": p["occupied"], "ratio": round(p["occupied"] / p["capacity"], 3)}
                      for p in places if p["category"] == SHELTER and p["capacity"] and p["occupied"] is not None
                      and p["occupied"] / p["capacity"] >= .8), key=lambda p: -p["ratio"])
    groups = {}
    try:
        group_sheet = tab(book, "กลุ่มเขต")
        group_d, group_g = col(group_sheet, 1, "DISTRICT"), col(group_sheet, 1, "GROUPDISTRICT")
        groups = {text(at(row, group_d)): text(at(row, group_g)) for row in group_sheet.iter_rows(min_row=2, values_only=True)}
    except ValueError:
        pass
    staff = {"source": SHEET_URL, "lastFetchedAt": utc_now(), "districts": sorted(districts),
             "districtGroups": groups, "districtNeeds": district_needs, "shelterNeeds": shelter_needs,
             "closedShelters": closed_shelters,
             "declarations": declarations, "density": density}
    return {"lastFetchedAt": staff["lastFetchedAt"], "facilities": places}, staff, names
