/**
 * Persona check: session readiness
 *
 * Verifies the repo is clean for a new session: git not diverged,
 * no uncommitted changes from a prior session, no IN PROGRESS sessions.
 *
 * Owner: Bob
 * Run: npx tsx build/build-personas/scripts/bob/check-session-ready.ts
 * From: {MONOREPO_ROOT} (monorepo root)
 */

import { execSync } from 'child_process'
import { readFileSync, existsSync } from 'fs'
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

const CHECK_NAME = 'session-ready'

/** State files to check for active sessions. Customize for your project. */
const SESSION_LOG_CANDIDATES = [
  'build/SESSION_LOG.md',
]

/** Required state files that should exist before a session starts */
const REQUIRED_FILES = [
  'build/PRIORITIES.md',
]

function run(): CheckResult {
  const findings: Finding[] = []

  // 1. Git fetch and check ahead/behind
  try {
    execSync('git fetch origin', { cwd: ROOT, encoding: 'utf-8', timeout: 15_000 })
  } catch {
    findings.push({ file: '.git', message: 'git fetch failed -- check network connection' })
  }

  try {
    const status = execSync('git status --porcelain --branch', { cwd: ROOT, encoding: 'utf-8' })
    const branchLine = status.split('\n')[0] || ''

    if (branchLine.includes('ahead')) {
      findings.push({ file: '.git', message: `Branch is ahead of remote -- unpushed commits from prior session` })
    }
    if (branchLine.includes('behind')) {
      findings.push({ file: '.git', message: `Branch is behind remote -- pull before starting` })
    }

    // Check for uncommitted changes
    const changes = status.split('\n').slice(1).filter(l => l.trim().length > 0)
    if (changes.length > 0) {
      findings.push({ file: '.git', message: `${changes.length} uncommitted change(s) from prior session` })
    }
  } catch {
    findings.push({ file: '.git', message: 'git status failed' })
  }

  // 2. Check for IN PROGRESS sessions in SESSION_LOG
  for (const logRelPath of SESSION_LOG_CANDIDATES) {
    try {
      const logPath = resolve(ROOT, logRelPath)
      if (!existsSync(logPath)) continue
      const content = readFileSync(logPath, 'utf-8')
      const lines = content.split('\n')
      let inComment = false
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i]
        if (line.includes('<!--')) inComment = true
        if (line.includes('-->')) { inComment = false; continue }
        if (inComment) continue
        if (/IN PROGRESS/i.test(line)) {
          findings.push({
            file: logRelPath,
            line: i + 1,
            message: `Active session detected: "${line.trim()}"`,
          })
        }
      }
    } catch {
      findings.push({ file: logRelPath, message: `Could not read ${logRelPath}` })
    }
  }

  // 3. Check required state files exist
  for (const reqFile of REQUIRED_FILES) {
    const reqPath = resolve(ROOT, reqFile)
    if (!existsSync(reqPath)) {
      findings.push({ file: reqFile, message: `Required state file missing: ${reqFile}` })
    }
  }

  if (findings.length === 0) {
    return { name: CHECK_NAME, status: 'PASS', summary: 'Repo clean, no active sessions', findings }
  }
  return { name: CHECK_NAME, status: 'WARN', summary: `${findings.length} items to address`, findings }
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
