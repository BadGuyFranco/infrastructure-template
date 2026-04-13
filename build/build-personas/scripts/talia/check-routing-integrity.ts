/**
 * Persona check: routing integrity
 *
 * Finds all AGENTS.md files. Parses routing sections for file/directory
 * path references (lines with ->). Verifies each target path exists.
 *
 * Owner: Talia
 * Run: npx tsx build/build-personas/scripts/talia/check-routing-integrity.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { readFileSync, readdirSync, statSync, existsSync } from 'fs'
import { resolve, relative, dirname } from 'path'

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

const CHECK_NAME = 'routing-integrity'

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
    } else if (entry === 'AGENTS.md') {
      files.push(full)
    }
  }
  return files
}

function run(): CheckResult {
  const findings: Finding[] = []
  const agentsFiles = walkDir(ROOT)

  // Also check AGENTS.md files above ROOT (project-level)
  const projectRoot = resolve(ROOT, '..')
  const projectAgents = resolve(projectRoot, 'AGENTS.md')
  if (existsSync(projectAgents)) {
    agentsFiles.push(projectAgents)
  }

  for (const file of agentsFiles) {
    const rel = relative(ROOT, file)
    const fileDir = dirname(file)
    let content: string
    try {
      content = readFileSync(file, 'utf-8')
    } catch {
      continue
    }

    const lines = content.split('\n')
    let inRouting = false

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]

      // Track if we are in a Routing section
      if (/^##\s+Routing/i.test(line)) {
        inRouting = true
        continue
      }
      if (inRouting && /^##\s+/.test(line) && !/^##\s+Routing/i.test(line)) {
        inRouting = false
        continue
      }

      if (!inRouting) continue

      // Match lines with -> that contain backtick-wrapped paths
      const arrowMatch = line.match(/->.*`([^`]+)`/)
      if (!arrowMatch) continue

      const target = arrowMatch[1]

      // Skip non-path references (URLs, commands, descriptions)
      if (target.startsWith('http') || target.startsWith('npx') || target.startsWith('pnpm')) continue
      if (target.includes(' ')) continue // likely a description, not a path

      // Resolve the target relative to the AGENTS.md file's directory
      const targetPath = resolve(fileDir, target)
      if (!existsSync(targetPath)) {
        findings.push({
          file: rel,
          line: i + 1,
          message: `Routing target missing: ${target}`,
        })
      }
    }
  }

  if (findings.length === 0) {
    return { name: CHECK_NAME, status: 'PASS', summary: `All routing targets in ${agentsFiles.length} AGENTS.md files exist`, findings }
  }
  return { name: CHECK_NAME, status: 'FAIL', summary: `${findings.length} broken routing targets`, findings }
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
