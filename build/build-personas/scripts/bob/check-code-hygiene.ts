/**
 * Persona check: code hygiene
 *
 * Scans TypeScript source files for:
 * - Files over 200 lines (WARN) or 300 lines (FAIL) per CODE_STANDARDS.md
 * - `as any` casts that may be avoidable
 *
 * Owner: Bob
 * Run: npx tsx build/build-personas/scripts/bob/check-code-hygiene.ts
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
  severity: 'warn' | 'fail'
}

type Status = 'PASS' | 'FAIL' | 'WARN' | 'SKIP'

interface CheckResult {
  name: string
  status: Status
  summary: string
  findings: Finding[]
}

const CHECK_NAME = 'code-hygiene'

const WARN_LINES = 200
const FAIL_LINES = 300

/**
 * Directories to scan (relative to ROOT).
 * CUSTOMIZE: Replace with your workspace package directories.
 * Example: ['packages', 'apps'] or ['src'] or ['my-services', 'my-web']
 */
const SCAN_DIRS = [
  'src',
]

/** Directories to skip */
const SKIP_DIRS = new Set([
  'node_modules', 'dist', '.next', 'out', '__snapshots__',
  '.git', '.local-repos', 'coverage',
])

/** Only scan these extensions */
const EXTENSIONS = new Set(['.ts', '.tsx'])

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

  for (const scanDir of SCAN_DIRS) {
    const absDir = resolve(ROOT, scanDir)
    const files = walkDir(absDir)

    for (const file of files) {
      const rel = relative(ROOT, file)
      let content: string
      try {
        content = readFileSync(file, 'utf-8')
      } catch {
        continue
      }
      const lines = content.split('\n')

      // File size check
      if (lines.length > FAIL_LINES) {
        findings.push({
          file: rel,
          message: `${lines.length} lines (hard limit: ${FAIL_LINES})`,
          severity: 'fail',
        })
      } else if (lines.length > WARN_LINES) {
        findings.push({
          file: rel,
          message: `${lines.length} lines (target: ${WARN_LINES})`,
          severity: 'warn',
        })
      }

      // `as any` check
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i]
        // Match common `any` patterns but skip comments and test files
        if (rel.includes('.test.') || rel.includes('__tests__')) continue
        if (/as\s+any\b/.test(line) && !line.trimStart().startsWith('//')) {
          findings.push({
            file: rel,
            line: i + 1,
            message: `\`as any\` cast: ${line.trim().substring(0, 80)}`,
            severity: 'warn',
          })
        }
      }
    }
  }

  const fails = findings.filter(f => f.severity === 'fail')
  const warns = findings.filter(f => f.severity === 'warn')

  if (fails.length > 0) {
    return {
      name: CHECK_NAME,
      status: 'FAIL',
      summary: `${fails.length} failures, ${warns.length} warnings`,
      findings,
    }
  }
  if (warns.length > 0) {
    return {
      name: CHECK_NAME,
      status: 'WARN',
      summary: `${warns.length} warnings (no failures)`,
      findings,
    }
  }
  return { name: CHECK_NAME, status: 'PASS', summary: 'All files within limits, no `as any` casts', findings }
}

function print(result: CheckResult): void {
  console.log(`[${result.status}] ${result.name}: ${result.summary}`)
  for (const f of result.findings) {
    const loc = f.line ? `${f.file}:${f.line}` : f.file
    const tag = f.severity === 'fail' ? '!!' : ' >'
    console.log(`  ${tag} ${loc} -- ${f.message}`)
  }
}

const result = run()
print(result)
process.exit(result.status === 'FAIL' ? 1 : result.status === 'SKIP' ? 2 : 0)
