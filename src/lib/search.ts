import { logger } from '@/lib/logger'
import { clampRadius, midpoint } from '@/lib/geo'
import { metrics } from '@/lib/metrics'
import type { Restaurant, SearchParams, BetweenParams, SearchResult } from '@/lib/types'
import { SearchError } from '@/lib/types'

async function getProvider() {
  const { getPlacesProvider } = await import('@/lib/providers/places')
  return getPlacesProvider()
}

async function getRanker() {
  const { getRankingProvider } = await import('@/lib/providers/ranking')
  return getRankingProvider()
}

export async function searchNearby(params: SearchParams): Promise<SearchResult> {
  const start = Date.now()
  metrics.incRequest()

  if (params.radiusMeters != null) {
    params.radiusMeters = clampRadius(params.radiusMeters)
  }

  logger.info('searchNearby', { lat: params.lat, lng: params.lng, radiusMeters: params.radiusMeters })

  try {
    const provider = await getProvider()
    const restaurants = await provider.searchNearby(params)

    const ranker = await getRanker()
    const ranked = ranker.rank(restaurants, params.lat, params.lng)

    const latency = Date.now() - start
    metrics.recordLatency(latency)
    metrics.recordUpstreamOutcome('success')

    logger.info('searchNearby complete', { count: ranked.length, latencyMs: latency })

    return { restaurants: ranked, total: ranked.length }
  } catch (err) {
    const latency = Date.now() - start
    metrics.recordLatency(latency)
    metrics.recordUpstreamOutcome('error')
    metrics.incError()

    if (err instanceof SearchError) {
      logger.warn('searchNearby failed', { code: err.code, message: err.message })
      throw err
    }

    logger.error('searchNearby unexpected error', { error: String(err) })
    throw new SearchError('provider_unavailable', 'Unexpected search error')
  }
}

export async function searchBetween(params: BetweenParams): Promise<SearchResult> {
  const center = midpoint(
    { lat: params.lat1, lng: params.lng1 },
    { lat: params.lat2, lng: params.lng2 },
  )

  const clampedRadius = clampRadius(params.radiusMeters)
  logger.info('searchBetween', {
    midpoint: center,
    radiusMeters: clampedRadius,
  })

  return searchNearby({
    lat: center.lat,
    lng: center.lng,
    radiusMeters: clampedRadius,
  })
}

export async function searchWithGeocode(
  query: string,
  radiusMeters: number,
): Promise<SearchResult> {
  const provider = await getProvider()
  const coords = await provider.geocode(query)

  if (!coords) {
    throw new SearchError('geocode_failed', `Could not geocode: ${query}`)
  }

  return searchNearby({ lat: coords.lat, lng: coords.lng, radiusMeters })
}

export async function checkProviderHealth(): Promise<boolean> {
  try {
    const provider = await getProvider()
    return provider.isReachable()
  } catch {
    return false
  }
}
