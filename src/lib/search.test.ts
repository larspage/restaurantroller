import { describe, it, expect, beforeEach } from 'vitest'
import { searchNearby, searchBetween, checkProviderHealth } from './search'
import { SearchError } from './types'
import { resetProviderForTest as resetPlacesProvider } from './providers/places'
import { resetProviderForTest as resetRankingProvider } from './providers/ranking'

describe('searchNearby', () => {
  beforeEach(() => {
    resetPlacesProvider()
    resetRankingProvider()
    process.env.PLACES_PROVIDER = 'fake'
    process.env.RANKING_PROVIDER = 'fake'
  })

  it('returns restaurants for valid coordinates', async () => {
    const result = await searchNearby({
      lat: 40.7128,
      lng: -74.006,
      radiusMeters: 1000,
    })

    expect(result.total).toBeGreaterThan(0)
    expect(result.restaurants.length).toBeGreaterThan(0)
  })

  it('clamps radius to valid range', async () => {
    const result = await searchNearby({
      lat: 40.7128,
      lng: -74.006,
      radiusMeters: 99999,
    })
    expect(result.restaurants.length).toBeGreaterThan(0)
  })
})

describe('searchBetween', () => {
  beforeEach(() => {
    resetPlacesProvider()
    resetRankingProvider()
    process.env.PLACES_PROVIDER = 'fake'
    process.env.RANKING_PROVIDER = 'fake'
  })

  it('returns restaurants for between-two-locations', async () => {
    const result = await searchBetween({
      lat1: 40.7128,
      lng1: -74.006,
      lat2: 40.758,
      lng2: -73.9855,
      radiusMeters: 1000,
    })

    expect(result.total).toBeGreaterThan(0)
    expect(result.restaurants.length).toBeGreaterThan(0)
  })
})

describe('checkProviderHealth', () => {
  beforeEach(() => {
    resetPlacesProvider()
    process.env.PLACES_PROVIDER = 'fake'
  })

  it('returns true when using fake provider', async () => {
    const healthy = await checkProviderHealth()
    expect(healthy).toBe(true)
  })
})
