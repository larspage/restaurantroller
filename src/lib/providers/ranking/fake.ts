import type { Restaurant } from '@/lib/types'
import type { RankingProvider } from './types'

export class FakeRanker implements RankingProvider {
  rank(restaurants: Restaurant[], _lat: number, _lng: number): Restaurant[] {
    return [...restaurants]
  }
}
