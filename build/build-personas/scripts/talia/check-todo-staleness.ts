/**
 * Persona check: TODO staleness
 *
 * Greps the codebase for TODO and FIXME in source files.
 * Parses inline dates if present. Flags items older than 30 days.
 *
 * Owner: Talia
 * Run: npx tsx build/build-personas/scripts/talia/check-todo-staleness.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { readFileSync, readdirSync, statSync } from 'fs'
import { resolve, relative, extname } from 'path'

import { fileURLToPath } from 'url'
const __dirname = resolve(fileURLToPath(import.meta.url), '..')
const ROOT = resolve(__dirname, '../../../../')

interface Finding {
  file: string
  line?: number
  message: string
}

type Status = 'PASS' | 'FAIL' | 'WARN' | 'SKIP'

interface CheckResult {
  name: string
  status: Status
  summary: string
  findings: Finding[]
}

const CHECK_NAME = 'todo-staleness'
const STALE_DAYS = 30

const SKIP_DIRS = new Set([
  'node_modules', 'dist', '.next', 'out', '.git', '.local-repos', 'coverage',
  '__snapshots__', 'design-system',
])

const EXTENSIONS = new Set(['.ts', '.tsx', '.js', '.jsx', '.md'])

function walkDir(dir: string, files: string[] = []): string[] {
  let entries: string[]
  try {
    entries = readdirSync(dir)
  } catch {
    return files
  }
  for (const entry of entries) {
    if (SKIP_DIRS.has(entry)) continue
    const full = resolve(dir, entry)
    let stat
    try {
      stat = statSync(full)
    } catch {
      continue
    }
    if (stat.isDirectory()) {
      walkDir(full, files)
    } else if (EXTENSIONS.has(extname(entry))) {
      files.push(full)
    }
  }
  return files
}

function run(): CheckResult {
  const findings: Finding[] = []
  const files = walkDir(ROOT)
  const now = Date.now()
  let totalTodos = 0

  for (const file of files) {
    const rel = relative(ROOT, file)
    let content: string
    try {
      content = readFileSync(file, 'utf-8')
    } catch {
      continue
    }

    const lines = content.split('\n')
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]

      // Match TODO or FIXME (case-insensitive, but TODO/FIXME is conventional)
      if (!/\b(TODO|FIXME)\b/i.test(line)) continue
      totalTodos++

      // Try to extract an inline date
      // Common patterns: TODO(2026-03-01), TODO 2026-03-01, TODO: (added 2026-03-01)
      const dateMatch = line.match(/(\d{4}-\d{2}-\d{2})/)
      if (dateMatch) {
        const todoDate = new Date(dateMatch[1])
        if (!isNaN(todoDate.getTime())) {
          const daysSince = Math.floor((now - todoDate.getTime()) / (1000 * 60 * 60 * 24))
          if (daysSince > STALE_DAYS) {
            const text = line.trim().substring(0, 100)
            findings.push({
              file: rel,
              line: i + 1,
              message: `Stale TODO (${daysSince} days): ${text}`,
            })
          }
        }
      }
    }
  }

  if (findings.length === 0) {
    return {
      name: CHECK_NAME,
      status: 'PASS',
      summary: `${totalTodos} TODOs/FIXMEs found, none with stale dates (>${STALE_DAYS} days)`,
      findings,
    }
  }
  return {
    name: CHECK_NAME,
    status: 'WARN',
    summary: `${findings.length} stale TODOs (>${STALE_DAYS} days old) out of ${totalTodos} total`,
    findings,
  }
}

function print(result: CheckResult): void {
  console.log(`[${result.status}] ${result.name}: ${result.summary}`)
  for (const f of result.findings) {
    const loc = f.line ? `${f.file}:${f.line}` : f.file
    console.log(`  - ${loc} -- ${f.message}`)
  }
}

const result = run()
print(result)
process.exit(result.status === 'FAIL' ? 1 : result.status === 'SKIP' ? 2 : 0)
