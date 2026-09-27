import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { circleIntersectsFeature, distanceKm, pointInFeature } from './src/geo.mjs';
import { isRoadSensorVisible, roadState } from './src/road.mjs';
import { canalState, isCanalStationVisible } from './src/canal.mjs';

const square = { type: 'Feature', geometry: { type: 'Polygon', coordinates: [[[100, 13], [100.1, 13], [100.1, 13.1], [100, 13.1], [100, 13]]] } };

test('point and circle geometry includes interior and shared boundary', () => {
  assert.equal(pointInFeature({ lat: 13.05, lng: 100.05 }, square), true);
  assert.equal(pointInFeature({ lat: 13, lng: 100.05 }, square), true);
  assert.equal(pointInFeature({ lat: 13.2, lng: 100.05 }, square), false);
  assert.equal(circleIntersectsFeature({ lat: 13.11, lng: 100.05 }, 2, square), true);
  assert.equal(circleIntersectsFeature({ lat: 13.2, lng: 100.05 }, 2, square), false);
});

test('real boundaries map all 50 district codes to nowcast and shelter pins', () => {
  const geo = JSON.parse(readFileSync(new URL('../../wwwroot/now/districts.geojson', import.meta.url)));
  const nowcast = JSON.parse(readFileSync(new URL('../../wwwroot/now/nowcast-data.json', import.meta.url)));
  const shelters = JSON.parse(readFileSync(new URL('../../wwwroot/now/floodsupport-data.json', import.meta.url)));
  assert.equal(geo.features.length, 50);
  assert.equal(new Set(geo.features.map((feature) => feature.properties.districtCode)).size, 50);
  assert.ok(geo.features.every((feature) => nowcast.payload.districts[feature.properties.districtCode]));
  const mapped = shelters.facilities.filter((row) => row.category === 'ศูนย์พักพิงชั่วคราว' && row.location);
  const matched = mapped.filter((row) => geo.features.some((feature) => pointInFeature({ lat: row.location.lat, lng: row.location.lon }, feature)));
  assert.ok(matched.length >= mapped.length * .95, `${matched.length}/${mapped.length} mapped shelter pins inside Bangkok districts`);
  const origin = { lat: 13.7563, lng: 100.5018 };
  const nearby = mapped.map((row) => ({ row, km: distanceKm(origin, { lat: row.location.lat, lng: row.location.lon }) }))
    .filter((item) => item.km <= 10).sort((a, b) => a.km - b.km);
  assert.ok(nearby.length > 0);
  assert.ok(nearby.every((item) => item.km <= 10));
  assert.ok(nearby.every((item, index) => index === 0 || nearby[index - 1].km <= item.km));
});

test('road sensor status rejects malfunction and stale readings', () => {
  const now = Date.parse('2026-09-27T10:00:00Z');
  const reading = { status: 'flooding', valueCm: 12, observedAt: '2026-09-27T09:40:00Z' };
  assert.equal(roadState(reading, now), 'flooding');
  assert.equal(roadState({ ...reading, status: 'temporary_malfunction' }, now), 'unavailable');
  assert.equal(roadState({ ...reading, status: 'normal', observedAt: '2026-09-27T08:00:00Z' }, now), 'unavailable');
  assert.equal(roadState({ ...reading, valueCm: null }, now), 'unavailable');
  assert.equal(isRoadSensorVisible(reading, now), true);
  assert.equal(isRoadSensorVisible({ ...reading, status: 'malfunction' }, now), false);
  assert.equal(isRoadSensorVisible({ ...reading, status: 'temporary_malfunction' }, now), false);
  assert.equal(isRoadSensorVisible({ ...reading, status: 'normal', observedAt: '2026-09-27T08:00:00Z' }, now), false);
  assert.equal(isRoadSensorVisible({ ...reading, valueCm: null }, now), false);
  const snapshot = JSON.parse(readFileSync(new URL('../../wwwroot/now/road-flood-data.json', import.meta.url)));
  assert.equal(snapshot.sensors.length, snapshot.total);
  assert.ok(snapshot.sensors.every((sensor) => Number.isFinite(sensor.lat) && Number.isFinite(sensor.lon)));
  assert.ok(snapshot.sensors.every((sensor) => !('sensor_profile' in sensor) && !('KeyId' in sensor)));
});

test('all CCTV flood reports have unique coordinates inside Bangkok and support radius filtering', () => {
  const geo = JSON.parse(readFileSync(new URL('../../wwwroot/now/districts.geojson', import.meta.url)));
  const cctv = JSON.parse(readFileSync(new URL('./data/cctv-flood-data.json', import.meta.url)));
  assert.equal(cctv.locations.length, 28);
  assert.equal(new Set(cctv.locations.map((row) => row.id)).size, 28);
  assert.ok(cctv.locations.every((row) => Number.isFinite(row.lat) && Number.isFinite(row.lng)));
  assert.ok(cctv.locations.every((row) => ['high', 'minor', 'reported'].includes(row.severity)));
  assert.ok(cctv.locations.every((row) => geo.features.some((feature) => pointInFeature(row, feature))), 'CCTV representative pins must be inside Bangkok');
  const origin = { lat: 13.7663637, lng: 100.6478851 };
  const nearby = cctv.locations.map((row) => ({ row, km: distanceKm(origin, row) })).filter((item) => item.km <= 3);
  assert.ok(nearby.some((item) => item.row.id === 'cctv-19'));
  assert.ok(nearby.every((item) => item.km <= 3));
});

test('canal readings hide malfunctioning stations and reject stale values', () => {
  const now = Date.parse('2026-09-27T12:00:00Z');
  const reading = { status: 'วิกฤต', levelM: 0.83, observedAt: '2026-09-27T18:45:00+07:00' };
  assert.equal(isCanalStationVisible(reading), true);
  assert.equal(canalState(reading, now), 'critical');
  assert.equal(canalState({ ...reading, status: 'เตือนภัย' }, now), 'warning');
  assert.equal(isCanalStationVisible({ ...reading, status: 'ขัดข้อง' }), false);
  assert.equal(canalState({ ...reading, observedAt: '2026-09-27T09:00:00+07:00' }, now), 'unavailable');
  const snapshot = JSON.parse(readFileSync(new URL('../../wwwroot/now/canal-water-data.json', import.meta.url)));
  assert.equal(snapshot.stations.length, snapshot.mappedTotal);
  assert.ok(snapshot.stations.length >= 200);
  assert.ok(snapshot.stations.every((station) => Number.isFinite(station.lat) && Number.isFinite(station.lng)));
  assert.ok(snapshot.stations.every((station) => typeof station.name === 'string' && typeof station.river === 'string'));
  assert.ok(snapshot.stations.every((station) => !('pumpdata' in station) && !('gatedata' in station) && !('KeyId' in station)));
  const origin = { lat: 13.7563, lng: 100.5018 };
  const nearby = snapshot.stations.filter(isCanalStationVisible)
    .map((station) => ({ station, km: distanceKm(origin, station) }))
    .filter((item) => item.km <= 10).sort((a, b) => a.km - b.km);
  assert.ok(nearby.length > 0);
  assert.ok(nearby.every((item, index) => index === 0 || nearby[index - 1].km <= item.km));
});
