import { NextRequest, NextResponse } from 'next/server'
import { logger } from '@/lib/logger'
import type { LogLevel } from '@/lib/logger'

export const dynamic = 'force-dynamic'

export async function GET() {
  return NextResponse.json({ level: logger.getLevel() })
}

export async function POST(request: NextRequest) {
  const validLevels = ['debug', 'info', 'warn', 'error']

  try {
    const body = await request.json()
    const { level } = body as { level: string }

    if (!level || !validLevels.includes(level)) {
      return NextResponse.json(
        { error: `Invalid level. Valid: ${validLevels.join(', ')}` },
        { status: 400 },
      )
    }

    const previous = logger.getLevel()
    logger.setLevel(level as LogLevel)
    logger.info('log level changed', { from: previous, to: level })

    return NextResponse.json({ previous, current: level })
  } catch {
    return NextResponse.json(
      { error: 'Invalid JSON body. Send {"level": "debug"}' },
      { status: 400 },
    )
  }
}
