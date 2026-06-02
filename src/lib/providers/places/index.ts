import { logger } from '@/lib/logger'
import type { PlacesProvider } from './types'

let provider: PlacesProvider | null = null

export async function getPlacesProvider(): Promise<PlacesProvider> {
  if (provider) return provider

  const providerName = process.env.PLACES_PROVIDER || 'osm'

  switch (providerName) {
    case 'osm':
      const { OSMProvider } = await import('./osm')
      provider = new OSMProvider()
      logger.info('places provider initialized', { provider: 'osm' })
      return provider
    case 'fake':
      const { FakePlacesProvider } = await import('./fake')
      provider = new FakePlacesProvider()
      logger.info('places provider initialized', { provider: 'fake' })
      return provider
    default:
      throw new Error(`Unknown places provider: ${providerName}`)
  }
}

export function resetProviderForTest(): void {
  provider = null
}

export type { PlacesProvider } from './types'
