class MetricsStore {
  private requestCount = 0
  private errorCount = 0
  private latencies: number[] = []
  private upstreamSuccesses = 0
  private upstreamErrors = 0

  incRequest(): void {
    this.requestCount++
  }

  incError(): void {
    this.errorCount++
  }

  recordLatency(ms: number): void {
    this.latencies.push(ms)
  }

  recordUpstreamOutcome(outcome: 'success' | 'error'): void {
    if (outcome === 'success') this.upstreamSuccesses++
    else this.upstreamErrors++
  }

  snapshot(): MetricsSnapshot {
    const sorted = [...this.latencies].sort((a, b) => a - b)
    const n = sorted.length
    return {
      requestCount: this.requestCount,
      errorCount: this.errorCount,
      errorRate: this.requestCount > 0 ? this.errorCount / this.requestCount : 0,
      latencyP50: n > 0 ? percentile(sorted, 0.5) : 0,
      latencyP95: n > 0 ? percentile(sorted, 0.95) : 0,
      upstreamSuccesses: this.upstreamSuccesses,
      upstreamErrors: this.upstreamErrors,
    }
  }

  reset(): void {
    this.requestCount = 0
    this.errorCount = 0
    this.latencies = []
    this.upstreamSuccesses = 0
    this.upstreamErrors = 0
  }
}

function percentile(sorted: number[], p: number): number {
  const index = Math.ceil(p * sorted.length) - 1
  return sorted[Math.max(0, index)]
}

export interface MetricsSnapshot {
  requestCount: number
  errorCount: number
  errorRate: number
  latencyP50: number
  latencyP95: number
  upstreamSuccesses: number
  upstreamErrors: number
}

export const metrics = new MetricsStore()
