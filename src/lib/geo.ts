import type { Coordinates } from './types'

const EARTH_RADIUS_M = 6_371_000

function toRad(deg: number): number {
  return (deg * Math.PI) / 180
}

function toDeg(rad: number): number {
  return (rad * 180) / Math.PI
}

export function haversineDistance(a: Coordinates, b: Coordinates): number {
  const dLat = toRad(b.lat - a.lat)
  const dLng = toRad(b.lng - a.lng)
  const sinDLat = Math.sin(dLat / 2)
  const sinDLng = Math.sin(dLng / 2)
  const h =
    sinDLat * sinDLat +
    Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * sinDLng * sinDLng
  return 2 * EARTH_RADIUS_M * Math.asin(Math.sqrt(h))
}

export function midpoint(a: Coordinates, b: Coordinates): Coordinates {
  const dLng = toRad(b.lng - a.lng)
  const lat1 = toRad(a.lat)
  const lat2 = toRad(b.lat)
  const lng1 = toRad(a.lng)

  const bx = Math.cos(lat2) * Math.cos(dLng)
  const by = Math.cos(lat2) * Math.sin(dLng)

  return {
    lat: toDeg(Math.atan2(
      Math.sin(lat1) + Math.sin(lat2),
      Math.sqrt((Math.cos(lat1) + bx) ** 2 + by * by),
    )),
    lng: toDeg(lng1 + Math.atan2(by, Math.cos(lat1) + bx)),
  }
}

export function clampRadius(radius: number): number {
  return Math.max(100, Math.min(radius, 20_000))
}
