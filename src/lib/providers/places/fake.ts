import type { Coordinates, Restaurant, SearchParams } from '@/lib/types'
import type { PlacesProvider } from './types'

export class FakePlacesProvider implements PlacesProvider {
  private restaurants: Restaurant[]

  constructor(restaurants?: Restaurant[]) {
    this.restaurants = restaurants ?? [
      {
        id: 'osm:node/1',
        name: 'Test Pizza',
        coordinates: { lat: 40.7128, lng: -74.006 },
        address: '123 Pizza St',
        cuisine: 'pizza',
        phone: '+1-555-0100',
        rating: 4.5,
        openNow: true,
        openingHours: 'Mo-Su 11:00-22:00',
      },
      {
        id: 'osm:node/2',
        name: 'Test Burger',
        coordinates: { lat: 40.7138, lng: -74.007 },
        address: '456 Burger Ave',
        cuisine: 'burger',
        phone: '+1-555-0101',
        rating: 4.0,
        openNow: null,
        openingHours: null,
      },
      {
        id: 'osm:node/3',
        name: 'Test Closed Ramen',
        coordinates: { lat: 40.7148, lng: -74.008 },
        address: '789 Ramen Blvd',
        cuisine: 'ramen',
        phone: '+1-555-0102',
        rating: 3.5,
        openNow: false,
        openingHours: 'Mo-Fr 09:00-17:00',
      },
      {
        id: 'osm:node/4',
        name: 'No Rating Cafe',
        coordinates: { lat: 40.7118, lng: -74.005 },
        address: '321 Cafe Ln',
        cuisine: 'cafe',
        phone: null,
        rating: null,
        openNow: null,
        openingHours: null,
      },
    ]
  }

  async geocode(query: string): Promise<Coordinates | null> {
    if (query.toLowerCase().includes('unknown')) return null
    return { lat: 40.7128, lng: -74.006 }
  }

  async searchNearby(_params: SearchParams): Promise<Restaurant[]> {
    return this.restaurants
  }

  async isReachable(): Promise<boolean> {
    return true
  }
}
