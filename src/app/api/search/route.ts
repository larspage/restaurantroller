import { NextRequest, NextResponse } from 'next/server'
import { logger } from '@/lib/logger'
import { searchNearby, searchWithGeocode } from '@/lib/search'
import { SearchError } from '@/lib/types'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl
  const latRaw = searchParams.get('lat')
  const lngRaw = searchParams.get('lng')
  const q = searchParams.get('q')
  const radiusRaw = searchParams.get('radius') || '1000'

  const radiusMeters = parseInt(radiusRaw, 10) || 1000

  try {
    let result

    if (latRaw && lngRaw) {
      const lat = parseFloat(latRaw)
      const lng = parseFloat(lngRaw)
      if (isNaN(lat) || isNaN(lng)) {
        return NextResponse.json(
          { error: 'Invalid coordinates', code: 'bad_request' },
          { status: 400 },
        )
      }
      result = await searchNearby({ lat, lng, radiusMeters })
    } else if (q) {
      result = await searchWithGeocode(q, radiusMeters)
    } else {
      return NextResponse.json(
        { error: 'Provide lat+lng or q parameter', code: 'bad_request' },
        { status: 400 },
      )
    }

    return NextResponse.json(result)
  } catch (err) {
    if (err instanceof SearchError) {
      logger.warn('search request failed', { code: err.code })
      const status = err.code === 'bad_request' ? 400 : 503
      return NextResponse.json({ error: err.message, code: err.code }, { status })
    }
    logger.error('search request unexpected error', { error: String(err) })
    return NextResponse.json(
      { error: 'Internal server error', code: 'provider_unavailable' },
      { status: 500 },
    )
  }
}
