import { NextResponse } from 'next/server'
import { metrics } from '@/lib/metrics'

export const dynamic = 'force-dynamic'

export async function GET() {
  const snapshot = metrics.snapshot()

  const lines = [
    `# HELP eats_requests_total Total request count`,
    `# TYPE eats_requests_total counter`,
    `eats_requests_total ${snapshot.requestCount}`,
    `# HELP eats_errors_total Total error count`,
    `# TYPE eats_errors_total counter`,
    `eats_errors_total ${snapshot.errorCount}`,
    `# HELP eats_error_rate Error rate`,
    `# TYPE eats_error_rate gauge`,
    `eats_error_rate ${snapshot.errorRate}`,
    `# HELP eats_latency_p50 Request latency p50 (ms)`,
    `# TYPE eats_latency_p50 gauge`,
    `eats_latency_p50 ${snapshot.latencyP50}`,
    `# HELP eats_latency_p95 Request latency p95 (ms)`,
    `# TYPE eats_latency_p95 gauge`,
    `eats_latency_p95 ${snapshot.latencyP95}`,
    `# HELP eats_upstream_successes Upstream call successes`,
    `# TYPE eats_upstream_successes counter`,
    `eats_upstream_successes ${snapshot.upstreamSuccesses}`,
    `# HELP eats_upstream_errors Upstream call errors`,
    `# TYPE eats_upstream_errors counter`,
    `eats_upstream_errors ${snapshot.upstreamErrors}`,
  ]

  return new NextResponse(lines.join('\n') + '\n', {
    status: 200,
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
  })
}
