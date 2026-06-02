import { logger } from '@/lib/logger'
import type { RankingProvider } from './types'

let provider: RankingProvider | null = null

export async function getRankingProvider(): Promise<RankingProvider> {
  if (provider) return provider

  const providerName = process.env.RANKING_PROVIDER || 'rules'

  switch (providerName) {
    case 'rules':
      const { RulesRanker } = await import('./rules')
      provider = new RulesRanker()
      logger.info('ranking provider initialized', { provider: 'rules' })
      return provider
    case 'fake':
      const { FakeRanker } = await import('./fake')
      provider = new FakeRanker()
      logger.info('ranking provider initialized', { provider: 'fake' })
      return provider
    default:
      throw new Error(`Unknown ranking provider: ${providerName}`)
  }
}

export function resetProviderForTest(): void {
  provider = null
}

export type { RankingProvider } from './types'
