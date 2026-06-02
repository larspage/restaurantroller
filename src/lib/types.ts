export interface Coordinates {
  lat: number
  lng: number
}

export interface Restaurant {
  id: string
  name: string
  coordinates: Coordinates
  address: string
  cuisine?: string | null
  phone?: string | null
  website?: string | null
  rating?: number | null
  priceLevel?: number | null
  openNow: boolean | null
  openingHours?: string | null
  photoReference?: string | null
}

export interface SearchParams {
  lat: number
  lng: number
  radiusMeters: number
  query?: string
}

export interface BetweenParams {
  lat1: number
  lng1: number
  lat2: number
  lng2: number
  radiusMeters: number
}

export interface SearchResult {
  restaurants: Restaurant[]
  total: number
}

export type SearchErrorCode =
  | 'location_unavailable'
  | 'geocode_failed'
  | 'provider_unavailable'
  | 'bad_request'
  | 'no_results'

export class SearchError extends Error {
  code: SearchErrorCode

  constructor(code: SearchErrorCode, message: string) {
    super(message)
    this.name = 'SearchError'
    this.code = code
  }
}
