/**
 * Persona check: doc freshness
 *
 * Finds all ARCHITECTURE.md files and checks their YAML frontmatter
 * for a `last-verified` date. Flags any stamp older than 30 days.
 *
 * Owner: Talia
 * Run: npx tsx build/build-personas/scripts/talia/check-doc-freshness.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { readFileSync, readdirSync, statSync } from 'fs'
import { resolve, relative } from 'path'

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

const CHECK_NAME = 'doc-freshness'
const STALE_DAYS = 30

const SKIP_DIRS = new Set([
  'node_modules', 'dist', '.next', 'out', '.git', '.local-repos', 'coverage',
])

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
    } else if (entry === 'ARCHITECTURE.md') {
      files.push(full)
    }
  }
  return files
}

function parseFrontmatter(content: string): Record<string, string> {
  const match = content.match(/^---\n([\s\S]*?)\n---/)
  if (!match) return {}
  const result: Record<string, string> = {}
  for (const line of match[1].split('\n')) {
    const idx = line.indexOf(':')
    if (idx > 0) {
      result[line.slice(0, idx).trim()] = line.slice(idx + 1).trim()
    }
  }
  return result
}

function run(): CheckResult {
  const findings: Finding[] = []
  const archFiles = walkDir(ROOT)
  const now = Date.now()

  for (const file of archFiles) {
    const rel = relative(ROOT, file)
    let content: string
    try {
      content = readFileSync(file, 'utf-8')
    } catch {
      continue
    }

    const fm = parseFrontmatter(content)
    const lastVerified = fm['last-verified']

    if (!lastVerified) {
      findings.push({
        file: rel,
        message: 'No last-verified date in frontmatter',
      })
      continue
    }

    const verifiedDate = new Date(lastVerified)
    if (isNaN(verifiedDate.getTime())) {
      findings.push({
        file: rel,
        message: `Invalid last-verified date: ${lastVerified}`,
      })
      continue
    }

    const daysSince = Math.floor((now - verifiedDate.getTime()) / (1000 * 60 * 60 * 24))
    if (daysSince > STALE_DAYS) {
      findings.push({
        file: rel,
        message: `last-verified: ${lastVerified} (${daysSince} days ago, limit: ${STALE_DAYS})`,
      })
    }
  }

  if (findings.length === 0) {
    return { name: CHECK_NAME, status: 'PASS', summary: `All ${archFiles.length} ARCHITECTURE.md files verified within ${STALE_DAYS} days`, findings }
  }
  return { name: CHECK_NAME, status: 'FAIL', summary: `${findings.length} stale or missing verification stamps`, findings }
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
