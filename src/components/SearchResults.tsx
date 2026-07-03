'use client'

interface SearchResultsProps {
  results: string | null
  error: string | null
}

export function SearchResults({ results, error }: SearchResultsProps) {
  if (error) {
    return <p style={{ color: 'red' }}>{error}</p>
  }
  if (results) {
    return (
      <pre style={{ background: '#f5f5f5', padding: 12, overflow: 'auto' }}>
        {results}
      </pre>
    )
  }
  return null
}