import { haversineDistance } from '@/lib/geo'
import type { Restaurant } from '@/lib/types'
import type { RankingProvider } from './types'

export class RulesRanker implements RankingProvider {
  rank(restaurants: Restaurant[], lat: number, lng: number): Restaurant[] {
    const scored = restaurants.map((r) => {
      const distance = haversineDistance(r.coordinates, { lat, lng })
      const rating = r.rating ?? 3.0
      const openBonus = r.openNow === true ? 1.2 : r.openNow === false ? 0.8 : 1.0
      const score = (rating / 5) * (1 / Math.max(distance, 1)) * openBonus
      return { restaurant: r, distance, score }
    })

    scored.sort((a, b) => b.score - a.score)

    return scored.map((s) => s.restaurant)
  }
}
