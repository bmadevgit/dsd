export const CANAL_COLORS = { critical: '#b82f29', warning: '#d67a18', normal: '#397f96', unavailable: '#82949d' };

export function isCanalStationVisible(station) {
  return !!station && station.status !== 'ขัดข้อง';
}

export function canalState(station, nowMs = Date.now()) {
  if (!isCanalStationVisible(station)) return 'unavailable';
  const observed = Date.parse(station.observedAt);
  if (!Number.isFinite(observed) || nowMs - observed > 60 * 60 * 1000 || observed - nowMs > 5 * 60 * 1000) return 'unavailable';
  if (!Number.isFinite(station.levelM)) return 'unavailable';
  if (station.status === 'วิกฤต') return 'critical';
  if (station.status === 'เตือนภัย') return 'warning';
  return station.status === 'ปกติ' ? 'normal' : 'unavailable';
}
