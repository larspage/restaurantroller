import { describe, it, expect, beforeEach } from 'vitest'
import { metrics } from '.'

describe('metrics', () => {
  beforeEach(() => {
    metrics.reset()
  })

  it('starts at zero', () => {
    const s = metrics.snapshot()
    expect(s.requestCount).toBe(0)
    expect(s.errorCount).toBe(0)
    expect(s.errorRate).toBe(0)
    expect(s.latencyP50).toBe(0)
    expect(s.latencyP95).toBe(0)
  })

  it('tracks request count', () => {
    metrics.incRequest()
    metrics.incRequest()
    expect(metrics.snapshot().requestCount).toBe(2)
  })

  it('tracks error rate', () => {
    metrics.incRequest()
    metrics.incRequest()
    metrics.incRequest()
    metrics.incRequest()
    metrics.incError()
    expect(metrics.snapshot().errorRate).toBeCloseTo(0.25)
  })

  it('calculates latency percentiles', () => {
    for (let i = 1; i <= 100; i++) {
      metrics.recordLatency(i)
    }
    const s = metrics.snapshot()
    expect(s.latencyP50).toBeCloseTo(50, -1)
    expect(s.latencyP95).toBeCloseTo(95, -1)
  })

  it('tracks upstream outcomes', () => {
    metrics.recordUpstreamOutcome('success')
    metrics.recordUpstreamOutcome('success')
    metrics.recordUpstreamOutcome('error')
    const s = metrics.snapshot()
    expect(s.upstreamSuccesses).toBe(2)
    expect(s.upstreamErrors).toBe(1)
  })
})
