import { describe, it, expect, beforeEach, vi } from 'vitest'
import { logger } from '.'

describe('logger', () => {
  beforeEach(() => {
    logger.setLevel('debug')
    vi.restoreAllMocks()
  })

  it('logs structured JSON at info level', () => {
    const stdout = vi.spyOn(process.stdout, 'write')
    logger.info('test message', { key: 'value' })

    expect(stdout).toHaveBeenCalledTimes(1)
    const line = stdout.mock.calls[0][0] as string
    const parsed = JSON.parse(line)
    expect(parsed.level).toBe('info')
    expect(parsed.message).toBe('test message')
    expect(parsed.key).toBe('value')
    expect(parsed.service).toBe('eats')
    expect(parsed.timestamp).toBeDefined()
  })

  it('respects log level filtering', () => {
    const stdout = vi.spyOn(process.stdout, 'write')
    const stderr = vi.spyOn(process.stderr, 'write')

    logger.setLevel('error')
    logger.debug('should not appear')
    logger.info('should not appear')
    logger.warn('should not appear')
    logger.error('should appear')

    expect(stdout).not.toHaveBeenCalled()
    expect(stderr).toHaveBeenCalledTimes(1)
    const line = stderr.mock.calls[0][0] as string
    expect(JSON.parse(line).level).toBe('error')
  })

  it('writes debug and info to stdout, error to stderr', () => {
    const stdout = vi.spyOn(process.stdout, 'write')
    const stderr = vi.spyOn(process.stderr, 'write')

    logger.debug('debug msg')
    logger.info('info msg')
    logger.error('error msg')

    expect(stdout).toHaveBeenCalledTimes(2)
    expect(stderr).toHaveBeenCalledTimes(1)
  })

  it('allows runtime level change via setLevel', () => {
    logger.setLevel('warn')
    expect(logger.getLevel()).toBe('warn')
  })
})
