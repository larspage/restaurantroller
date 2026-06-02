import { describe, it, expect } from 'vitest'
import { haversineDistance, midpoint, clampRadius } from './geo'

describe('haversineDistance', () => {
  it('returns 0 for same point', () => {
    const p = { lat: 40.7128, lng: -74.006 }
    expect(haversineDistance(p, p)).toBeCloseTo(0, 0)
  })

  it('calculates NY to LA approximately 3944 km', () => {
    const ny = { lat: 40.7128, lng: -74.006 }
    const la = { lat: 34.0522, lng: -118.2437 }
    const dist = haversineDistance(ny, la)
    expect(dist).toBeGreaterThan(3_900_000)
    expect(dist).toBeLessThan(4_000_000)
  })

  it('calculates a small distance correctly', () => {
    const a = { lat: 40.7128, lng: -74.006 }
    const b = { lat: 40.7138, lng: -74.007 }
    const dist = haversineDistance(a, b)
    expect(dist).toBeGreaterThan(100)
    expect(dist).toBeLessThan(200)
  })
})

describe('midpoint', () => {
  it('returns the midpoint between two points', () => {
    const ny = { lat: 40.7128, lng: -74.006 }
    const la = { lat: 34.0522, lng: -118.2437 }
    const mid = midpoint(ny, la)

    expect(mid.lat).toBeGreaterThan(34)
    expect(mid.lat).toBeLessThan(41)
    expect(mid.lng).toBeGreaterThan(-119)
    expect(mid.lng).toBeLessThan(-74)
  })

  it('returns the same point when both inputs are the same', () => {
    const p = { lat: 40.7128, lng: -74.006 }
    const mid = midpoint(p, p)
    expect(mid.lat).toBeCloseTo(p.lat, 4)
    expect(mid.lng).toBeCloseTo(p.lng, 4)
  })
})

describe('clampRadius', () => {
  it('clamps below 100 to 100', () => {
    expect(clampRadius(10)).toBe(100)
  })

  it('clamps above 20000 to 20000', () => {
    expect(clampRadius(50000)).toBe(20000)
  })

  it('keeps values in range', () => {
    expect(clampRadius(1000)).toBe(1000)
    expect(clampRadius(100)).toBe(100)
    expect(clampRadius(20000)).toBe(20000)
  })
})
