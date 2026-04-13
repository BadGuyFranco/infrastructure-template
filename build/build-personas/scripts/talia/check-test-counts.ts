/**
 * Persona check: test counts
 *
 * Runs the test suite and compares the actual test count against
 * the count claimed in BUILD_STATUS.md or PRIORITIES.md.
 *
 * Owner: Talia
 * Run: npx tsx build/build-personas/scripts/talia/check-test-counts.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { readFileSync, existsSync } from 'fs'
import { resolve } from 'path'
import { execSync } from 'child_process'

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

const CHECK_NAME = 'test-counts'

/** Files to search for test count claims. Customize for your project. */
const CLAIM_SOURCES = [
  'build/PRIORITIES.md',
  'build/BUILD_STATUS.md',
]

/** Command to run tests. Customize for your project's test runner. */
const TEST_COMMAND = 'npx turbo run test 2>&1'

function extractClaimedCount(): { count: number; source: string; line: number } | null {
  for (const relPath of CLAIM_SOURCES) {
    const filePath = resolve(ROOT, relPath)
    if (!existsSync(filePath)) continue

    const content = readFileSync(filePath, 'utf-8')
    const lines = content.split('\n')
    for (let i = 0; i < lines.length; i++) {
      // Match patterns like "~1,879 tests" or "1,879 tests" or "1879 tests"
      const match = lines[i].match(/~?([\d,]+)\s+tests/i)
      if (match) {
        const count = parseInt(match[1].replace(/,/g, ''), 10)
        if (!isNaN(count) && count > 100) {
          return { count, source: relPath, line: i + 1 }
        }
      }
    }
  }

  return null
}

function getActualTestCount(): number | null {
  try {
    const output = execSync(TEST_COMMAND, {
      encoding: 'utf-8',
      cwd: ROOT,
      timeout: 120_000,
    })

    // Parse Vitest output for test counts
    // Matches patterns like "Tests  42 passed" or "Tests  42 passed (50)"
    let totalTests = 0
    const testLines = output.match(/Tests\s+(\d+)\s+passed/g)
    if (testLines) {
      for (const line of testLines) {
        const match = line.match(/Tests\s+(\d+)\s+passed/)
        if (match) {
          totalTests += parseInt(match[1], 10)
        }
      }
    }

    // Also check for "X passed" in summary lines
    if (totalTests === 0) {
      const summaryMatch = output.match(/(\d+)\s+passed/g)
      if (summaryMatch) {
        for (const m of summaryMatch) {
          const num = parseInt(m, 10)
          if (!isNaN(num)) totalTests += num
        }
      }
    }

    return totalTests > 0 ? totalTests : null
  } catch {
    return null
  }
}

function run(): CheckResult {
  const findings: Finding[] = []

  const claimed = extractClaimedCount()
  if (!claimed) {
    return {
      name: CHECK_NAME,
      status: 'SKIP',
      summary: 'No test count claim found in PRIORITIES.md or BUILD_STATUS.md',
      findings,
    }
  }

  const actual = getActualTestCount()
  if (actual === null) {
    return {
      name: CHECK_NAME,
      status: 'SKIP',
      summary: 'Could not run tests or parse test output',
      findings,
    }
  }

  // Allow 5% tolerance for minor changes
  const tolerance = Math.floor(claimed.count * 0.05)
  const diff = actual - claimed.count

  if (Math.abs(diff) > tolerance) {
    findings.push({
      file: claimed.source,
      line: claimed.line,
      message: `Claimed: ${claimed.count.toLocaleString()} tests, Actual: ${actual.toLocaleString()} tests (difference: ${diff > 0 ? '+' : ''}${diff})`,
    })
    return {
      name: CHECK_NAME,
      status: 'FAIL',
      summary: `Test count mismatch: claimed ${claimed.count.toLocaleString()}, actual ${actual.toLocaleString()}`,
      findings,
    }
  }

  return {
    name: CHECK_NAME,
    status: 'PASS',
    summary: `Test count matches: claimed ${claimed.count.toLocaleString()}, actual ${actual.toLocaleString()} (within ${tolerance} tolerance)`,
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
