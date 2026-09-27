import './data.css';
import { setOptions, importLibrary } from '@googlemaps/js-api-loader';
import { MarkerClusterer } from '@googlemaps/markerclusterer';
import { GOOGLE_MAPS_KEY } from './maps-config.js';
import { circleIntersectsFeature, distanceKm, pointInFeature } from './geo.mjs';
import { isRoadSensorVisible, ROAD_COLORS, roadState } from './road.mjs';
import { CANAL_COLORS, canalState, isCanalStationVisible } from './canal.mjs';

const $ = (id) => document.getElementById(id);
const state = { point: null, radius: 10, boundaries: null, rain: null, shelters: null, road: null, cctv: null, canal: null, map: null, pin: null, circle: null, clusterer: null, markers: [], roadClusterer: null, roadMarkers: [], canalClusterer: null, canalMarkers: [] };
const thaiTime = (value) => value ? new Intl.DateTimeFormat('th-TH', { dateStyle: 'short', timeStyle: 'short', timeZone: 'Asia/Bangkok' }).format(new Date(value)) : 'ไม่ทราบเวลา';
const elem = (tag, className, content) => { const node = document.createElement(tag); if (className) node.className = className; if (content !== undefined) node.textContent = content; return node; };
const empty = (text) => elem('p', 'empty', text);

function message(text) { $('locationState').textContent = text; $('locationState').hidden = !text; }
function selectedDistrict() { return state.boundaries?.features.find((feature) => pointInFeature(state.point, feature)); }
function nameFor(feature) { return state.rain?.payload?.districts?.[feature.properties.districtCode]?.district_t || feature.properties.nameEnglish; }

function selectPoint(point, moveMap = true) {
  if (!Number.isFinite(point.lat) || !Number.isFinite(point.lng) || Math.abs(point.lat) > 90 || Math.abs(point.lng) > 180) return;
  state.point = point;
  message('');
  if (state.map) {
    if (!state.pin) state.pin = new google.maps.Marker({ map: state.map, title: 'พิกัดที่เลือก', zIndex: 1000 });
    if (!state.circle) state.circle = new google.maps.Circle({ map: state.map, fillColor: '#238fc0', fillOpacity: .1, strokeColor: '#167fa8', strokeOpacity: .75, strokeWeight: 2, clickable: false });
    state.pin.setPosition(point);
    state.circle.setCenter(point);
    state.circle.setRadius(state.radius * 1000);
    if (moveMap) state.map.fitBounds(state.circle.getBounds(), 28);
  }
  render();
}

function renderShelters() {
  const root = $('shelterResults'); root.replaceChildren();
  renderMarkers([]);
  if (!state.shelters) { root.append(empty('โหลดข้อมูลศูนย์พักพิงไม่ได้ กรุณาลองใหม่ภายหลัง')); $('shelterTime').textContent = 'ข้อมูลไม่พร้อมใช้งาน'; return; }
  const data = state.shelters;
  const stale = data.sourceHealth && Object.values(data.sourceHealth).some((item) => item?.stale || item?.fetchFailed);
  $('shelterTime').textContent = `อัปเดต ${thaiTime(data.lastFetchedAt)}${stale ? ' · แหล่งข้อมูลบางส่วนอาจเก่า' : ''}`;
  if (!state.point) { root.append(empty('เลือกพิกัดเพื่อดูศูนย์พักพิงใกล้เคียง')); return; }
  const rows = (data.facilities || []).filter((row) => row.category === 'ศูนย์พักพิงชั่วคราว' &&
    row.location && Number.isFinite(row.location.lat) && Number.isFinite(row.location.lon))
    .map((row) => ({ ...row, km: distanceKm(state.point, { lat: row.location.lat, lng: row.location.lon }) }))
    .filter((row) => row.km <= state.radius).sort((a, b) => a.km - b.km);
  if (!rows.length) { root.append(empty(`ไม่พบศูนย์พักพิงที่มีพิกัดยืนยันในรัศมี ${state.radius} กม.`)); return; }
  root.append(elem('p', 'empty', `พบ ${rows.length} แห่งในรัศมี ${state.radius} กม.`));
  const more = rows.length > 5 ? document.createElement('details') : null;
  if (more) { const summary = document.createElement('summary'); summary.textContent = `ดูศูนย์พักพิงอีก ${rows.length - 5} แห่ง`; more.append(summary); }
  for (const [index, row] of rows.entries()) {
    const card = elem('article', 'item');
    card.append(elem('h3', '', row.name));
    card.append(elem('p', 'tag', `${row.km.toFixed(1)} กม. (เส้นตรง) · เขต${row.district || 'ไม่ทราบ'}`));
    if (row.status) card.append(elem('p', '', `สถานะ: ${row.status}`));
    if (Number.isFinite(row.available)) card.append(elem('p', '', `ว่าง ${row.available} ${row.unitType || 'คน'}`));
    if (row.phone) {
      const firstNumber = String(row.phone).match(/(?:\+?66|0)[\d -]{7,13}/)?.[0]?.replace(/[^+0-9]/g, '');
      if (firstNumber) { const phone = elem('a', '', `โทร ${row.phone}`); phone.href = `tel:${firstNumber}`; card.append(phone); }
      else card.append(elem('p', '', `โทร ${row.phone}`));
    }
    const nav = elem('a', '', 'นำทางด้วย Google Maps ↗');
    nav.href = `https://www.google.com/maps/dir/?api=1&destination=${row.location.lat},${row.location.lon}`;
    nav.target = '_blank'; nav.rel = 'noopener noreferrer';
    card.append(nav); (index < 5 ? root : more).append(card);
  }
  if (more) root.append(more);
  renderMarkers(rows);
}

function renderMarkers(rows) {
  state.clusterer?.clearMarkers();
  for (const marker of state.markers) marker.setMap(null);
  state.markers = [];
  if (!state.map) return;
  for (const row of rows) {
    const marker = new google.maps.Marker({ position: { lat: row.location.lat, lng: row.location.lon }, title: row.name,
      icon: { path: google.maps.SymbolPath.CIRCLE, scale: 6, fillColor: '#079173', fillOpacity: 1, strokeColor: '#fff', strokeWeight: 2 } });
    marker.addListener('click', () => { const item = [...$('shelterResults').querySelectorAll('.item')].find((node) => node.querySelector('h3')?.textContent === row.name); item?.closest('details')?.setAttribute('open', ''); item?.scrollIntoView({ behavior: 'smooth', block: 'center' }); });
    state.markers.push(marker);
  }
  state.clusterer.addMarkers(state.markers);
}

function renderRain() {
  const root = $('rainResults'); root.replaceChildren();
  const snapshot = state.rain;
  if (!snapshot?.payload) { $('rainTime').textContent = 'ข้อมูลไม่พร้อมใช้งาน'; root.append(empty('โหลดพยากรณ์ฝนไม่ได้ กรุณาลองใหม่ภายหลัง')); return; }
  const payload = snapshot.payload;
  const age = Date.now() - Date.parse(snapshot.lastFetchedAt);
  const stale = snapshot.fetchFailed || !Number.isFinite(age) || age > 30 * 60 * 1000;
  $('rainTime').textContent = `รอบ ${String(payload.base_time || payload.generated_at).replace('T', ' ')} น. · ดึงล่าสุด ${thaiTime(snapshot.lastFetchedAt)}${stale ? ' · ข้อมูลเก่า' : ''}`;
  if (!state.point) { root.append(empty('เลือกพิกัดเพื่อดูพยากรณ์ฝนในเขตใกล้เคียง')); return; }
  if (!state.boundaries) { root.append(empty('โหลดขอบเขตเขตไม่ได้ จึงยังระบุพยากรณ์ใกล้พิกัดไม่ได้')); return; }
  const primary = selectedDistrict();
  const features = state.boundaries.features.filter((feature) => circleIntersectsFeature(state.point, state.radius, feature));
  features.sort((a, b) => (a === primary ? -1 : b === primary ? 1 : nameFor(a).localeCompare(nameFor(b), 'th')));
  if (!features.length) { root.append(empty('พิกัดนี้อยู่นอกพื้นที่เขตกรุงเทพมหานครในรัศมีที่เลือก')); return; }
  root.append(elem('p', 'empty', `${primary ? `พิกัดอยู่ในเขต${nameFor(primary)} · ` : ''}พบ ${features.length} เขตที่ตัดกับรัศมี ${state.radius} กม.`));
  const more = features.length > 1 ? document.createElement('details') : null;
  if (more) { const summary = document.createElement('summary'); summary.textContent = `ดูพยากรณ์เขตใกล้เคียงอีก ${features.length - 1} เขต`; more.append(summary); }
  for (const [index, feature] of features.entries()) {
    const district = payload.districts[feature.properties.districtCode];
    if (!district) continue;
    const card = elem('article', 'item');
    card.append(elem('h3', '', `${feature === primary ? '⌖ ' : ''}เขต${district.district_t}`));
    card.append(elem('p', 'tag', district.onset_min === null ? 'ยังไม่คาดว่ามีฝนตามเกณฑ์ของ API' : `คาดว่าฝนเริ่มใน ${district.onset_min} นาทีจากเวลารอบพยากรณ์`));
    card.append(elem('p', '', `ความแรงฝนระดับสูง (P95) ${Number(district.peak_mmhr || 0).toFixed(1)} มม./ชม. · โอกาสฝนสูงสุดในช่วงพยากรณ์ ${Number(district.prob_rain_pct || 0).toFixed(0)}%`));
    (index === 0 ? root : more).append(card);
  }
  if (more) root.append(more);
}

function cctvState(row) { return row.severity === 'high' ? 'flooding' : row.severity === 'minor' ? 'minor_flood' : 'reported'; }

function renderRoadMarkers(rows) {
  state.roadClusterer?.clearMarkers();
  for (const marker of state.roadMarkers) marker.setMap(null);
  state.roadMarkers = [];
  if (!state.map) return;
  for (const row of rows) {
    const isCctv = row.kind === 'cctv';
    const status = isCctv ? cctvState(row) : roadState(row);
    const marker = new google.maps.Marker({ position: { lat: row.lat, lng: isCctv ? row.lng : row.lon },
      title: isCctv ? `รายงาน CCTV: ${row.road} ${row.section}` : `จุดวัดน้ำท่วมถนน: ${row.name}`,
      icon: { path: isCctv ? 'M 0,-8 8,0 0,8 -8,0 z' : google.maps.SymbolPath.CIRCLE, scale: isCctv ? 1 : 7,
        fillColor: status === 'reported' ? '#7547a8' : ROAD_COLORS[status], fillOpacity: 1, strokeColor: '#fff', strokeWeight: 2 } });
    marker.addListener('click', () => { const item = [...$('roadResults').querySelectorAll('.item')].find((node) => node.dataset.roadKey === row.key); item?.closest('details')?.setAttribute('open', ''); item?.scrollIntoView({ behavior: 'smooth', block: 'center' }); });
    state.roadMarkers.push(marker);
  }
  state.roadClusterer.addMarkers(state.roadMarkers);
}

function renderRoad() {
  const root = $('roadResults'); root.replaceChildren();
  renderRoadMarkers([]);
  const data = state.road;
  const cctv = state.cctv;
  if (!data?.sensors && !cctv?.locations) { $('roadTime').textContent = 'ข้อมูลไม่พร้อมใช้งาน'; root.append(empty('โหลดข้อมูลน้ำท่วมถนนไม่ได้ กรุณาลองใหม่ภายหลัง')); return; }
  const age = data ? Date.now() - Date.parse(data.lastFetchedAt) : NaN;
  const stale = data && (data.fetchFailed || !Number.isFinite(age) || age > 15 * 60 * 1000);
  const sensorTime = data ? `เซ็นเซอร์ ${thaiTime(data.lastFetchedAt)}${stale ? ' · ข้อมูลอาจเก่า' : ''}` : 'เซ็นเซอร์ไม่พร้อม';
  const cctvTime = cctv?.source?.reportedAt ? `CCTV ${thaiTime(cctv.source.reportedAt)}` : 'CCTV ไม่พร้อม';
  $('roadTime').textContent = `${sensorTime} · ${cctvTime}`;
  if (!state.point) { root.append(empty('เลือกพิกัดเพื่อดูข้อมูลน้ำท่วมถนนใกล้เคียง')); return; }
  const priority = { flooding: 0, minor_flood: 1, reported: 2, normal: 3, unavailable: 4 };
  const nowMs = Date.now();
  const sensorRows = (data?.sensors || []).filter((row) => isRoadSensorVisible(row) && Number.isFinite(row.lat) && Number.isFinite(row.lon))
    .map((row) => ({ ...row, kind: 'sensor', key: `sensor-${row.id}`, km: distanceKm(state.point, { lat: row.lat, lng: row.lon }) }))
    .filter((row) => row.km <= state.radius);
  const cctvRows = (cctv?.locations || []).filter((row) => Number.isFinite(row.lat) && Number.isFinite(row.lng))
    .map((row) => ({ ...row, kind: 'cctv', key: row.id, km: distanceKm(state.point, row) }))
    .filter((row) => row.km <= state.radius);
  const rows = [...sensorRows, ...cctvRows].sort((a, b) => {
    const aState = a.kind === 'cctv' ? cctvState(a) : roadState(a, nowMs);
    const bState = b.kind === 'cctv' ? cctvState(b) : roadState(b, nowMs);
    return priority[aState] - priority[bState] || a.km - b.km;
  });
  if (!rows.length) { root.append(empty(`ไม่พบข้อมูลน้ำท่วมถนนในรัศมี ${state.radius} กม.`)); return; }
  const counts = { flooding: 0, minor_flood: 0, normal: 0, unavailable: 0 };
  for (const row of sensorRows) counts[roadState(row)] += 1;
  const cctvCounts = { high: 0, minor: 0, reported: 0 };
  for (const row of cctvRows) cctvCounts[row.severity] += 1;
  const summary = elem('div', 'road-summary');
  for (const [status, label, count] of [
    ['flooding', 'เซ็นเซอร์น้ำท่วม', counts.flooding], ['minor_flood', 'เซ็นเซอร์ท่วมเล็กน้อย', counts.minor_flood],
    ['cctv-high', 'CCTV ท่วมสูง', cctvCounts.high], ['cctv-minor', 'CCTV ท่วมเล็กน้อย', cctvCounts.minor],
    ['cctv-reported', 'CCTV ระดับไม่ระบุ', cctvCounts.reported],
    ['normal', 'เซ็นเซอร์ปกติ', counts.normal]
  ]) summary.append(elem('span', status, `${label} ${count}`));
  root.append(elem('p', 'empty', `พบเซ็นเซอร์ ${sensorRows.length} จุด และรายงาน CCTV ${cctvRows.length} จุดในรัศมี ${state.radius} กม. · เรียงจุดน้ำท่วมก่อนและตามระยะทาง`), summary);
  const more = rows.length > 5 ? document.createElement('details') : null;
  if (more) { const label = document.createElement('summary'); label.textContent = `ดูข้อมูลน้ำท่วมถนนอีก ${rows.length - 5} จุด`; more.append(label); }
  for (const [index, row] of rows.entries()) {
    const isCctv = row.kind === 'cctv';
    const status = isCctv ? cctvState(row) : roadState(row);
    const card = elem('article', `item${isCctv ? ' cctv-item' : ''}`); card.dataset.roadKey = row.key;
    card.append(elem('h3', '', isCctv ? `${row.road} · ${row.section}` : (row.name || row.road || row.code)));
    const feature = isCctv && state.boundaries?.features.find((item) => pointInFeature(row, item));
    const district = isCctv ? (feature ? nameFor(feature) : 'ไม่ทราบ') : (row.district || 'ไม่ทราบ');
    card.append(elem('p', 'tag', `${row.km.toFixed(1)} กม. (เส้นตรง) · เขต${district}${isCctv ? ' · รายงาน CCTV' : ' · เซ็นเซอร์'}`));
    const statusText = status === 'flooding' ? 'น้ำท่วม' : status === 'minor_flood' ? 'น้ำท่วมเล็กน้อย' :
      status === 'reported' ? 'มีรายงานน้ำท่วมขัง' : status === 'normal' ? 'ปกติที่จุดตรวจวัด' : 'ไม่มีข้อมูลปัจจุบัน';
    card.append(elem('p', `road-status ${status}`, statusText));
    if (isCctv) {
      if (row.passability) card.append(elem('p', '', row.passability === 'small_vehicle' ? 'รถเล็กสัญจรได้ตามรายงาน' : row.passability === 'vehicle' ? 'รถยนต์สัญจรได้ตามรายงาน' : 'สัญจรได้ตามรายงาน'));
      card.append(elem('p', '', `รายงาน ${thaiTime(cctv.source.reportedAt)} · พิกัดตัวแทนของจุดหรือช่วงถนน`));
    } else {
      if (status !== 'unavailable') card.append(elem('p', '', `ระดับน้ำที่วัดได้ ${row.valueCm.toFixed(1)} ซม.`));
      else card.append(elem('p', '', 'ค่าที่อ่านได้เกิน 60 นาทีหรือไม่สมบูรณ์'));
      card.append(elem('p', '', `อ่านค่าล่าสุด ${thaiTime(row.observedAt)}`));
    }
    (index < 5 ? root : more).append(card);
  }
  if (more) root.append(more);
  renderRoadMarkers(rows);
}

function renderCanalMarkers(rows) {
  state.canalClusterer?.clearMarkers();
  for (const marker of state.canalMarkers) marker.setMap(null);
  state.canalMarkers = [];
  if (!state.map) return;
  for (const row of rows) {
    const status = canalState(row);
    const marker = new google.maps.Marker({ position: { lat: row.lat, lng: row.lng }, title: `${row.river || row.name || 'สถานีวัดระดับน้ำ'} (${row.code})`,
      icon: { path: google.maps.SymbolPath.CIRCLE, scale: 7, fillColor: CANAL_COLORS[status], fillOpacity: 1, strokeColor: '#fff', strokeWeight: 2 } });
    marker.addListener('click', () => { const item = $(`canal-${row.code.replaceAll('.', '-')}`); item?.closest('details')?.setAttribute('open', ''); item?.scrollIntoView({ behavior: 'smooth', block: 'center' }); });
    state.canalMarkers.push(marker);
  }
  state.canalClusterer.addMarkers(state.canalMarkers);
}

function renderCanal() {
  const root = $('canalResults'); root.replaceChildren();
  renderCanalMarkers([]);
  const data = state.canal;
  if (!data?.stations) { $('canalTime').textContent = 'ข้อมูลไม่พร้อมใช้งาน'; root.append(empty('โหลดข้อมูลระดับน้ำในคลองไม่ได้ กรุณาลองใหม่ภายหลัง')); return; }
  const age = Date.now() - Date.parse(data.lastFetchedAt);
  const stale = data.fetchFailed || !Number.isFinite(age) || age > 15 * 60 * 1000;
  $('canalTime').textContent = `อัปเดต ${thaiTime(data.lastFetchedAt)}${stale ? ' · ข้อมูลอาจเก่า' : ''}`;
  if (!state.point) { root.append(empty('เลือกพิกัดเพื่อดูระดับน้ำในคลองใกล้เคียง')); return; }
  const priority = { critical: 0, warning: 1, normal: 2, unavailable: 3 };
  const rows = data.stations.filter((row) => isCanalStationVisible(row) && Number.isFinite(row.lat) && Number.isFinite(row.lng))
    .map((row) => ({ ...row, km: distanceKm(state.point, row) }))
    .filter((row) => row.km <= state.radius)
    .sort((a, b) => priority[canalState(a)] - priority[canalState(b)] || a.km - b.km);
  if (!rows.length) { root.append(empty(`ไม่พบสถานีวัดระดับน้ำในคลองในรัศมี ${state.radius} กม.`)); return; }
  const counts = { critical: 0, warning: 0, normal: 0, unavailable: 0 };
  for (const row of rows) counts[canalState(row)] += 1;
  const summary = elem('div', 'road-summary');
  for (const [status, label] of [['critical', 'วิกฤต'], ['warning', 'เตือนภัย'], ['normal', 'ปกติ'], ['unavailable', 'ข้อมูลเก่า/ไม่สมบูรณ์']]) summary.append(elem('span', `canal-${status}`, `${label} ${counts[status]}`));
  root.append(elem('p', 'empty', `พบ ${rows.length} สถานีในรัศมี ${state.radius} กม. · เรียงสถานะวิกฤตก่อนและตามระยะทาง`), summary);
  const more = rows.length > 5 ? document.createElement('details') : null;
  if (more) { const label = document.createElement('summary'); label.textContent = `ดูสถานีวัดระดับน้ำอีก ${rows.length - 5} แห่ง`; more.append(label); }
  for (const [index, row] of rows.entries()) {
    const status = canalState(row);
    const card = elem('article', 'item canal-item'); card.id = `canal-${row.code.replaceAll('.', '-')}`;
    card.append(elem('h3', '', row.name || `สถานี ${row.code}`));
    if (row.river) card.append(elem('p', '', `ชื่อคลอง: ${row.river}`));
    card.append(elem('p', 'tag', `รหัสสถานี ${row.code}`));
    const feature = state.boundaries?.features.find((item) => pointInFeature(row, item));
    card.append(elem('p', 'tag', `${row.km.toFixed(1)} กม. (เส้นตรง)${feature ? ` · เขต${nameFor(feature)}` : ''}`));
    const statusText = status === 'critical' ? 'วิกฤต' : status === 'warning' ? 'เตือนภัย' : status === 'normal' ? 'ปกติ' : 'ข้อมูลเก่าหรือไม่สมบูรณ์';
    card.append(elem('p', `canal-status ${status}`, `สถานะ: ${statusText}`));
    if (status !== 'unavailable') card.append(elem('p', '', `ระดับน้ำ ${row.levelM.toFixed(2)} ม.`));
    card.append(elem('p', '', `อ่านค่าล่าสุด ${thaiTime(row.observedAt)}`));
    (index < 5 ? root : more).append(card);
  }
  if (more) root.append(more);
  renderCanalMarkers(rows);
}

function render() {
  const district = state.point && selectedDistrict();
  $('selectedName').textContent = state.point ? (district ? `พิกัดในเขต${nameFor(district)}` : 'พิกัดที่เลือก') : 'ยังไม่ได้เลือกพิกัด';
  $('selectedCoords').textContent = state.point ? `${state.point.lat.toFixed(6)}, ${state.point.lng.toFixed(6)} · รัศมี ${state.radius} กม.` : 'แตะแผนที่หรือใช้ตำแหน่งปัจจุบัน';
  renderRain(); renderShelters(); renderRoad(); renderCanal();
}

async function fetchJson(url) { const response = await fetch(`${url}?t=${Date.now()}`, { cache: 'no-store' }); if (!response.ok) throw new Error(`HTTP ${response.status}`); return response.json(); }
async function loadSources() {
  const results = await Promise.allSettled([fetchJson('./districts.geojson'), fetchJson('./nowcast-data.json'), fetchJson('./floodsupport-data.json')]);
  state.boundaries = results[0].status === 'fulfilled' && results[0].value?.features?.length === 50 ? results[0].value : null;
  state.rain = results[1].status === 'fulfilled' ? results[1].value : null;
  state.shelters = results[2].status === 'fulfilled' ? results[2].value : null;
  render();
}

async function loadRoad() {
  const results = await Promise.allSettled([fetchJson('./road-flood-data.json'), fetchJson('./cctv-flood-data.json'), fetchJson('./canal-water-data.json')]);
  state.road = results[0].status === 'fulfilled' ? results[0].value : null;
  state.cctv = results[1].status === 'fulfilled' ? results[1].value : null;
  state.canal = results[2].status === 'fulfilled' ? results[2].value : null;
  if (!state.road) console.error('Road flood sensor data load failed', results[0].reason);
  if (!state.cctv) console.error('Road flood CCTV data load failed', results[1].reason);
  if (!state.canal) console.error('Canal water data load failed', results[2].reason);
  renderRoad(); renderCanal();
}

async function initMap() {
  try {
    setOptions({ key: GOOGLE_MAPS_KEY, v: 'weekly', language: 'th', region: 'TH', authReferrerPolicy: 'origin' });
    const { Map } = await importLibrary('maps');
    state.map = new Map($('map'), { center: { lat: 13.7563, lng: 100.5018 }, zoom: 10, minZoom: 8, maxZoom: 19,
      renderingType: google.maps.RenderingType.RASTER, mapTypeId: google.maps.MapTypeId.ROADMAP,
      gestureHandling: matchMedia('(max-width: 760px)').matches ? 'cooperative' : 'greedy',
      mapTypeControl: false, streetViewControl: false, fullscreenControl: false });
    state.clusterer = new MarkerClusterer({ map: state.map, markers: [] });
    state.roadClusterer = new MarkerClusterer({ map: state.map, markers: [], renderer: { render: ({ count, position }) => new google.maps.Marker({
      position, label: { text: String(count), color: '#fff', fontWeight: 'bold' },
      icon: { path: google.maps.SymbolPath.CIRCLE, scale: 18, fillColor: '#bd5736', fillOpacity: 1, strokeColor: '#fff', strokeWeight: 2 },
      zIndex: Number(google.maps.Marker.MAX_ZINDEX) + count
    }) } });
    state.canalClusterer = new MarkerClusterer({ map: state.map, markers: [], renderer: { render: ({ count, position }) => new google.maps.Marker({
      position, label: { text: String(count), color: '#fff', fontWeight: 'bold' },
      icon: { path: google.maps.SymbolPath.CIRCLE, scale: 18, fillColor: '#6659a7', fillOpacity: 1, strokeColor: '#fff', strokeWeight: 2 },
      zIndex: Number(google.maps.Marker.MAX_ZINDEX) + count
    }) } });
    state.map.addListener('click', (event) => selectPoint({ lat: event.latLng.lat(), lng: event.latLng.lng() }, false));
    state.map.addListener('tilesloaded', () => { $('mapState').hidden = true; });
    if (state.point) selectPoint(state.point);
    render();
  } catch (error) { console.error('Map load failed', error); $('mapState').hidden = false; }
}

window.gm_authFailure = () => { $('mapState').hidden = false; };
$('radius').addEventListener('change', () => { state.radius = Number($('radius').value); if (state.circle) { state.circle.setRadius(state.radius * 1000); state.map.fitBounds(state.circle.getBounds(), 28); } render(); });
$('locateBtn').addEventListener('click', () => {
  if (!navigator.geolocation) { message('อุปกรณ์ไม่รองรับตำแหน่ง กรุณาแตะแผนที่เพื่อเลือกจุด'); return; }
  $('locateBtn').disabled = true;
  navigator.geolocation.getCurrentPosition(({ coords }) => { $('locateBtn').disabled = false; selectPoint({ lat: coords.latitude, lng: coords.longitude }); },
    () => { $('locateBtn').disabled = false; message('ไม่สามารถใช้ตำแหน่งได้ กรุณาแตะแผนที่เพื่อเลือกจุด'); },
    { enableHighAccuracy: false, timeout: 10000 });
});
void initMap();
void loadSources();
void loadRoad();
setInterval(() => { void loadSources(); }, 15 * 60 * 1000);
setInterval(() => { void loadRoad(); }, 5 * 60 * 1000);
