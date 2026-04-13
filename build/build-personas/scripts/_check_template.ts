/**
 * Persona check: <CHECK NAME>
 *
 * <One-line description of what this check verifies.>
 *
 * Owner: <persona name>
 * Run: npx tsx build/build-personas/scripts/<persona>/check-<name>.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { readFileSync, existsSync, readdirSync } from 'fs'
import { resolve, relative } from 'path'

// --- Configuration ---

import { fileURLToPath } from 'url'
const __dirname = resolve(fileURLToPath(import.meta.url), '..')
/** Monorepo root -- all paths relative to this */
const ROOT = resolve(__dirname, '../../../')

// --- Types ---

interface Finding {
  file: string    // relative to ROOT
  line?: number   // line number if applicable
  message: string
}

type Status = 'PASS' | 'FAIL' | 'WARN' | 'SKIP'

interface CheckResult {
  name: string
  status: Status
  summary: string
  findings: Finding[]
}

// --- Check implementation ---

const CHECK_NAME = 'template-check'

function run(): CheckResult {
  const findings: Finding[] = []

  // TODO: Implement check logic here.
  //
  // Pattern:
  //   1. Find files to check (glob or readdir)
  //   2. Read each file, apply deterministic rules
  //   3. Push a Finding for each issue
  //
  // Example:
  //   const content = readFileSync(resolve(ROOT, 'some/file.md'), 'utf-8')
  //   const lines = content.split('\n')
  //   lines.forEach((line, i) => {
  //     if (/* condition */) {
  //       findings.push({
  //         file: 'some/file.md',
  //         line: i + 1,
  //         message: 'Description of the issue'
  //       })
  //     }
  //   })

  if (findings.length === 0) {
    return { name: CHECK_NAME, status: 'PASS', summary: 'All checks passed', findings }
  }
  return { name: CHECK_NAME, status: 'FAIL', summary: `${findings.length} issues found`, findings }
}

// --- Output formatting (do not modify) ---

function print(result: CheckResult): void {
  const tag = `[${result.status}]`
  console.log(`${tag} ${result.name}: ${result.summary}`)
  for (const f of result.findings) {
    const loc = f.line ? `${f.file}:${f.line}` : f.file
    console.log(`  - ${loc} -- ${f.message}`)
  }
}

const result = run()
print(result)
process.exit(result.status === 'FAIL' ? 1 : result.status === 'SKIP' ? 2 : 0)
