import type { Metadata } from 'next'
import { logger } from '@/lib/logger'

export const metadata: Metadata = {
  title: 'Eats — Restaurant Finder',
  description: 'Find restaurants nearby or between two locations',
}

logger.info('app initialized')

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
