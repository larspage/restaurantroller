import { NextResponse } from 'next/server'
import { logger } from '@/lib/logger'

export const dynamic = 'force-dynamic'

export async function GET() {
  logger.debug('healthz check')
  return NextResponse.json({ status: 'ok', service: 'eats' }, { status: 200 })
}
