'use client'

import { useState } from 'react'
import { SearchModeToggle, type SearchMode } from '@/components/SearchModeToggle'
import { NearbyForm, type NearbyFormPayload } from '@/components/NearbyForm'
import { BetweenForm, type BetweenFormPayload } from '@/components/BetweenForm'
import { RadiusInput } from '@/components/RadiusInput'
import { SearchResults } from '@/components/SearchResults'

type NearbySearch = { kind: 'nearby'; payload: NearbyFormPayload }
type BetweenSearch = { kind: 'between'; payload: BetweenFormPayload }

export default function Home() {
  const [mode, setMode] = useState<SearchMode>('nearby')
  const [radius, setRadius] = useState('1000')
  const [results, setResults] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  async function runSearch(request: NearbySearch | BetweenSearch) {
    setLoading(true)
    setError(null)
    setResults(null)

    const params = new URLSearchParams()
    if (request.kind === 'nearby') {
      const { lat, lng, query } = request.payload
      if (lat && lng) {
        params.set('lat', lat)
        params.set('lng', lng)
      } else if (query) {
        params.set('q', query)
      } else {
        setError('Enter coordinates or a location name')
        setLoading(false)
        return
      }
    } else {
      const { lat1, lng1, lat2, lng2 } = request.payload
      params.set('lat1', lat1)
      params.set('lng1', lng1)
      params.set('lat2', lat2)
      params.set('lng2', lng2)
    }
    params.set('radius', radius)

    try {
      const endpoint = request.kind === 'nearby' ? '/api/search' : '/api/search/between'
      const res = await fetch(`${endpoint}?${params}`)
      const data = await res.json()
      if (!res.ok) {
        setError(data.error || data.code || 'Search failed')
      } else {
        setResults(JSON.stringify(data, null, 2))
      }
    } catch {
      setError('Network error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <main style={{ maxWidth: 640, margin: '0 auto', padding: 24, fontFamily: 'system-ui' }}>
      <h1>Eats</h1>
      <p>Find restaurants nearby or between two locations</p>

      <SearchModeToggle mode={mode} onChange={setMode} />

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {mode === 'nearby' ? (
          <NearbyForm onSubmit={payload => runSearch({ kind: 'nearby', payload })} loading={loading} />
        ) : (
          <BetweenForm onSubmit={payload => runSearch({ kind: 'between', payload })} loading={loading} />
        )}
        <RadiusInput value={radius} onChange={setRadius} />
      </div>

      <SearchResults results={results} error={error} />
    </main>
  )
}