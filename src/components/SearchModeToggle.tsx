'use client'

export type SearchMode = 'nearby' | 'between'

interface SearchModeToggleProps {
  mode: SearchMode
  onChange: (mode: SearchMode) => void
}

export function SearchModeToggle({ mode, onChange }: SearchModeToggleProps) {
  return (
    <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
      <button
        type="button"
        onClick={() => onChange('nearby')}
        disabled={mode === 'nearby'}
      >
        Nearby
      </button>
      <button
        type="button"
        onClick={() => onChange('between')}
        disabled={mode === 'between'}
      >
        Between Two
      </button>
    </div>
  )
}
