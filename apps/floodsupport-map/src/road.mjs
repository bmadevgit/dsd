export const ROAD_COLORS = { flooding: '#c7392f', minor_flood: '#e28a22', normal: '#43849b', unavailable: '#82949d' };

export function isRoadSensorVisible(sensor, nowMs = Date.now()) {
  return roadState(sensor, nowMs) !== 'unavailable';
}

export function roadState(sensor, nowMs = Date.now()) {
  if (!sensor || !['flooding', 'minor_flood', 'normal'].includes(sensor.status)) return 'unavailable';
  const observed = Date.parse(sensor.observedAt);
  if (!Number.isFinite(observed) || nowMs - observed > 60 * 60 * 1000 || observed - nowMs > 5 * 60 * 1000) return 'unavailable';
  if (!Number.isFinite(sensor.valueCm) || sensor.valueCm < 0) return 'unavailable';
  return sensor.status;
}
