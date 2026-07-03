'use client'

import { useState } from 'react'

export interface NearbyFormPayload {
  lat: string
  lng: string
  query: string
}

interface NearbyFormProps {
  onSubmit: (payload: NearbyFormPayload) => void
  loading: boolean
}

export function NearbyForm({ onSubmit, loading }: NearbyFormProps) {
  const [lat, setLat] = useState('')
  const [lng, setLng] = useState('')
  const [query, setQuery] = useState('')

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    onSubmit({ lat, lng, query })
  }

  return (
    <form
      onSubmit={handleSubmit}
      style={{ display: 'flex', flexDirection: 'column', gap: 12 }}
    >
      <label>
        Lat:{' '}
        <input
          type="text"
          value={lat}
          onChange={e => setLat(e.target.value)}
          placeholder="40.7128"
          name="lat"
        />
      </label>
      <label>
        Lng:{' '}
        <input
          type="text"
          value={lng}
          onChange={e => setLng(e.target.value)}
          placeholder="-74.006"
          name="lng"
        />
      </label>
      <p style={{ textAlign: 'center', color: '#888' }}>— or —</p>
      <label>
        Location:{' '}
        <input
          type="text"
          value={query}
          onChange={e => setQuery(e.target.value)}
          placeholder="New York"
          name="query"
        />
      </label>
      <button type="submit" disabled={loading}>
        {loading ? 'Searching...' : 'Search'}
      </button>
    </form>
  )
}
