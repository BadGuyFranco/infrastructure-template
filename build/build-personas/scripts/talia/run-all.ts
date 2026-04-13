/**
 * Talia's deterministic checks -- entry point.
 *
 * Auto-discovers and runs all check-*.ts scripts in this directory.
 * Prints per-check results, then a summary.
 *
 * Owner: Talia
 * Run: npx tsx build/build-personas/scripts/talia/run-all.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { readdirSync } from 'fs'
import { resolve } from 'path'
import { execSync } from 'child_process'

import { fileURLToPath } from 'url'
const DIR = resolve(fileURLToPath(import.meta.url), '..')
const checks = readdirSync(DIR)
  .filter(f => f.startsWith('check-') && f.endsWith('.ts'))
  .sort()

let hasFail = false
let hasSkip = false

console.log(`\nTalia checks: running ${checks.length} scripts\n${'='.repeat(50)}`)

for (const check of checks) {
  try {
    const output = execSync(`npx tsx "${resolve(DIR, check)}"`, {
      encoding: 'utf-8',
      cwd: resolve(DIR, '../../../../'),
      timeout: 120_000,
    })
    process.stdout.write(output)
    if (output.includes('[FAIL]')) hasFail = true
    if (output.includes('[SKIP]')) hasSkip = true
  } catch (err: unknown) {
    const e = err as { stdout?: string; stderr?: string; status?: number }
    if (e.stdout) process.stdout.write(e.stdout)
    if (e.status === 1) hasFail = true
    if (e.status === 2) hasSkip = true
  }
}

console.log(`${'='.repeat(50)}`)
if (hasFail) {
  console.log('Summary: FAIL -- issues found. Review above.')
  process.exit(1)
} else if (hasSkip) {
  console.log('Summary: WARN -- some checks skipped.')
  process.exit(2)
} else {
  console.log('Summary: ALL PASS')
  process.exit(0)
}
