/**
 * Persona check: commit readiness
 *
 * Scans the git staging area for files that should never be committed:
 * .env files, build artifacts, node_modules, secrets patterns.
 *
 * Owner: Bob
 * Run: npx tsx build/build-personas/scripts/bob/check-commit-ready.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { execSync } from 'child_process'
import { resolve } from 'path'

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

const CHECK_NAME = 'commit-ready'

/** Patterns that should never be staged */
const BLOCKED_PATTERNS: Array<{ pattern: RegExp; reason: string }> = [
  { pattern: /\.env($|\.)/, reason: 'Environment/secrets file' },
  { pattern: /^dist\/|\/dist\//, reason: 'Build artifact (dist/)' },
  { pattern: /^\.next\/|\/\.next\//, reason: 'Build artifact (.next/)' },
  { pattern: /^out\/|\/out\//, reason: 'Build artifact (out/)' },
  { pattern: /\.tsbuildinfo$/, reason: 'TypeScript build info' },
  { pattern: /node_modules\//, reason: 'node_modules' },
  { pattern: /\.DS_Store$/, reason: 'macOS system file' },
  { pattern: /Thumbs\.db$/, reason: 'Windows system file' },
  { pattern: /credentials\.json$/, reason: 'Credentials file' },
  { pattern: /\.pem$/, reason: 'Certificate/key file' },
]

function run(): CheckResult {
  const findings: Finding[] = []

  // Get staged files
  let staged: string[]
  try {
    const output = execSync('git diff --cached --name-only', { cwd: ROOT, encoding: 'utf-8' })
    staged = output.split('\n').filter(l => l.trim().length > 0)
  } catch {
    return { name: CHECK_NAME, status: 'SKIP', summary: 'Could not read git staging area', findings }
  }

  if (staged.length === 0) {
    return { name: CHECK_NAME, status: 'PASS', summary: 'Nothing staged', findings }
  }

  // Check each staged file against blocked patterns
  for (const file of staged) {
    for (const { pattern, reason } of BLOCKED_PATTERNS) {
      if (pattern.test(file)) {
        findings.push({ file, message: `Should not be committed: ${reason}` })
        break // one finding per file is enough
      }
    }
  }

  // Also check unstaged changes for .env files (warn about potential exposure)
  let untracked: string[]
  try {
    const output = execSync('git ls-files --others --exclude-standard', { cwd: ROOT, encoding: 'utf-8' })
    untracked = output.split('\n').filter(l => l.trim().length > 0)
  } catch {
    untracked = []
  }

  for (const file of untracked) {
    if (/\.env($|\.)/.test(file)) {
      findings.push({ file, message: 'Untracked .env file -- verify .gitignore covers it' })
    }
  }

  if (findings.length === 0) {
    return { name: CHECK_NAME, status: 'PASS', summary: `${staged.length} staged files, all clean`, findings }
  }
  return { name: CHECK_NAME, status: 'FAIL', summary: `${findings.length} problematic files`, findings }
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
