import { NextResponse } from 'next/server'
import { logger } from '@/lib/logger'
import { checkProviderHealth } from '@/lib/search'

export const dynamic = 'force-dynamic'

export async function GET() {
  logger.debug('readyz check')

  let upstreamOk = false
  try {
    upstreamOk = await checkProviderHealth()
  } catch {
    upstreamOk = false
  }

  if (!upstreamOk) {
    logger.warn('readyz failed — upstream unreachable')
    return NextResponse.json(
      { status: 'unhealthy', service: 'eats', upstream: 'unreachable' },
      { status: 503 },
    )
  }

  return NextResponse.json(
    { status: 'ok', service: 'eats', upstream: 'reachable' },
    { status: 200 },
  )
}
