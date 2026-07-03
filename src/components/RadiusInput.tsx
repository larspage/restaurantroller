'use client'

interface RadiusInputProps {
  value: string
  onChange: (value: string) => void
}

export function RadiusInput({ value, onChange }: RadiusInputProps) {
  return (
    <label>
      Radius (m):{' '}
      <input
        type="number"
        value={value}
        onChange={e => onChange(e.target.value)}
        min={100}
        max={20000}
        name="radius"
      />
    </label>
  )
}