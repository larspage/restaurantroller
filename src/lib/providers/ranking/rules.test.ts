import { describe, it, expect } from 'vitest'
import { RulesRanker } from './rules'
import type { Restaurant } from '@/lib/types'

describe('RulesRanker', () => {
  const ranker = new RulesRanker()

  function makeRestaurant(overrides: Partial<Restaurant>): Restaurant {
    return {
      id: 'osm:node/test',
      name: 'Test',
      coordinates: { lat: 40.7128, lng: -74.006 },
      address: '123 Test St',
      rating: 3.0,
      openNow: null,
      ...overrides,
    }
  }

  it('returns restaurants in score order', () => {
    const restaurants = [
      makeRestaurant({ id: 'osm:node/1', name: 'High Rated', rating: 5.0, coordinates: { lat: 40.7129, lng: -74.006 } }),
      makeRestaurant({ id: 'osm:node/2', name: 'Low Rated', rating: 1.0, coordinates: { lat: 40.7129, lng: -74.006 } }),
    ]

    const ranked = ranker.rank(restaurants, 40.7128, -74.006)
    expect(ranked[0].name).toBe('High Rated')
    expect(ranked[1].name).toBe('Low Rated')
  })

  it('prefers open restaurants at similar distance', () => {
    const restaurants = [
      makeRestaurant({ id: 'osm:node/1', name: 'Closed High Rated', openNow: false, rating: 5.0, coordinates: { lat: 40.713, lng: -74.006 } }),
      makeRestaurant({ id: 'osm:node/2', name: 'Open', openNow: true, rating: 4.0, coordinates: { lat: 40.7129, lng: -74.006 } }),
    ]

    const ranked = ranker.rank(restaurants, 40.7128, -74.006)
    expect(ranked[0].name).toBe('Open')
  })

  it('handles null rating gracefully', () => {
    const restaurants = [
      makeRestaurant({ id: 'osm:node/1', name: 'No Rating', rating: null }),
    ]

    const ranked = ranker.rank(restaurants, 40.7128, -74.006)
    expect(ranked.length).toBe(1)
    expect(ranked[0].name).toBe('No Rating')
  })
})
