export function distanceKm(a, b) {
  const rad = Math.PI / 180;
  const dLat = (a.lat - b.lat) * rad;
  const dLon = (a.lng - b.lng) * rad;
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(a.lat * rad) * Math.cos(b.lat * rad) * Math.sin(dLon / 2) ** 2;
  return 6371.0088 * 2 * Math.asin(Math.min(1, Math.sqrt(h)));
}

function onSegment(point, a, b) {
  const cross = (point[0] - a[0]) * (b[1] - a[1]) - (point[1] - a[1]) * (b[0] - a[0]);
  if (Math.abs(cross) > 1e-9) return false;
  return point[0] >= Math.min(a[0], b[0]) - 1e-9 && point[0] <= Math.max(a[0], b[0]) + 1e-9 &&
    point[1] >= Math.min(a[1], b[1]) - 1e-9 && point[1] <= Math.max(a[1], b[1]) + 1e-9;
}

function inRing(point, ring) {
  let inside = false;
  for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    const a = ring[i], b = ring[j];
    if (onSegment(point, a, b)) return true;
    if ((a[1] > point[1]) !== (b[1] > point[1]) &&
        point[0] < (b[0] - a[0]) * (point[1] - a[1]) / (b[1] - a[1]) + a[0]) inside = !inside;
  }
  return inside;
}

function polygons(geometry) {
  return geometry.type === 'Polygon' ? [geometry.coordinates] :
    geometry.type === 'MultiPolygon' ? geometry.coordinates : [];
}

export function pointInFeature(point, feature) {
  const xy = [point.lng, point.lat];
  return polygons(feature.geometry).some((polygon) => inRing(xy, polygon[0]) && !polygon.slice(1).some((hole) => inRing(xy, hole)));
}

function segmentDistanceKm(center, a, b) {
  const scaleX = 111.195 * Math.cos(center.lat * Math.PI / 180);
  const scaleY = 111.195;
  const ax = (a[0] - center.lng) * scaleX, ay = (a[1] - center.lat) * scaleY;
  const bx = (b[0] - center.lng) * scaleX, by = (b[1] - center.lat) * scaleY;
  const dx = bx - ax, dy = by - ay;
  const t = dx * dx + dy * dy ? Math.max(0, Math.min(1, -(ax * dx + ay * dy) / (dx * dx + dy * dy))) : 0;
  return Math.hypot(ax + t * dx, ay + t * dy);
}

export function circleIntersectsFeature(center, radiusKm, feature) {
  if (pointInFeature(center, feature)) return true;
  return polygons(feature.geometry).some((polygon) => polygon.some((ring) =>
    ring.some((vertex, i) => segmentDistanceKm(center, vertex, ring[(i + 1) % ring.length]) <= radiusKm)));
}
