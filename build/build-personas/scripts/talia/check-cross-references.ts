/**
 * Persona check: cross-references
 *
 * Scans markdown files for ADR references (pattern: ADR-NNNN or paths
 * containing decisions/NNNN-). Verifies referenced ADR files exist.
 *
 * Owner: Talia
 * Run: npx tsx build/build-personas/scripts/talia/check-cross-references.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { readFileSync, readdirSync, statSync, existsSync } from 'fs'
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

const CHECK_NAME = 'cross-references'

const SKIP_DIRS = new Set([
  'node_modules', 'dist', '.next', 'out', '.git', '.local-repos', 'coverage',
  'archive',  // archived plans are historical snapshots, not living docs
])

const DECISIONS_DIR = resolve(ROOT, 'decisions')

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
    } else if (extname(entry) === '.md') {
      files.push(full)
    }
  }
  return files
}

/** Build a map of ADR numbers to file paths */
function buildAdrIndex(): Map<string, string> {
  const index = new Map<string, string>()
  if (!existsSync(DECISIONS_DIR)) return index

  let entries: string[]
  try {
    entries = readdirSync(DECISIONS_DIR)
  } catch {
    return index
  }

  for (const entry of entries) {
    // Match files like 0031-monorepo-architecture.md
    const match = entry.match(/^(\d{4})-/)
    if (match) {
      const adrNum = match[1]
      index.set(adrNum, entry)
    }
  }
  return index
}

function run(): CheckResult {
  const findings: Finding[] = []

  if (!existsSync(DECISIONS_DIR)) {
    return { name: CHECK_NAME, status: 'SKIP', summary: 'decisions/ directory not found', findings }
  }

  const adrIndex = buildAdrIndex()
  const mdFiles = walkDir(ROOT)

  // Also check markdown files above ROOT (project-level)
  const projectRoot = resolve(ROOT, '..')
  const projectMdFiles = walkDir(projectRoot).filter(f => !f.startsWith(ROOT))
  mdFiles.push(...projectMdFiles)

  // Skip files inside decisions/ itself
  const decisionsPrefix = DECISIONS_DIR + '/'

  let totalRefs = 0

  for (const file of mdFiles) {
    if (file.startsWith(decisionsPrefix)) continue

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

      // Match ADR-NNNN references (e.g., ADR-0031, ADR-0044)
      const adrRefs = line.matchAll(/ADR-(\d{4})/g)
      for (const match of adrRefs) {
        totalRefs++
        const adrNum = match[1]
        if (!adrIndex.has(adrNum)) {
          findings.push({
            file: rel,
            line: i + 1,
            message: `References ADR-${adrNum} but no matching file in decisions/`,
          })
        }
      }

      // Match path-style references: decisions/NNNN-
      const pathRefs = line.matchAll(/decisions\/(\d{4})-([^\s)"\]]+)/g)
      for (const match of pathRefs) {
        totalRefs++
        const adrNum = match[1]
        const fullRef = `${adrNum}-${match[2]}`
        // Strip trailing .md if present for the existence check
        const refFile = fullRef.endsWith('.md') ? fullRef : `${fullRef}`
        const refPath = resolve(DECISIONS_DIR, refFile)
        if (!existsSync(refPath) && !existsSync(refPath + '.md')) {
          // Check if the ADR number exists even if the slug is different
          if (!adrIndex.has(adrNum)) {
            findings.push({
              file: rel,
              line: i + 1,
              message: `References decisions/${fullRef} but file not found`,
            })
          }
        }
      }
    }
  }

  if (findings.length === 0) {
    return { name: CHECK_NAME, status: 'PASS', summary: `All ${totalRefs} ADR references valid across ${mdFiles.length} markdown files`, findings }
  }
  return { name: CHECK_NAME, status: 'FAIL', summary: `${findings.length} broken ADR references`, findings }
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
