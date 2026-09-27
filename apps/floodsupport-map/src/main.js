import './style.css';
import { setOptions, importLibrary } from '@googlemaps/js-api-loader';
import { MarkerClusterer } from '@googlemaps/markerclusterer';

// A browser Maps JavaScript API key is public by design. Restrict it to this
// website's HTTPS referrer and Maps JavaScript API in Google Cloud Console.
const GOOGLE_MAPS_KEY = 'AIzaSyB6v6q1yPgrjtm3KPuqf6QAtkkzKahUV20';
const $ = (id) => document.getElementById(id);
const state = { data: null, category: '', aiIds: null, selectedId: null, visible: [], userLocation: null, staffData: null, staffCsrf: null, view: 'public' };
const categoryColors = {
  'ศูนย์พักพิงชั่วคราว': '#007a9a',
  'จุดแจกจ่ายอาหาร/น้ำดื่ม': '#e08b19',
  'จุดบริการทางการแพทย์': '#c94e63',
  'จุดจอดรถ': '#7252ae',
  'จุดบริการรถรับ-ส่งประชาชน': '#18836c',
};
let map = null;
let clusterer = null;
let markers = [];
let userMarker = null;
let initialFitDone = false;
window.gm_authFailure = () => { $('mapError').hidden = false; };

async function initGoogleMap() {
  try {
    setOptions({ key: GOOGLE_MAPS_KEY, v: 'weekly', language: 'th', region: 'TH', authReferrerPolicy: 'origin' });
    const { Map } = await importLibrary('maps');
    map = new Map($('map'), {
      center: { lat: 13.76, lng: 100.54 },
      zoom: 10.3,
      minZoom: 8,
      maxZoom: 19,
      renderingType: google.maps.RenderingType.RASTER,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      gestureHandling: matchMedia('(max-width: 980px)').matches ? 'cooperative' : 'greedy',
      mapTypeControl: false,
      streetViewControl: false,
      fullscreenControl: false,
      clickableIcons: false,
      zoomControl: true,
    });
    clusterer = new MarkerClusterer({ map, markers: [] });
    map.addListener('tilesloaded', () => { $('mapError').hidden = true; });
    updatePoints();
    if (state.userLocation) showUserMarker();
    if (state.data && !initialFitDone) { fitToVisible(); initialFitDone = true; }
  } catch (error) {
    console.error('Google Maps could not load', error);
    $('mapError').hidden = false;
  }
}

function dateLabel(value) {
  if (!value) return 'ไม่ทราบเวลา';
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? 'ไม่ทราบเวลา' : new Intl.DateTimeFormat('th-TH', { timeZone: 'Asia/Bangkok', dateStyle: 'medium', timeStyle: 'short' }).format(date);
}
function safeSourceLink(value) {
  if (typeof value !== 'string') return null;
  try {
    const url = new URL(value.trim());
    if (url.protocol !== 'https:') return null;
    if (url.hostname === 'docs.google.com' && url.pathname.startsWith('/spreadsheets/d/1S3mDcZisdLkcIFbv996xKo1G6-E2KVEt1d8lyz-gR_U/')) return url.href;
    return ['maps.app.goo.gl', 'www.google.com', 'google.com', 'share.google', 'me-l.co'].includes(url.hostname) ? url.href : null;
  } catch { return null; }
}
function navUrl(place) {
  const point = place.location;
  if (!point || !Number.isFinite(point.lat) || !Number.isFinite(point.lon)) return null;
  return `https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(`${point.lat},${point.lon}`)}`;
}
function element(tag, className, text) {
  const item = document.createElement(tag);
  if (className) item.className = className;
  if (text !== undefined) item.textContent = text;
  return item;
}
function externalLink(label, href, className) {
  const a = element('a', className, label);
  a.href = href;
  a.target = '_blank';
  a.rel = 'noopener noreferrer';
  return a;
}
function setNotice(message = '') {
  $('notice').hidden = !message;
  $('notice').textContent = message;
}

function selectPlace(place) {
  state.selectedId = place.id;
  const detail = $('placeDetail');
  detail.replaceChildren();
  const top = element('div', 'detail-top');
  const intro = element('div');
  intro.append(element('div', 'detail-type', place.category), element('h3', '', place.name));
  top.append(intro);
  const close = element('button', 'detail-close', '×');
  close.type = 'button'; close.setAttribute('aria-label', 'ปิดรายละเอียด'); close.addEventListener('click', () => { detail.hidden = true; state.selectedId = null; renderList(); });
  top.append(close); detail.append(top);
  detail.append(element('p', 'detail-meta', `${place.district}${place.subdistrict ? ` · แขวง${place.subdistrict}` : ''} · ${place.status}`));
  if (Number.isFinite(place.capacity) && place.capacity > 0) detail.append(element('p', 'detail-meta', `ความจุ ${place.capacity.toLocaleString('th-TH')} ${place.unitType || ''} · คงเหลือ ${Number.isFinite(place.available) ? place.available.toLocaleString('th-TH') : 'ไม่ทราบ'} ${place.unitType || ''}`));
  detail.append(element('p', 'detail-meta', `ข้อมูลจาก: ${(place.sources || ['Flood Support']).join(' + ')}`));
  detail.append(element('p', 'detail-meta', `ดึงข้อมูลล่าสุด: ${dateLabel(state.data?.lastFetchedAt)}`));
  if (place.conditions) detail.append(element('p', 'detail-note', `เงื่อนไข: ${place.conditions}`));
  if (place.phone) detail.append(element('p', 'detail-meta', `ติดต่อ: ${place.phone}`));
  if (place.routeDetails) detail.append(element('p', 'detail-note', place.routeDetails));
  if (place.additionalDetails) detail.append(element('p', 'detail-note', place.additionalDetails));
  if (!place.location) detail.append(element('p', 'unmapped-label', 'ยังไม่มีพิกัดที่ยืนยันได้ จึงไม่แสดงหมุด'));
  const actions = element('div', 'detail-actions');
  const nav = navUrl(place); if (nav) actions.append(externalLink('นำทางด้วย Google Maps ↗', nav, 'nav-link'));
  const source = safeSourceLink(place.sourceLink); if (source) actions.append(externalLink('เปิดลิงก์ต้นทาง ↗', source, 'source-link'));
  detail.append(actions); detail.hidden = false;
  if (place.location && map) {
    map.panTo({ lat: place.location.lat, lng: place.location.lon });
    if (map.getZoom() < 14) map.setZoom(14);
  }
  renderList();
}

function renderChips() {
  const root = $('categoryChips'); root.replaceChildren();
  const categories = ['', ...(state.data?.categories || [])];
  for (const category of categories) {
    const count = category ? state.data.facilities.filter((row) => row.category === category).length : state.data.facilities.length;
    const button = element('button', 'chip'); button.type = 'button'; button.setAttribute('aria-pressed', String(state.category === category));
    button.append(document.createTextNode(category || 'ทุกประเภท'));
    button.append(element('span', 'chip-count', count.toLocaleString('th-TH')));
    if (category && !count) button.disabled = true;
    button.addEventListener('click', () => { state.category = category; render(); fitToVisible(); });
    root.append(button);
  }
}
function renderShelterSourceSummary() {
  const shelters = state.data.facilities.filter((row) => row.category === 'ศูนย์พักพิงชั่วคราว');
  const has = (row, source) => Array.isArray(row.sources) && row.sources.includes(source);
  const flood = shelters.filter((row) => has(row, 'Flood Support')).length;
  const sheets = shelters.filter((row) => has(row, 'Google Sheets')).length;
  const both = shelters.filter((row) => has(row, 'Flood Support') && has(row, 'Google Sheets')).length;
  for (const [id, count] of [['shelterTotal', shelters.length], ['shelterFloodCount', flood],
    ['shelterSheetCount', sheets], ['shelterBothCount', both]]) $(id).textContent = count.toLocaleString('th-TH');
  $('shelterSourceSummary').hidden = shelters.length === 0;
}
function populateSelects() {
  for (const [id, values] of [
    ['districtSelect', [...new Set(state.data.facilities.map((row) => row.district))].sort((a, b) => a.localeCompare(b, 'th'))],
    ['statusSelect', [...new Set(state.data.facilities.map((row) => row.status))].sort((a, b) => a.localeCompare(b, 'th'))],
  ]) {
    const select = $(id); const old = select.value;
    select.replaceChildren(element('option', '', id === 'districtSelect' ? 'ทุกเขต' : 'ทุกสถานะ'));
    select.firstChild.value = '';
    for (const value of values) { const option = element('option', '', value); option.value = value; select.append(option); }
    select.value = values.includes(old) ? old : '';
  }
}
function filteredPlaces() {
  if (!state.data) return [];
  const search = $('searchInput').value.trim().toLocaleLowerCase('th');
  const district = $('districtSelect').value, status = $('statusSelect').value;
  const rows = state.data.facilities.filter((row) =>
    (!state.category || row.category === state.category) &&
    (!district || row.district === district) &&
    (!status || row.status === status) &&
    (!state.aiIds || state.aiIds.has(row.id)) &&
    (!search || `${row.name} ${row.district} ${row.subdistrict || ''} ${row.category} ${row.routeDetails || ''}`.toLocaleLowerCase('th').includes(search))
  );
  if (state.userLocation) rows.sort((a, b) => distanceKm(a.location, state.userLocation) - distanceKm(b.location, state.userLocation));
  return rows;
}

function distanceKm(point, origin) {
  if (!point || !origin) return Infinity;
  const rad = Math.PI / 180;
  const dLat = (point.lat - origin.lat) * rad, dLon = (point.lon - origin.lng) * rad;
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(point.lat * rad) * Math.cos(origin.lat * rad) * Math.sin(dLon / 2) ** 2;
  return 12742 * Math.asin(Math.min(1, Math.sqrt(a)));
}
function updatePoints() {
  if (!map || !clusterer) return;
  clusterer.clearMarkers();
  for (const marker of markers) {
    google.maps.event.clearInstanceListeners(marker);
    marker.setMap(null);
  }
  markers = state.visible.filter((row) => row.location).map((row) => {
    const marker = new google.maps.Marker({
      position: { lat: row.location.lat, lng: row.location.lon },
      title: row.name,
      icon: {
        path: google.maps.SymbolPath.CIRCLE,
        scale: 10,
        fillColor: categoryColors[row.category] || '#007a9a',
        fillOpacity: 1,
        strokeColor: '#ffffff',
        strokeWeight: 3,
      },
    });
    marker.addListener('click', () => selectPlace(row));
    return marker;
  });
  clusterer.addMarkers(markers);
}
function fitToVisible() {
  if (!map) return;
  const located = state.visible.filter((row) => row.location);
  if (!located.length) return;
  const bounds = new google.maps.LatLngBounds();
  for (const row of located) bounds.extend({ lat: row.location.lat, lng: row.location.lon });
  map.fitBounds(bounds, { top: 55, right: 55, bottom: 55, left: 55 });
  google.maps.event.addListenerOnce(map, 'idle', () => { if (map.getZoom() > 14) map.setZoom(14); });
}
function renderList() {
  const root = $('resultList'); root.replaceChildren();
  if (!state.visible.length) { root.append(element('div', 'empty', 'ไม่พบรายการตามเงื่อนไขที่เลือก')); return; }
  for (const [label, hasLocation] of [['มีพิกัดยืนยัน', true], ['รอตรวจพิกัด', false]]) {
    const rows = state.visible.filter((row) => Boolean(row.location) === hasLocation);
    if (!rows.length) continue;
    const heading = element('div', 'group-title'); heading.append(element('span', '', label), element('span', '', `${rows.length.toLocaleString('th-TH')} รายการ`)); root.append(heading);
    for (const row of rows) {
      const card = element('button', 'result-card' + (state.selectedId === row.id ? ' selected' : ''));
      card.type = 'button'; card.setAttribute('aria-label', `ดูรายละเอียด ${row.name}`);
      card.append(element('div', 'result-type', row.category), element('h3', '', row.name), element('p', '', `${row.district} · ${row.status}`));
      if (Number.isFinite(row.capacity) && row.capacity > 0) card.append(element('p', row.status.includes('เต็ม') ? 'status full' : 'status', `คงเหลือ ${Number.isFinite(row.available) ? row.available.toLocaleString('th-TH') : 'ไม่ทราบ'} / ${row.capacity.toLocaleString('th-TH')} ${row.unitType || ''}`));
      if (state.userLocation && hasLocation) card.append(element('p', 'distance', `ประมาณ ${distanceKm(row.location, state.userLocation).toFixed(1)} กม. (เส้นตรง)`));
      card.append(element('p', 'source-label', `ข้อมูล: ${(row.sources || ['Flood Support']).join(' + ')}`));
      if (!hasLocation) card.append(element('p', 'unmapped-label', 'ยังไม่ยืนยันพิกัด'));
      card.addEventListener('click', () => selectPlace(row)); root.append(card);
    }
  }
}
function render() {
  if (!state.data) return;
  state.visible = filteredPlaces();
  const mapped = state.visible.filter((row) => row.location).length;
  $('resultCount').textContent = `แสดง ${state.visible.length.toLocaleString('th-TH')} รายการ`;
  $('pinCount').textContent = `${mapped.toLocaleString('th-TH')} หมุด`;
  renderChips(); updatePoints(); renderList();
  if (state.selectedId && !state.visible.some((row) => row.id === state.selectedId)) { state.selectedId = null; $('placeDetail').hidden = true; }
}

async function loadData() {
  $('refreshBtn').disabled = true;
  try {
    const response = await fetch(`./floodsupport-data.json?t=${Date.now()}`, { cache: 'no-store' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    if (!Array.isArray(data.facilities) || !Array.isArray(data.categories)) throw new Error('รูปแบบข้อมูลไม่ถูกต้อง');
    state.data = data;
    $('totalCount').textContent = data.total.toLocaleString('th-TH');
    $('mappedCount').textContent = data.mapped.toLocaleString('th-TH');
    $('unmappedCount').textContent = data.unmapped.toLocaleString('th-TH');
    $('freshness').textContent = `รวมข้อมูลล่าสุด ${dateLabel(data.lastFetchedAt)}`;
    const health = data.sourceHealth || {};
    $('sourceHealth').textContent = `Flood Support: ${dateLabel(health.api?.fetchedAt)}${health.api?.stale || health.api?.fetchFailed ? ' (ข้อมูลเก่า)' : ''} · Google Sheets: ${dateLabel(health.sheets?.fetchedAt)}${health.sheets?.stale || health.sheets?.fetchFailed ? ' (ข้อมูลเก่า)' : ''}`;
    const age = Date.now() - Date.parse(data.lastFetchedAt);
    setNotice(data.upstreamStale || !Number.isFinite(age) || age > 15 * 60 * 1000 ? 'ข้อมูลบางแหล่งอาจไม่เป็นปัจจุบัน กรุณาตรวจสอบกับหน่วยบริการก่อนเดินทาง' : '');
    populateSelects(); renderShelterSourceSummary(); render(); if (map && !initialFitDone) { fitToVisible(); initialFitDone = true; }
  } catch (error) {
    setNotice(state.data ? 'รีเฟรชไม่สำเร็จ กำลังแสดงข้อมูลชุดล่าสุดที่โหลดได้' : 'ไม่สามารถโหลดข้อมูลสถานที่ได้ กรุณาลองใหม่อีกครั้ง');
    if (!state.data) { $('freshness').textContent = 'โหลดข้อมูลไม่สำเร็จ'; $('resultCount').textContent = 'ยังไม่มีข้อมูล'; }
  } finally { $('refreshBtn').disabled = false; }
}

function keywordFallback(query) {
  const q = query.toLocaleLowerCase('th').trim();
  return state.data.facilities.filter((row) => `${row.name} ${row.district} ${row.category} ${row.status}`.toLocaleLowerCase('th').includes(q)).map((row) => row.id);
}
async function askAi(event) {
  event.preventDefault();
  if (!state.data) return;
  const query = $('aiQuery').value.trim(); if (!query) return;
  $('aiSubmit').disabled = true; $('aiState').hidden = false; $('aiState').textContent = 'กำลังค้นหาจากข้อมูลล่าสุด…';
  try {
    const response = await fetch('./floodsupport-ai.php', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ query }) });
    const result = await response.json();
    if (!response.ok || !Array.isArray(result.matchedIds)) throw new Error(result.error || 'ค้นหา AI ไม่สำเร็จ');
    state.aiIds = new Set(result.matchedIds);
    $('aiState').textContent = `AI ตีความ: ${result.interpretation || query} · พบ ${result.total.toLocaleString('th-TH')} รายการจากข้อมูลจริง`;
    $('clearAi').hidden = false; render(); fitToVisible();
  } catch (error) {
    const ids = keywordFallback(query);
    state.aiIds = new Set(ids);
    $('aiState').textContent = `AI ไม่พร้อมใช้งาน แสดงผลค้นหาคำตรง ${ids.length.toLocaleString('th-TH')} รายการ`;
    $('clearAi').hidden = false; render(); fitToVisible();
  } finally { $('aiSubmit').disabled = false; }
}

$('searchInput').addEventListener('input', render);
for (const id of ['districtSelect', 'statusSelect']) $(id).addEventListener('change', () => { render(); fitToVisible(); });
$('refreshBtn').addEventListener('click', loadData);
$('fitBtn').addEventListener('click', fitToVisible);
$('aiForm').addEventListener('submit', askAi);
$('clearAi').addEventListener('click', () => { state.aiIds = null; $('aiQuery').value = ''; $('aiState').hidden = true; $('clearAi').hidden = true; render(); fitToVisible(); });
function showUserMarker() {
  if (!map || !state.userLocation) return;
  if (userMarker) userMarker.setMap(null);
  userMarker = new google.maps.Marker({ map, position: state.userLocation, title: 'ตำแหน่งของฉัน', icon: { path: google.maps.SymbolPath.CIRCLE, scale: 9, fillColor: '#287cf0', fillOpacity: 1, strokeColor: '#fff', strokeWeight: 3 } });
}
function requestLocation() {
  if (!navigator.geolocation) { $('nearestState').textContent = 'อุปกรณ์นี้ไม่รองรับตำแหน่ง กรุณาเลือกเขต'; return; }
  $('nearbyBtn').disabled = true;
  navigator.geolocation.getCurrentPosition(({ coords }) => {
    state.userLocation = { lat: coords.latitude, lng: coords.longitude };
    showUserMarker();
    if (map) { map.panTo(state.userLocation); map.setZoom(13); }
    $('nearestState').textContent = 'เรียงสถานที่ที่มีพิกัดตามระยะทางเส้นตรงจากตำแหน่งของคุณ';
    $('nearbyBtn').disabled = false;
    render();
  }, () => { $('nearbyBtn').disabled = false; $('nearestState').textContent = 'ใช้ตำแหน่งไม่ได้ กรุณาค้นหาหรือเลือกเขต'; }, { enableHighAccuracy: false, timeout: 10000 });
}
$('locateBtn').addEventListener('click', requestLocation);
$('nearbyBtn').addEventListener('click', requestLocation);

const staffTypes = {
  reliefBags: 'ถุงยังชีพ', water: 'น้ำดื่ม', cookedMeals: 'อาหารปรุงสุก', gmc: 'รถ GMC',
  highClearance: 'รถยกสูง', buses: 'รถเมล์', bedridden: 'ผู้ป่วยติดเตียง',
  fiberglassBoats: 'เรือไฟเบอร์', flatBoats: 'เรือท้องแบน',
};
function staffCard(title, lines) {
  const card = element('article', 'staff-card'); card.append(element('h4', '', title));
  for (const line of lines.filter(Boolean)) card.append(element('p', '', line));
  return card;
}
function staffFollowup(kind, row, needType = '') {
  const saved = kind === 'district' ? row.followUp?.[needType] : row.followUp;
  const form = element('form', 'followup-form');
  const label = element('label', 'followup-check');
  const checked = document.createElement('input'); checked.type = 'checkbox'; checked.checked = Boolean(saved?.done);
  label.append(checked, element('span', '', 'ดำเนินการแล้ว'));
  const note = document.createElement('textarea'); note.maxLength = 500; note.rows = 2;
  note.placeholder = 'หมายเหตุการดำเนินการ (ถ้ามี)'; note.value = saved?.note || '';
  note.setAttribute('aria-label', `หมายเหตุการดำเนินการ ${kind === 'district' ? `เขต${row.district} ${staffTypes[needType]}` : row.name}`);
  const actions = element('div', 'followup-actions');
  const button = element('button', '', 'บันทึก'); button.type = 'submit';
  const message = element('span', 'followup-message', saved?.updatedAt ? `บันทึก ${dateLabel(saved.updatedAt)}` : '');
  message.setAttribute('role', 'status'); actions.append(button, message); form.append(label, note, actions);
  checked.addEventListener('change', () => { form.dataset.dirty = '1'; });
  note.addEventListener('input', () => { form.dataset.dirty = '1'; });
  form.addEventListener('submit', async (event) => {
    event.preventDefault(); button.disabled = true; message.textContent = 'กำลังบันทึก…';
    try {
      const request = { action: 'update', csrf: state.staffCsrf, kind, done: checked.checked, note: note.value,
        ...(kind === 'district' ? { district: row.district, needType } : { id: row.id }) };
      const response = await fetch('./floodsupport-staff.php', { method: 'POST', credentials: 'same-origin', cache: 'no-store',
        headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(request) });
      const result = await response.json();
      if (!response.ok || !result.followUp) throw new Error(result.error || 'บันทึกไม่สำเร็จ');
      if (kind === 'district') { row.followUp ||= {}; row.followUp[needType] = result.followUp; }
      else row.followUp = result.followUp;
      message.textContent = `บันทึกแล้ว ${dateLabel(result.followUp.updatedAt)}`;
      form.classList.toggle('is-done', result.followUp.done);
      delete form.dataset.dirty;
    } catch (error) { message.textContent = error.message || 'บันทึกไม่สำเร็จ'; }
    finally { button.disabled = false; }
  });
  form.classList.toggle('is-done', Boolean(saved?.done));
  return form;
}
function renderStaff() {
  const data = state.staffData; if (!data) return;
  const district = $('staffDistrict').value, kind = $('staffNeedType').value, status = $('staffStatus').value;
  const completion = $('staffCompletion').value;
  const format = (n) => Number.isFinite(n) ? n.toLocaleString('th-TH') : 'ไม่ระบุ';
  const apiHealth = data.sourceHealth?.api;
  $('staffFreshness').textContent = `Google Sheets ${dateLabel(data.lastFetchedAt)}${Date.now() - Date.parse(data.lastFetchedAt) > 15 * 60 * 1000 ? ' · ข้อมูลอาจเก่า' : ''}` +
    (apiHealth?.fetchedAt ? ` · Flood Support ${dateLabel(apiHealth.fetchedAt)}${apiHealth.fetchFailed || apiHealth.stale ? ' (ข้อมูลอาจเก่า)' : ''}` : '');
  const stats = $('staffStats'); stats.replaceChildren();
  for (const [label, value] of [['เขตที่รายงานความต้องการ', data.districtNeeds.filter((row) => row.hasNeed).length], ['ศูนย์ที่แจ้งความต้องการ', data.shelterNeeds.length], ['ศูนย์ที่ยังไม่เปิด', data.closedShelters?.length || 0], ['ศูนย์พักพิงเข้าพัก ≥80%', data.density.length]]) {
    const card = element('div', 'staff-stat'); card.append(element('strong', '', format(value)), element('span', '', label)); stats.append(card);
  }
  const districts = data.districtNeeds.filter((row) => (!district || row.district === district) &&
    (!kind || Number(row.needs[kind] || 0) > 0) &&
    (!status || (status === 'need' ? row.hasNeed : !row.hasNeed)));
  const districtRoot = $('districtNeeds'); districtRoot.replaceChildren();
  for (const row of districts) {
    const needs = Object.entries(staffTypes).filter(([key]) => Number(row.needs[key] || 0) > 0 && (!kind || kind === key) &&
      (!completion || (completion === 'done') === Boolean(row.followUp?.[key]?.done)));
    if (!needs.length && (row.hasNeed || completion)) continue;
    const card = staffCard(`เขต${row.district}${data.districtGroups?.[row.district] ? ` · ${data.districtGroups[row.district]}` : ''}`,
      [`ผู้ประสบภัย ${format(row.affectedPeople)} ราย (Google Sheets) · ${format(row.affectedFamilies)} ครอบครัว (Google Sheets)`,
        !row.hasNeed ? 'ไม่มีรายงานความต้องการ' : '', row.note ? `หมายเหตุจาก Google Sheets: ${row.note}` : '']);
    for (const [key, label] of needs) {
      const heading = element('div', 'followup-need-title', `${label} ${format(row.needs[key])}`);
      heading.append(element('span', 'staff-source-badge', row.source || 'Google Sheets'));
      card.append(heading, staffFollowup('district', row, key));
    }
    districtRoot.append(card);
  }
  if (!districtRoot.children.length) districtRoot.append(element('p', 'empty', 'ไม่พบข้อมูลตามตัวกรอง'));
  const shelters = data.shelterNeeds.filter((row) => (!district || row.district === district) && status !== 'none' &&
    (!kind || row.request.includes(staffTypes[kind])) &&
    (!completion || (completion === 'done') === Boolean(row.followUp?.done)));
  const shelterRoot = $('shelterNeeds'); shelterRoot.replaceChildren();
  if (!shelters.length) shelterRoot.append(element('p', 'empty', 'ไม่พบข้อมูลตามตัวกรอง'));
  for (const row of shelters) {
    const sheetSource = row.requestSource || 'Google Sheets';
    const card = staffCard(row.name, [`เขต${row.district}${row.subdistrict ? ` · แขวง${row.subdistrict}` : ''} · ${row.status} (${sheetSource})`,
      `ความต้องการ: ${row.request} (${sheetSource})`,
      Number.isFinite(row.capacity) || Number.isFinite(row.occupied) || Number.isFinite(row.available)
        ? `ข้อมูลศูนย์: รองรับ ${format(row.capacity)} คน (${sheetSource}) · เข้าพัก ${format(row.occupied)} คน (${sheetSource}) · คงเหลือ ${format(row.available)} คน (${sheetSource})` : '']);
    if (row.floodSupport) {
      const api = row.floodSupport;
      card.append(element('p', 'staff-source-comparison',
        `ข้อมูลศูนย์: รองรับ ${format(api.capacity)} คน (Flood Support) · เข้าพัก ${format(api.occupied)} คน (Flood Support) · คงเหลือ ${format(api.available)} คน (Flood Support) · ${api.status || 'ไม่ระบุสถานะ'} (Flood Support)`));
    }
    card.append(staffFollowup('shelter', row)); shelterRoot.append(card);
  }
  const closedRoot = $('staffClosed'); const closed = (data.closedShelters || []).filter((row) => !district || row.district === district);
  closedRoot.replaceChildren(element('h4', '', `ศูนย์ที่ยังไม่เปิด: ${closed.length} แห่ง`));
  for (const row of closed) closedRoot.append(staffCard(row.name, [`เขต${row.district}${row.subdistrict ? ` · แขวง${row.subdistrict}` : ''}`, `รองรับได้ ${format(row.capacity)} คน · ${row.status}`]));
  const densityRoot = $('staffDensity'); densityRoot.replaceChildren(element('h4', '', `ศูนย์พักพิงเข้าพักตั้งแต่ 80%: ${data.density.filter((row) => !district || row.district === district).length} แห่ง`));
  for (const row of data.density.filter((item) => !district || item.district === district)) densityRoot.append(staffCard(row.name, [`เขต${row.district} · เข้าพัก ${format(row.occupied)} / ${format(row.capacity)} คน (${Math.round(row.ratio * 100)}%)`]));
  const declarationRoot = $('staffDeclarations'); declarationRoot.replaceChildren(element('h4', '', 'สถานะประกาศพื้นที่'));
  for (const row of data.declarations.filter((item) => !district || item.district === district)) declarationRoot.append(staffCard(`เขต${row.district} · แขวง${row.subdistrict}`, [row.declarationStatus, row.submissionStatus]));
}
async function loadStaff(pin = null) {
  if (pin === null && state.staffData && document.querySelector('.followup-form[data-dirty="1"]')) {
    $('staffFreshness').textContent = 'มีรายการที่ยังไม่บันทึก กรุณาบันทึกก่อนรีเฟรชข้อมูล';
    return;
  }
  try {
    const response = await fetch('./floodsupport-staff.php', { method: pin === null ? 'GET' : 'POST',
      headers: pin === null ? {} : { 'Content-Type': 'application/json' },
      body: pin === null ? undefined : JSON.stringify({ action: 'login', pin }), credentials: 'same-origin', cache: 'no-store' });
    const result = await response.json();
    if (!response.ok || !result.authenticated || !result.data) throw new Error(result.error || 'กรุณาเข้าสู่ระบบ');
    state.staffData = result.data; state.staffCsrf = result.csrf;
    $('staffLogin').hidden = true; $('staffDashboard').hidden = false; $('staffLogout').hidden = false;
    $('staffPin').value = ''; $('staffLoginMessage').textContent = '';
    const select = $('staffDistrict'); const selected = select.value;
    select.replaceChildren(element('option', '', 'ทุกเขต')); select.firstChild.value = '';
    for (const district of result.data.districts) { const option = element('option', '', district); option.value = district; select.append(option); }
    select.value = result.data.districts.includes(selected) ? selected : '';
    renderStaff();
  } catch (error) {
    state.staffData = null; state.staffCsrf = null; $('staffLogin').hidden = false; $('staffDashboard').hidden = true; $('staffLogout').hidden = true;
    $('staffLoginMessage').textContent = pin === null && error.message === 'กรุณาเข้าสู่ระบบ' ? '' : error.message;
  }
}
function showView(view) {
  state.view = view;
  $('publicView').hidden = view !== 'public'; $('staffView').hidden = view !== 'staff';
  $('publicTab').classList.toggle('active', view === 'public'); $('staffTab').classList.toggle('active', view === 'staff');
  $('publicTab').setAttribute('aria-current', view === 'public' ? 'page' : 'false');
  $('staffTab').setAttribute('aria-current', view === 'staff' ? 'page' : 'false');
  if (view === 'staff') void loadStaff();
  else if (map) setTimeout(() => google.maps.event.trigger(map, 'resize'), 100);
}
$('publicTab').addEventListener('click', () => showView('public'));
$('staffTab').addEventListener('click', () => showView('staff'));
$('staffLogin').addEventListener('submit', (event) => { event.preventDefault(); void loadStaff($('staffPin').value); });
$('staffLogout').addEventListener('click', async () => {
  await fetch('./floodsupport-staff.php', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ action: 'logout' }), credentials: 'same-origin' });
  state.staffData = null; state.staffCsrf = null; $('staffDashboard').hidden = true; $('staffLogin').hidden = false; $('staffLogout').hidden = true;
});
$('staffRefresh').addEventListener('click', () => void loadStaff());
for (const id of ['staffDistrict', 'staffNeedType', 'staffStatus', 'staffCompletion']) $(id).addEventListener('change', renderStaff);
for (const [key, label] of Object.entries(staffTypes)) { const option = element('option', '', label); option.value = key; $('staffNeedType').append(option); }
setInterval(() => { if (document.visibilityState === 'visible') { void loadData(); if (state.view === 'staff') void loadStaff(); } }, 5 * 60 * 1000);
document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'visible') { void loadData(); if (state.view === 'staff') void loadStaff(); } });
void initGoogleMap();
void loadData();
