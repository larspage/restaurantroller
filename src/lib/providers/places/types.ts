import type { Coordinates, Restaurant, SearchParams } from '@/lib/types'

export interface PlacesProvider {
  geocode(query: string): Promise<Coordinates | null>
  searchNearby(params: SearchParams): Promise<Restaurant[]>
  isReachable(): Promise<boolean>
}
