# BMA Flood Support Map

Public page: `https://now.bangkok.go.th/floodsupport.html`

## Public nearby flood map

Home page: `https://now.bangkok.go.th/index.html`. `src/index.html`, `src/index.js`, and `src/index.css` are its sources. Run `npm run build:home` and copy `src/index.html` to `C:\inetpub\wwwroot\now\index.html`. The page reuses the public `floodsupport-data.json` snapshot without changing the existing shelter page or its five-minute sync. It displays only verified shelter locations inside the selected straight-line radius (default 10 km).

`sync-nowcast.ps1` fetches `https://nowcast.bangkok.go.th/api/zonal` on the server and atomically updates `C:\inetpub\wwwroot\now\nowcast-data.json`. A failure retains the last valid payload and marks `fetchFailed`; the page additionally marks data old after 30 minutes. Install or restore the 15-minute SYSTEM task with `install-nowcast-task.ps1`. Its log is `C:\ProgramData\BMAFloodSupport\nowcast-sync.log`. The Python equivalent (`sync_nowcast.py`) and its failure tests are retained as a reference; this server has intermittent multi-minute Python startup under SYSTEM, so Task Scheduler invokes PowerShell.

`districts.geojson` is generated from the [BMA 50-district open-data shapefile](https://data.go.th/th/dataset/50), EPSG:32647, by `build_district_geojson.py`. To rebuild it, install `requirements-geo.txt` in the project venv, download the resource URL listed in that script, and pass the downloaded ZIP path to the script. The public `web.config` allows IIS to serve `.geojson`. District codes join the forecast JSON. The mobile map uses the same Google Maps browser key as the existing public page; the key must remain restricted to this HTTPS referrer and Maps JavaScript API.

Road flood sensors are fetched by the persistent `road_flood_daemon.py` process every five minutes. The `BMA Road Flood 5 Minute Sync` SYSTEM task (`install-road-flood-task.ps1`) launches it at boot without an execution time limit and restarts it on failure. This avoids the server's intermittent multi-minute SYSTEM process startup on each polling cycle. `sync-road-flood.ps1` remains a one-shot manual diagnostic. The `KeyId` header value lives only in `C:\ProgramData\BMANowMap\road-flood-key.txt`, with access restricted to SYSTEM and Administrators. The public `road-flood-data.json` is an atomic, reduced snapshot containing names, locations, device states, water levels, and observation times; it never includes the key or raw sensor profiles. If the API fails, the last valid snapshot remains and is marked as failed. The page treats malfunctioning or over-60-minute readings as unavailable, rather than showing their numeric readings as current conditions. The source is the [BMA road flood monitoring system](https://floodbangkok.bangkok.go.th/).

CCTV road flood reports are stored in `data/cctv-flood-data.json`. It contains all 28 locations transcribed from the SharePoint document “อัพเดทจุดที่มีน้ำท่วมขัง จาก CCTV 1732”. Long road sections use a representative coordinate and are labelled as CCTV data in the interface. Copy this file to `C:\inetpub\wwwroot\now\cctv-flood-data.json` when publishing. This snapshot stays separate from the five-minute sensor feed and retains its report time and source link.

Checks: `node --test test_home.mjs`, `python -m unittest test_sync_nowcast.py test_sync_road_flood.py test_sync_canal_water.py`, and `npm run build:home`. Verify the home page and JSON URLs return HTTP 200, inspect scheduled tasks and snapshot timestamps, and check the mobile radius filter.

Canal levels are fetched every five minutes from the BMA DDS `water/lastupdate` API by `canal_water_daemon.py`, using the same server-only KeyId file as the road sensors. The reduced public snapshot is `canal-water-data.json`; it excludes pump/gate payloads and the KeyId. Station coordinates come from the official DDS flood-plan station table in `data/canal-stations.json`. The page shows only coordinate-matched stations in the selected radius, hides malfunctioning stations, and marks readings older than 60 minutes unavailable. Install or restore the persistent SYSTEM task with `install-canal-water-task.ps1`.

## Components

- `merged_sync.py` refreshes the Flood Support API and Google Sheets independently. `daemon.py` keeps the imports loaded and invokes it every five minutes. It merges uniquely matched type/name/district records; API status and capacity win, while sheet contact/conditions and explicit valid sheet coordinates supplement them. The source caches and private needs snapshot are in `C:\ProgramData\BMAFloodSupport`. Failed sources keep their last valid snapshot and show a separate stale warning. Scheduled task: **BMA Flood Support Map Sync**, under SYSTEM.
- `sheet_parser.py` resolves headers by label because the workbook columns change. The public snapshot excludes the sheet's support requests. The staff dashboard requires a server-side session; its PIN hash is outside webroot. Staff can mark each district need type or shelter request complete and save a note. These updates are stored separately in `C:\ProgramData\BMAFloodSupport\staff-followup\status.json`, so the five-minute source sync does not overwrite them. A changed source quantity or shelter request no longer carries its previous completion mark.
- Each staff need quantity and the affected-family/person counts are labeled **Google Sheets**. The Flood Support API has no support-request quantity fields. For shelter requests with an unambiguous type/name/district match, the staff card separately shows its capacity, occupancy, remaining capacity, and status labeled **Flood Support** beside the sheet figures. Duplicate sheet rows for the same named site are collapsed only if populated numeric values agree; conflicting rows retain the last valid source snapshot instead of publishing an arbitrary choice.
- The task action calls `run-merged-sync.ps1`, which invokes `bootstrap.py` and records start/exit and delayed-start tracebacks outside webroot. The task starts at boot and runs continuously; `daemon.py` starts a refresh every five minutes. The task has no execution time limit and three restart attempts after failure.
- The scheduled job uses the project's Python 3.11 `.venv` with packages pinned in `requirements.txt`. Timed SYSTEM jobs intermittently spent several minutes importing modules, so the daemon avoids importing them each cycle.
- `src/main.js` and `src/style.css` compile with `npm run build` into the public JavaScript and CSS. The page loads Google Maps JavaScript API asynchronously through the locally bundled `@googlemaps/js-api-loader`, and uses `@googlemaps/markerclusterer` for the verified pins. The Google basemap and its controls come from Google; the BMA POI service is used only by the server-side coordinate verification workflow.
- `C:\inetpub\wwwroot\now\floodsupport-ai.php` interprets a Thai question as validated filters, then matches IDs in the current merged public snapshot. It uses the server-only gateway key in `C:\ProgramData\BMAFloodSupport\gateway-key.txt`.
- `review_candidates.py` writes an operator-only `C:\ProgramData\BMAFloodSupport\candidate-review.json`. Its AI suggestions are never made into public pins automatically.

## Coordinate policy

Public pins come from explicit valid coordinates in a matching sheet row, an explicit Google Maps place target, a unique exact BMA POI match, or a manually verified override. Sheet coordinates take precedence on matched places, as requested. Viewport `@lat,lon` values, short links, ambiguous name matches, and AI suggestions never become pins. Direct link and BMA POI points that disagree by over 1.5 km are withheld for review when there is no higher-priority verified point.

To add a reviewed coordinate, create or edit `C:\ProgramData\BMAFloodSupport\verified-locations.json` as an object keyed by source facility ID. Each entry must contain `lat`, `lon`, `verifiedBy`, `verifiedAt`, and `source`. Example:

```json
{
  "facility-id": {
    "lat": 13.75,
    "lon": 100.5,
    "verifiedBy": "BMA map operator",
    "verifiedAt": "2026-09-26T14:00:00Z",
    "source": "verified source URL or document reference"
  }
}
```

Run `python merged_sync.py` after review. The public JSON exposes the coordinate and method, but not the operator's identity or review metadata.

## Checks

Run `python -m unittest test_sync.py test_merged_sync.py`, compile the JavaScript/CSS, and lint both PHP endpoints. Check `C:\ProgramData\BMAFloodSupport\merged-sync.log`, each source timestamp in the public JSON, and the scheduled task result if a source becomes stale. The private staff JSON, staff PIN hash, gateway key, and review report remain outside webroot.

## Rollback

The pre-change API-only release is in `C:\ProgramData\BMAFloodSupport\backups\20260927-134303`. Its `public` files, `app` files, and task XML can be restored if the merged release must be withdrawn. Disable the scheduled task before restoring files and its action/trigger, then enable it after verification. The later `20260927-140012` folder preserves the interrupted partial release for investigation.

The release before staff follow-up editing is in `C:\ProgramData\BMAFloodSupport\backups\staff-followup-20260927-145626`. To roll back only this feature, restore its `now-*` public files and `src-*` source files. Keep `staff-followup\status.json` with the backup when preserving staff actions; the original release did not use it.

The Maps JavaScript API browser key is embedded in the public JavaScript bundle, as required by Google's web API. In Google Cloud Console, restrict that key to HTTPS referrers under `https://now.bangkok.go.th/*` and to **Maps JavaScript API**, and set a usage quota. This key is separate from the server-only AI gateway key. If the map fails to load, the public list, filters, AI search, and Google Maps directions links continue to work.
