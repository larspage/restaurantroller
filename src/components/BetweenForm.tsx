'use client'

import { useState } from 'react'

export interface BetweenFormPayload {
  lat1: string
  lng1: string
  lat2: string
  lng2: string
}

interface BetweenFormProps {
  onSubmit: (payload: BetweenFormPayload) => void
  loading: boolean
}

export function BetweenForm({ onSubmit, loading }: BetweenFormProps) {
  const [lat1, setLat1] = useState('')
  const [lng1, setLng1] = useState('')
  const [lat2, setLat2] = useState('')
  const [lng2, setLng2] = useState('')

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    onSubmit({ lat1, lng1, lat2, lng2 })
  }

  return (
    <form
      onSubmit={handleSubmit}
      style={{ display: 'flex', flexDirection: 'column', gap: 12 }}
    >
      <label>
        Lat 1:{' '}
        <input
          type="text"
          value={lat1}
          onChange={e => setLat1(e.target.value)}
          placeholder="40.7128"
          name="lat1"
        />
      </label>
      <label>
        Lng 1:{' '}
        <input
          type="text"
          value={lng1}
          onChange={e => setLng1(e.target.value)}
          placeholder="-74.006"
          name="lng1"
        />
      </label>
      <label>
        Lat 2:{' '}
        <input
          type="text"
          value={lat2}
          onChange={e => setLat2(e.target.value)}
          placeholder="40.7580"
          name="lat2"
        />
      </label>
      <label>
        Lng 2:{' '}
        <input
          type="text"
          value={lng2}
          onChange={e => setLng2(e.target.value)}
          placeholder="-73.9855"
          name="lng2"
        />
      </label>
      <button type="submit" disabled={loading}>
        {loading ? 'Searching...' : 'Search'}
      </button>
    </form>
  )
}
