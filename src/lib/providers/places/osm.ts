import { logger } from '@/lib/logger'
import { SearchError } from '@/lib/types'
import type { Coordinates, Restaurant, SearchParams } from '@/lib/types'
import type { PlacesProvider } from './types'

const OVERPASS_URL =
  process.env.OVERPASS_URL || 'https://overpass-api.de/api/interpreter'

const USER_AGENT = 'Eats/0.1 (restaurant-finder; contact@example.com)'

interface OverpassNode {
  type: string
  id: number
  lat: number
  lon: number
  tags?: Record<string, string>
}

interface OverpassElement extends OverpassNode {
  center?: { lat: number; lon: number }
  nodes?: number[]
  members?: OverpassElement[]
}

interface OverpassResponse {
  elements: OverpassElement[]
}

function buildNearbyQuery(params: SearchParams): string {
  const { lat, lng, radiusMeters } = params
  return `[out:json][timeout:15];
(
  node["amenity"="restaurant"](around:${radiusMeters},${lat},${lng});
  way["amenity"="restaurant"](around:${radiusMeters},${lat},${lng});
);
out center tags ${Math.min(50, 50)};`
}

function buildGeocodeQuery(query: string): string {
  const escaped = query.replace(/"/g, '\\"')
  return `[out:json][timeout:10];
(
  node["place"~"city|town|village|suburb"]["name"="${escaped}"];
  way["place"~"city|town|village|suburb"]["name"="${escaped}"];
);
out center 1;`
}

function toRestaurant(el: OverpassElement): Restaurant | null {
  const tags = el.tags ?? {}
  const lat = el.lat ?? el.center?.lat
  const lng = el.lon ?? el.center?.lon
  if (lat == null || lng == null) return null

  return {
    id: `osm:${el.type}/${el.id}`,
    name: tags.name || 'Unknown',
    coordinates: { lat, lng },
    address: [tags['addr:street'], tags['addr:housenumber']]
      .filter(Boolean)
      .join(' ') || tags['addr:city'] || '',
    cuisine: tags.cuisine ?? null,
    phone: tags.phone ?? null,
    website: tags.website ?? null,
    rating: tags.rating ? parseFloat(tags.rating) : null,
    priceLevel: null,
    openNow: null,
    openingHours: tags.opening_hours ?? null,
    photoReference: null,
  }
}

export class OSMProvider implements PlacesProvider {
  async searchNearby(params: SearchParams): Promise<Restaurant[]> {
    const query = buildNearbyQuery(params)
    logger.debug('osm searchNearby', { radiusMeters: params.radiusMeters, lat: params.lat, lng: params.lng })

    let data: OverpassResponse
    try {
      const res = await fetch(OVERPASS_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': USER_AGENT,
        },
        body: new URLSearchParams({ data: query }),
        signal: AbortSignal.timeout(15_000),
      })

      if (!res.ok) {
        throw new SearchError('provider_unavailable', `Overpass returned ${res.status}`)
      }

      data = await res.json()
    } catch (err) {
      if (err instanceof SearchError) throw err
      logger.error('osm request failed', { error: String(err) })
      throw new SearchError('provider_unavailable', 'Overpass request failed')
    }

    const restaurants: Restaurant[] = []
    for (const el of data.elements) {
      const r = toRestaurant(el)
      if (r) restaurants.push(r)
    }

    logger.info('osm searchNearby results', { count: restaurants.length })
    return restaurants
  }

  async geocode(query: string): Promise<Coordinates | null> {
    const overpassQuery = buildGeocodeQuery(query)
    logger.debug('osm geocode', { query })

    try {
      const res = await fetch(OVERPASS_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': USER_AGENT,
        },
        body: new URLSearchParams({ data: overpassQuery }),
        signal: AbortSignal.timeout(10_000),
      })

      if (!res.ok) return null

      const data: OverpassResponse = await res.json()
      const el = data.elements?.[0]
      if (!el) return null

      const lat = el.lat ?? el.center?.lat
      const lng = el.lon ?? el.center?.lon
      if (lat == null || lng == null) return null

      return { lat, lng }
    } catch {
      logger.error('osm geocode failed', { query })
      return null
    }
  }

  async isReachable(): Promise<boolean> {
    try {
      const res = await fetch(OVERPASS_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': USER_AGENT,
        },
        body: new URLSearchParams({ data: '[out:json];node(0);out 0;' }),
        signal: AbortSignal.timeout(5_000),
      })
      return res.ok
    } catch {
      return false
    }
  }
}
