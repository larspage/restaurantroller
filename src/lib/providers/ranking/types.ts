import type { Restaurant } from '@/lib/types'

export interface RankingProvider {
  rank(restaurants: Restaurant[], lat: number, lng: number): Restaurant[]
}
