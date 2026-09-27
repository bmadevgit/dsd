import './index.css';
import { setOptions, importLibrary } from '@googlemaps/js-api-loader';
import { GOOGLE_MAPS_KEY } from './maps-config.js';
import { circleIntersectsFeature, distanceKm, pointInFeature } from './geo.mjs';
import { isRoadSensorVisible, ROAD_COLORS, roadState } from './road.mjs';
import { CANAL_COLORS, canalState, isCanalStationVisible } from './canal.mjs';

const $ = (id) => document.getElementById(id);
const ROUTES = new Set(['home', 'map', 'help', 'shelters']);
const state = {
  route: 'home', point: null, radius: 3, filter: 'all', boundaries: null, rain: null,
  shelters: null, road: null, cctv: null, canal: null, map: null, pin: null, circle: null,
  markers: [], geocoder: null, autocompletes: []
};

const thaiTime = (value) => value ? new Intl.DateTimeFormat('th-TH', { dateStyle: 'short', timeStyle: 'short', timeZone: 'Asia/Bangkok' }).format(new Date(value)) : 'ไม่ทราบเวลา';
const node = (tag, className, text) => { const el = document.createElement(tag); if (className) el.className = className; if (text !== undefined) el.textContent = text; return el; };
const clear = (id) => { const el = $(id); el.replaceChildren(); return el; };

function selectedDistrict() {
  return state.point && state.boundaries?.features.find((feature) => pointInFeature(state.point, feature));
}

function districtName(feature) {
  return state.rain?.payload?.districts?.[feature?.properties?.districtCode]?.district_t || feature?.properties?.nameThai || feature?.properties?.nameEnglish || '';
}

function setMessage(text) {
  $('locationState').textContent = text;
  $('locationState').hidden = !text;
}

function roadRows() {
  if (!state.point) return [];
  const sensors = (state.road?.sensors || [])
    .filter((row) => isRoadSensorVisible(row) && roadState(row) !== 'unavailable')
    .map((row) => ({ ...row, kind: 'road', lng: row.lon, km: distanceKm(state.point, { lat: row.lat, lng: row.lon }), viewState: roadState(row) }));
  const cctv = (state.cctv?.locations || []).map((row) => ({ ...row, kind: 'cctv', km: distanceKm(state.point, row), viewState: row.severity === 'high' ? 'flooding' : row.severity === 'minor' ? 'minor_flood' : 'reported' }));
  const priority = { flooding: 0, minor_flood: 1, reported: 2, normal: 3 };
  return [...sensors, ...cctv].filter((row) => row.km <= state.radius).sort((a, b) => priority[a.viewState] - priority[b.viewState] || a.km - b.km);
}

function canalRows() {
  if (!state.point) return [];
  const priority = { critical: 0, warning: 1, normal: 2, unavailable: 3 };
  return (state.canal?.stations || []).filter((row) => isCanalStationVisible(row) && Number.isFinite(row.lat) && Number.isFinite(row.lng))
    .map((row) => ({ ...row, kind: 'canal', km: distanceKm(state.point, row), viewState: canalState(row) }))
    .filter((row) => row.km <= state.radius).sort((a, b) => priority[a.viewState] - priority[b.viewState] || a.km - b.km);
}

function shelterRows() {
  if (!state.point) return [];
  return (state.shelters?.facilities || []).filter((row) => row.location && Number.isFinite(row.location.lat) && Number.isFinite(row.location.lon))
    .map((row) => ({ ...row, kind: 'shelter', lat: row.location.lat, lng: row.location.lon, km: distanceKm(state.point, { lat: row.location.lat, lng: row.location.lon }) }))
    .filter((row) => row.km <= state.radius).sort((a, b) => a.km - b.km);
}

function selectedRain() {
  const feature = selectedDistrict();
  return feature ? state.rain?.payload?.districts?.[feature.properties.districtCode] : null;
}

function statusLabel(value) {
  return ({ flooding: 'น้ำท่วม', minor_flood: 'เฝ้าระวัง', reported: 'มีรายงาน CCTV', normal: 'ปกติ', critical: 'วิกฤต', warning: 'เตือนภัย', unavailable: 'ข้อมูลเก่า' })[value] || value;
}

function renderHome() {
  const district = selectedDistrict();
  const selectedLabel = state.point ? (district ? `พิกัดในเขต${districtName(district)}` : 'พิกัดที่เลือก') : 'ยังไม่ได้เลือกพิกัด';
  $('selectedName').textContent = selectedLabel;
  $('mapSelectedName').textContent = state.point ? `${selectedLabel} · รัศมี ${state.radius} กม.` : selectedLabel;
  $('selectedCoords').textContent = state.point ? `${state.point.lat.toFixed(5)}, ${state.point.lng.toFixed(5)} · รัศมี ${state.radius} กม.` : 'แตะแผนที่หรือใช้ตำแหน่งปัจจุบัน';
  renderRoadSummary(); renderRainSummary(); renderCanalSummary(); renderNearbyRoads(); renderNearestShelter();
}

function renderRoadSummary() {
  for (const id of ['roadSummary', 'mapRoadSummary']) {
    const root = clear(id);
    if (!state.point) { root.append(node('p', 'loading', 'เลือกพิกัดเพื่อดูข้อมูลใกล้คุณ')); continue; }
    const rows = roadRows();
    const heavy = rows.filter((row) => row.viewState === 'flooding').length;
    const watch = rows.filter((row) => ['minor_flood', 'reported'].includes(row.viewState)).length;
    for (const [count, label, style] of [[heavy, 'หนัก', 'danger'], [watch, 'ปานกลาง', 'warning']]) {
      const metric = node('div', `metric ${style}`); metric.append(node('strong', '', `${count} เส้น`), node('span', '', label)); root.append(metric);
    }
    if (!rows.length) root.append(node('p', 'loading', `ไม่พบข้อมูลน้ำท่วมถนนในรัศมี ${state.radius} กม.`));
  }
  const canalRoot = clear('mapCanalSummary');
  if (!state.point) { canalRoot.append(node('p', 'loading', 'เลือกพิกัดเพื่อดูข้อมูลใกล้คุณ')); return; }
  const canals = canalRows();
  const critical = canals.filter((row) => row.viewState === 'critical').length;
  const warning = canals.filter((row) => row.viewState === 'warning').length;
  for (const [count, label, style] of [[critical, 'หนัก', 'danger'], [warning, 'ปานกลาง', 'warning']]) {
    const metric = node('div', `metric ${style}`); metric.append(node('strong', '', `${count} คลอง`), node('span', '', label)); canalRoot.append(metric);
  }
}

function renderRainSummary() {
  const current = clear('rainNow'); const forecast = clear('rainForecast'); const rain = selectedRain();
  if (!state.point) { current.append(node('p', 'loading', 'เลือกพิกัดเพื่อดูฝนในเขต')); forecast.append(node('p', 'loading', 'เลือกพิกัดเพื่อดูพยากรณ์')); return; }
  if (!rain) { current.append(node('p', 'loading', 'ข้อมูลฝนไม่พร้อมใช้งาน')); forecast.append(node('p', 'loading', 'ข้อมูลพยากรณ์ไม่พร้อมใช้งาน')); return; }
  const currentText = rain.peak_mmhr > 0 ? `มีฝนในเขต${rain.district_t} สูงสุด ${rain.peak_mmhr.toFixed(1)} มม./ชม.` : `ยังไม่พบฝนในเขต${rain.district_t}`;
  current.append(node('p', '', currentText), node('p', 'muted', `โอกาสฝน ${Math.round(rain.prob_rain_pct || 0)}% · รอบ ${state.rain?.payload?.base_time || '-'}`));
  const onset = Number.isFinite(rain.onset_min) ? `คาดว่าฝนเริ่มใน ${rain.onset_min} นาที` : 'ยังไม่คาดว่าฝนจะเริ่มในช่วงพยากรณ์';
  forecast.append(node('p', '', onset), node('p', 'muted', 'พยากรณ์ระดับเขต ไม่ใช่ค่าที่พิกัดโดยตรง'));
}

function renderCanalSummary() {
  const root = clear('canalSummary');
  if (!state.point) { root.append(node('p', 'loading', 'เลือกพิกัดเพื่อดูสถานีใกล้คุณ')); return; }
  const rows = canalRows();
  if (!rows.length) { root.append(node('p', 'loading', `ไม่พบสถานีในรัศมี ${state.radius} กม.`)); return; }
  const counts = { critical: 0, warning: 0, normal: 0, unavailable: 0 }; rows.forEach((row) => counts[row.viewState]++);
  root.append(node('p', '', `วิกฤต ${counts.critical} · เตือนภัย ${counts.warning} · ปกติ ${counts.normal}`), node('p', 'muted', `พบ ${rows.length} สถานี · อัปเดต ${thaiTime(state.canal?.lastFetchedAt)}`));
  rows.slice(0, 2).forEach((row) => root.append(makeCanalCard(row)));
}

function makeRoadCard(row) {
  const card = node('article', 'item'); const title = row.kind === 'cctv' ? `${row.road} · ${row.section}` : (row.name || row.road || row.code);
  card.append(node('h3', '', title), node('span', `badge ${row.viewState === 'flooding' ? 'danger' : row.viewState === 'minor_flood' ? 'warning' : ''}`, statusLabel(row.viewState)));
  card.append(node('p', '', `${row.km.toFixed(1)} กม. · ${row.kind === 'cctv' ? 'รายงาน CCTV' : `เซ็นเซอร์ ${row.valueCm.toFixed(1)} ซม.`}`));
  card.append(node('p', 'muted', row.kind === 'cctv' ? `รายงาน ${thaiTime(state.cctv?.source?.reportedAt)}` : `อ่านค่าล่าสุด ${thaiTime(row.observedAt)}`)); return card;
}

function makeCanalCard(row) {
  const canalName = row.river?.trim() || 'ไม่ระบุชื่อคลอง';
  const card = node('article', 'item'); card.append(node('h3', '', `คลอง: ${canalName}`), node('span', `badge ${row.viewState}`, statusLabel(row.viewState)));
  card.append(node('p', '', `${row.km.toFixed(1)} กม. · ${Number.isFinite(row.levelM) ? `ระดับน้ำ ${row.levelM.toFixed(2)} ม.` : 'ไม่มีค่าระดับน้ำ'}`), node('p', 'muted', `อ่านค่าล่าสุด ${thaiTime(row.observedAt)}`)); return card;
}

function makeShelterCard(row) {
  const card = node('article', 'item'); card.append(node('h3', '', row.name), node('span', 'badge', row.status || 'ตรวจสอบสถานะ'));
  card.append(node('p', '', `เขต${row.district} · ${row.km.toFixed(1)} กม.`));
  if (Number.isFinite(row.available)) card.append(node('p', '', `ว่าง ${row.available} ${row.unitType || 'คน'} จาก ${row.capacity ?? '-'} ${row.unitType || 'คน'}`));
  if (row.phone) card.append(node('p', '', `โทร ${row.phone}`));
  const link = node('a', 'text-button', 'ดูข้อมูลติดต่อและเส้นทาง →'); link.href = `https://www.google.com/maps/dir/?api=1&destination=${row.lat},${row.lng}`; link.target = '_blank'; link.rel = 'noopener'; card.append(link); return card;
}

function renderNearbyRoads() {
  const root = clear('nearRoads'); if (!state.point) { root.append(node('p', 'loading', 'เลือกพิกัดเพื่อดูรายการ')); return; }
  const rows = roadRows().filter((row) => row.viewState !== 'normal');
  if (!rows.length) { root.append(node('p', 'loading', `ไม่พบรายงานน้ำท่วมในรัศมี ${state.radius} กม.`)); return; }
  rows.slice(0, 4).forEach((row) => root.append(makeRoadCard(row)));
  if (rows.length > 4) { const button = node('button', 'text-button', `ดูอีก ${rows.length - 4} จุดบนแผนที่ →`); button.dataset.route = 'map'; root.append(button); }
}

function renderNearestShelter() {
  const rows = shelterRows(); $('nearestShelterText').textContent = rows[0] ? `${rows[0].name} · ${rows[0].km.toFixed(1)} กม. · ${rows[0].status || 'ตรวจสอบสถานะก่อนเดินทาง'}` : (state.point ? `ไม่พบศูนย์พักพิงในรัศมี ${state.radius} กม.` : 'เลือกพิกัดเพื่อค้นหาศูนย์พักพิงที่ใกล้ที่สุด');
}

function renderMapResults() {
  const root = clear('mapResults'); $('mapUpdated').textContent = state.point ? `รัศมี ${state.radius} กม.` : '';
  if (!state.point) { root.append(node('p', 'loading', 'ค้นหาพื้นที่หรือแตะแผนที่เพื่อเลือกพิกัด')); renderMarkers(); return; }
  const rows = roadRows().filter((row) => row.viewState !== 'normal');
  if (!rows.length) root.append(node('p', 'loading', `ไม่พบถนนน้ำท่วมในรัศมี ${state.radius} กม.`));
  for (const [kind, title, updated] of [['road', '⚙ จาก Sensor ระบบตรวจวัดน้ำท่วมถนน', state.road?.lastFetchedAt], ['cctv', '▣ จาก CCTV', state.cctv?.source?.reportedAt]]) {
    const sourceRows = rows.filter((row) => row.kind === kind);
    if (!sourceRows.length) continue;
    const group = node('section', 'source-group'); group.append(node('h3', '', title), node('p', 'muted', `ข้อมูลล่าสุด ${thaiTime(updated)}`));
    sourceRows.slice(0, 10).forEach((row) => group.append(makeRoadCard(row))); root.append(group);
  }
  if (rows.length > 20) root.append(node('p', 'muted', `แสดง 20 จาก ${rows.length} รายการ ดูจุดทั้งหมดได้บนแผนที่`)); renderMarkers();
}

function renderShelters() {
  const root = clear('shelterResults'); $('shelterTime').textContent = state.shelters ? `อัปเดต ${thaiTime(state.shelters.lastFetchedAt)}` : 'ข้อมูลไม่พร้อม';
  if (!state.point) { root.append(node('p', 'loading', 'แตะแผนที่หรือใช้ตำแหน่งปัจจุบัน')); return; }
  const rows = shelterRows(); if (!rows.length) { root.append(node('p', 'loading', `ไม่พบศูนย์พักพิงในรัศมี ${state.radius} กม.`)); return; }
  rows.slice(0, 8).forEach((row) => root.append(makeShelterCard(row)));
  if (rows.length > 8) {
    const more = node('details', 'more-list');
    more.append(node('summary', '', `ดูศูนย์พักพิงอีก ${rows.length - 8} แห่ง`));
    rows.slice(8).forEach((row) => more.append(makeShelterCard(row)));
    root.append(more);
  }
}

function clearMarkers() {
  state.markers.forEach((marker) => marker.setMap(null)); state.markers = [];
}

function pinIcon(kind, color) {
  const glyph = kind === 'canal'
    ? '<path d="M4.5 7.5c1.2-1.1 2.4-1.1 3.6 0s2.4 1.1 3.6 0 2.4-1.1 3.8 0M4.5 11c1.2-1.1 2.4-1.1 3.6 0s2.4 1.1 3.6 0 2.4-1.1 3.8 0M4.5 14.5c1.2-1.1 2.4-1.1 3.6 0s2.4 1.1 3.6 0 2.4-1.1 3.8 0" fill="none" stroke="#fff" stroke-width="1.4" stroke-linecap="round"/>'
    : kind === 'shelter'
      ? '<path d="M5 10l5-4.2 5 4.2v5h-3.4v-3.5H8.4V15H5z" fill="#fff"/>'
      : '<path d="M7.2 15l1.3-10h3l1.3 10M10 5.8v2.5m0 2.2V14" fill="none" stroke="#fff" stroke-width="1.5" stroke-linecap="round"/>';
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20"><circle cx="10" cy="10" r="9" fill="${color}" stroke="#fff" stroke-width="2"/>${glyph}</svg>`;
  return { url: `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`, scaledSize: new google.maps.Size(18, 18), anchor: new google.maps.Point(9, 9) };
}

function addMarker(row, color, title, kind) {
  const marker = new google.maps.Marker({ map: state.map, position: { lat: row.lat, lng: row.lng }, title, icon: pinIcon(kind, color) }); state.markers.push(marker);
}

function renderMarkers() {
  clearMarkers(); if (!state.map || !state.point) return;
  const filter = state.route === 'shelters' ? 'shelter' : state.filter;
  if (['all', 'road'].includes(filter)) roadRows().forEach((row) => addMarker(row, row.kind === 'cctv' ? '#7547a8' : ROAD_COLORS[row.viewState], row.kind === 'cctv' ? `${row.road} ${row.section}` : (row.name || row.code), 'road'));
  if (['all', 'canal'].includes(filter)) canalRows().forEach((row) => addMarker(row, CANAL_COLORS[row.viewState], `คลอง: ${row.river?.trim() || 'ไม่ระบุชื่อคลอง'}`, 'canal'));
  if (['all', 'shelter'].includes(filter)) shelterRows().forEach((row) => addMarker(row, '#087f59', row.name, 'shelter'));
}

function render() { renderHome(); renderMapResults(); renderShelters(); }

function selectPoint(point, moveMap = true) {
  if (!Number.isFinite(point.lat) || !Number.isFinite(point.lng) || Math.abs(point.lat) > 90 || Math.abs(point.lng) > 180) return;
  state.point = point; setMessage('');
  if (state.map) {
    if (!state.pin) state.pin = new google.maps.Marker({ map: state.map, title: 'ตำแหน่งที่เลือก', zIndex: 1000 });
    if (!state.circle) state.circle = new google.maps.Circle({ map: state.map, fillColor: '#168bb2', fillOpacity: .1, strokeColor: '#0c799d', strokeOpacity: .8, strokeWeight: 2, clickable: false });
    state.pin.setPosition(point); state.circle.setCenter(point); state.circle.setRadius(state.radius * 1000);
    if (moveMap) state.map.fitBounds(state.circle.getBounds(), 28);
  }
  render();
}

function locate() {
  const buttons = [$('locateBtn'), $('mapLocateBtn'), $('shelterLocateBtn')].filter(Boolean);
  if (!navigator.geolocation) { setMessage('อุปกรณ์ไม่รองรับตำแหน่ง กรุณาแตะแผนที่'); return; }
  buttons.forEach((button) => { button.disabled = true; });
  navigator.geolocation.getCurrentPosition(({ coords }) => { buttons.forEach((button) => { button.disabled = false; }); selectPoint({ lat: coords.latitude, lng: coords.longitude }); }, () => { buttons.forEach((button) => { button.disabled = false; }); setMessage('ไม่สามารถใช้ตำแหน่งได้ กรุณาแตะแผนที่เพื่อเลือกจุด'); }, { enableHighAccuracy: false, timeout: 10000 });
}

function usePlace(place) {
  const location = place?.geometry?.location;
  if (!location) return false;
  const lat = typeof location.lat === 'function' ? location.lat() : location.lat;
  const lng = typeof location.lng === 'function' ? location.lng() : location.lng;
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return false;
  const label = place.name || place.formatted_address;
  if (label) ['placeSearch', 'mapPlaceSearch'].forEach((id) => { $(id).value = label; });
  selectPoint({ lat, lng });
  return true;
}

async function searchPlace(inputId = 'placeSearch', buttonId = 'placeSearchBtn') {
  const input = $(inputId); const button = $(buttonId); const query = input.value.trim();
  if (!query) { setMessage('กรุณาพิมพ์ชื่อถนน เขต หรือสถานที่ที่ต้องการค้นหา'); input.focus(); return; }
  if (!state.geocoder) { setMessage('ระบบค้นหาสถานที่ยังไม่พร้อม กรุณาลองใหม่อีกครั้ง'); return; }
  button.disabled = true; setMessage('กำลังค้นหาสถานที่…');
  try {
    const response = await state.geocoder.geocode({ address: `${query}, กรุงเทพมหานคร`, region: 'TH', componentRestrictions: { country: 'TH' } });
    const result = response.results?.[0];
    if (!result || !usePlace({ ...result, name: result.formatted_address })) setMessage('ไม่พบสถานที่ กรุณาลองระบุชื่อถนนหรือเขตให้ละเอียดขึ้น');
  } catch (error) { console.error('Place search failed', error); setMessage('ค้นหาสถานที่ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง'); }
  finally { button.disabled = false; }
}

async function initPlaceSearch() {
  try {
    const { Geocoder } = await importLibrary('geocoding'); state.geocoder = new Geocoder();
  } catch (error) { console.error('Geocoder load failed', error); }
  try {
    const { Autocomplete } = await importLibrary('places');
    for (const [inputId, buttonId] of [['placeSearch', 'placeSearchBtn'], ['mapPlaceSearch', 'mapPlaceSearchBtn']]) {
      const autocomplete = new Autocomplete($(inputId), { componentRestrictions: { country: 'th' }, fields: ['geometry', 'name', 'formatted_address'] });
      autocomplete.addListener('place_changed', () => { if (!usePlace(autocomplete.getPlace())) void searchPlace(inputId, buttonId); });
      state.autocompletes.push(autocomplete);
    }
  } catch (error) { console.warn('Place autocomplete unavailable; text search remains active', error); }
}

function go(route) { if (!ROUTES.has(route)) route = 'home'; if (location.hash !== `#${route}`) location.hash = route; else applyRoute(); }

function applyRoute() {
  state.route = ROUTES.has(location.hash.slice(1)) ? location.hash.slice(1) : 'home';
  document.querySelectorAll('[data-view]').forEach((view) => { const active = view.dataset.view === state.route; view.hidden = !active; view.classList.toggle('active', active); });
  document.querySelectorAll('.bottom-nav [data-route]').forEach((button) => button.classList.toggle('active', button.dataset.route === state.route || (state.route === 'shelters' && button.dataset.route === 'help')));
  if (state.route === 'shelters') $('shelterMapMount').append($('map')); else if (state.route === 'map') $('mapMount').append($('map')); else $('mapPreview').append($('map'));
  if (state.map && ['home', 'map', 'shelters'].includes(state.route)) { google.maps.event.trigger(state.map, 'resize'); if (state.circle) state.map.fitBounds(state.circle.getBounds(), 28); renderMarkers(); }
  window.scrollTo({ top: 0, behavior: 'instant' });
}

async function fetchJson(url) { const response = await fetch(`${url}?t=${Date.now()}`, { cache: 'no-store' }); if (!response.ok) throw new Error(`HTTP ${response.status}`); return response.json(); }

async function loadData() {
  const urls = ['./districts.geojson', './nowcast-data.json', './floodsupport-data.json', './road-flood-data.json', './cctv-flood-data.json', './canal-water-data.json'];
  const results = await Promise.allSettled(urls.map(fetchJson));
  state.boundaries = results[0].status === 'fulfilled' && results[0].value?.features?.length === 50 ? results[0].value : null;
  [state.rain, state.shelters, state.road, state.cctv, state.canal] = results.slice(1).map((result) => result.status === 'fulfilled' ? result.value : null);
  results.forEach((result, index) => { if (result.status === 'rejected') console.error(`Data load failed: ${urls[index]}`, result.reason); }); render();
}

async function initMap() {
  try {
    setOptions({ key: GOOGLE_MAPS_KEY, v: 'weekly', language: 'th', region: 'TH', authReferrerPolicy: 'origin' });
    const { Map } = await importLibrary('maps');
    state.map = new Map($('map'), { center: { lat: 13.7563, lng: 100.5018 }, zoom: 10, minZoom: 8, maxZoom: 19, renderingType: google.maps.RenderingType.RASTER, mapTypeId: google.maps.MapTypeId.ROADMAP, gestureHandling: 'cooperative', mapTypeControl: false, streetViewControl: false, fullscreenControl: false });
    state.map.addListener('click', (event) => selectPoint({ lat: event.latLng.lat(), lng: event.latLng.lng() }, false));
    state.map.addListener('tilesloaded', () => { $('mapState').hidden = true; }); applyRoute();
    void initPlaceSearch();
  } catch (error) { console.error('Map load failed', error); $('mapState').hidden = false; }
}

document.addEventListener('click', (event) => { const route = event.target.closest('[data-route]')?.dataset.route; if (route) go(route); });
document.querySelectorAll('input[name="radius"]').forEach((input) => input.addEventListener('change', () => { state.radius = Number(input.value); if (state.circle) { state.circle.setRadius(state.radius * 1000); state.map.fitBounds(state.circle.getBounds(), 28); } render(); }));
[$('locateBtn'), $('mapLocateBtn'), $('shelterLocateBtn')].filter(Boolean).forEach((button) => button.addEventListener('click', locate));
$('placeSearchBtn').addEventListener('click', () => searchPlace());
$('placeSearch').addEventListener('keydown', (event) => { if (event.key === 'Enter') { event.preventDefault(); void searchPlace(); } });
$('mapPlaceSearchBtn').addEventListener('click', () => searchPlace('mapPlaceSearch', 'mapPlaceSearchBtn'));
$('mapPlaceSearch').addEventListener('keydown', (event) => { if (event.key === 'Enter') { event.preventDefault(); void searchPlace('mapPlaceSearch', 'mapPlaceSearchBtn'); } });
window.addEventListener('hashchange', applyRoute); window.gm_authFailure = () => { $('mapState').hidden = false; };
if (!location.hash) history.replaceState(null, '', '#home'); applyRoute(); void initMap(); void loadData();
setInterval(loadData, 5 * 60 * 1000);
