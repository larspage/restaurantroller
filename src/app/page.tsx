'use client'

import { useState } from 'react'

export default function Home() {
  const [mode, setMode] = useState<'nearby' | 'between'>('nearby')
  const [lat, setLat] = useState('')
  const [lng, setLng] = useState('')
  const [query, setQuery] = useState('')
  const [lat2, setLat2] = useState('')
  const [lng2, setLng2] = useState('')
  const [radius, setRadius] = useState('1000')
  const [results, setResults] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError(null)
    setResults(null)

    const params = new URLSearchParams()
    if (mode === 'nearby') {
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
      params.set('lat1', lat)
      params.set('lng1', lng)
      params.set('lat2', lat2)
      params.set('lng2', lng2)
    }
    params.set('radius', radius)

    try {
      const endpoint = mode === 'nearby' ? '/api/search' : '/api/search/between'
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

      <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
        <button onClick={() => setMode('nearby')} disabled={mode === 'nearby'}>Nearby</button>
        <button onClick={() => setMode('between')} disabled={mode === 'between'}>Between Two</button>
      </div>

      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {mode === 'nearby' ? (
          <>
            <label>
              Lat: <input type="text" value={lat} onChange={e => setLat(e.target.value)} placeholder="40.7128" />
            </label>
            <label>
              Lng: <input type="text" value={lng} onChange={e => setLng(e.target.value)} placeholder="-74.006" />
            </label>
            <p style={{ textAlign: 'center', color: '#888' }}>— or —</p>
            <label>
              Location: <input type="text" value={query} onChange={e => setQuery(e.target.value)} placeholder="New York" />
            </label>
          </>
        ) : (
          <>
            <label>Lat 1: <input type="text" value={lat} onChange={e => setLat(e.target.value)} placeholder="40.7128" /></label>
            <label>Lng 1: <input type="text" value={lng} onChange={e => setLng(e.target.value)} placeholder="-74.006" /></label>
            <label>Lat 2: <input type="text" value={lat2} onChange={e => setLat2(e.target.value)} placeholder="40.7580" /></label>
            <label>Lng 2: <input type="text" value={lng2} onChange={e => setLng2(e.target.value)} placeholder="-73.9855" /></label>
          </>
        )}

        <label>
          Radius (m): <input type="number" value={radius} onChange={e => setRadius(e.target.value)} min={100} max={20000} />
        </label>

        <button type="submit" disabled={loading}>
          {loading ? 'Searching...' : 'Search'}
        </button>
      </form>

      {error && <p style={{ color: 'red' }}>{error}</p>}
      {results && <pre style={{ background: '#f5f5f5', padding: 12, overflow: 'auto' }}>{results}</pre>}
    </main>
  )
}
