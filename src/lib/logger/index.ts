type LogLevel = 'debug' | 'info' | 'warn' | 'error'

const LOG_LEVELS: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
}

let currentLevel: LogLevel = (process.env.LOG_LEVEL as LogLevel) ?? 'info'

function isValidLevel(s: string): s is LogLevel {
  return ['debug', 'info', 'warn', 'error'].includes(s)
}

function setLevel(level: LogLevel): void {
  currentLevel = level
}

function getLevel(): LogLevel {
  return currentLevel
}

function setLevelFromEnv(): void {
  const env = process.env.LOG_LEVEL
  if (env && isValidLevel(env)) {
    currentLevel = env
  }
}

type LogFn = (message: string, meta?: Record<string, unknown>) => void

function log(level: LogLevel, message: string, meta?: Record<string, unknown>): void {
  if (LOG_LEVELS[level] < LOG_LEVELS[currentLevel]) return

  const entry = {
    timestamp: new Date().toISOString(),
    level,
    service: 'eats',
    message,
    ...meta,
  }

  const output = JSON.stringify(entry)

  switch (level) {
    case 'error':
      process.stderr.write(output + '\n')
      break
    default:
      process.stdout.write(output + '\n')
  }
}

const logger: Record<LogLevel, LogFn> & {
  setLevel: typeof setLevel
  getLevel: typeof getLevel
  setLevelFromEnv: typeof setLevelFromEnv
} = {
  debug: (message, meta) => log('debug', message, meta),
  info: (message, meta) => log('info', message, meta),
  warn: (message, meta) => log('warn', message, meta),
  error: (message, meta) => log('error', message, meta),
  setLevel,
  getLevel,
  setLevelFromEnv,
}

export { logger }
export type { LogLevel }
