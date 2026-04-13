# Persona Scripts

Deterministic checks that personas own and run. These are executable verification scripts -- not LLM prompts, not instincts. They catch mechanical issues that an LLM will skip under pressure or context limits.

## Design Principle

**If a check can be deterministic, it must be a script.** LLM judgment is expensive and unreliable for mechanical verification (file existence, date arithmetic, pattern matching). Scripts run the same way every time, cost nothing, and never skip steps. Reserve LLM dispatch for checks that require judgment -- behavioral verification, spec compliance, edge case reasoning.

## Structure

```
scripts/
  AGENTS.md              -- this file
  _check_template.ts     -- template for new check scripts
  bob/                   -- Bob's build-time checks (session ready, code hygiene, commit ready)
    run-all.ts           -- entry point: auto-discovers and runs all check-*.ts
    check-*.ts           -- individual check scripts
  talia/                 -- Talia's QA checks (post-build integrity)
  oscar/                 -- Oscar's orchestration scripts (tmux session management)
```

Each persona gets a subdirectory when they need scripts. Not every persona needs scripts -- only add a directory when there are concrete checks to automate.

## Language and Runtime

**TypeScript via tsx.** Consistent with the monorepo convention. All scripts run with `npx tsx <script>`.

**Self-contained.** Scripts must not require `npm install` or additional dependencies beyond what the monorepo already provides. Use Node.js built-in modules (`fs`, `path`, `child_process`, `url`) and simple regex parsing. Do not add package.json to this directory.

**`__dirname` pattern.** Do not use `import.meta.dirname` -- it is undefined in this tsx/Node.js environment. Use the `fileURLToPath` pattern from the template instead:
```typescript
import { fileURLToPath } from 'url'
const __dirname = resolve(fileURLToPath(import.meta.url), '..')
const ROOT = resolve(__dirname, '../../path/to/monorepo/root')
```
**ROOT depth depends on subdirectory.** The template (`scripts/_check_template.ts`) uses `../../../` (3 levels up from `scripts/`). Scripts in persona subdirectories (`scripts/bob/`, `scripts/talia/`) need `../../../../` (4 levels up). When copying the template into a persona directory, adjust the `..` count so ROOT resolves to `{MONOREPO_ROOT}`.

**Run from monorepo root.** All scripts assume the working directory is `{MONOREPO_ROOT}`. Paths are relative to that root.

## Output Format

Every check script prints results in this format:

```
[PASS] <check name>: <summary>
[FAIL] <check name>: <count> issues found
  - <file>:<line> -- <description>
  - <file>:<line> -- <description>
[WARN] <check name>: <summary>
[SKIP] <check name>: <reason>
```

- **PASS** -- check ran, no issues
- **FAIL** -- check ran, issues found (each listed with file and description)
- **WARN** -- check ran, non-blocking concerns found
- **SKIP** -- check could not run (missing dependency, wrong environment)

Exit codes:
- `0` -- all checks PASS or WARN
- `1` -- at least one FAIL
- `2` -- at least one SKIP (environment issue)

## Entry Points

Each persona's `run-all.ts` is the single entry point. It runs every `check-*.ts` in its directory and prints a summary.

```bash
# Run all Talia checks
npx tsx build/build-personas/scripts/talia/run-all.ts

# Run a single check
npx tsx build/build-personas/scripts/talia/check-doc-freshness.ts
```

## How to Add a New Check

1. Copy `_check_template.ts` into the persona's subdirectory
2. Rename to `check-<name>.ts`
3. Implement the `run()` function
4. The entry point (`run-all.ts`) auto-discovers `check-*.ts` files -- no registration needed
5. Update the persona's playbook ownership section to reference the new check

## Routing

- **Adding a check for Talia?** -> `talia/`
- **Adding a check for Bob?** -> `bob/` (create if it does not exist)
- **Template for new checks?** -> `_check_template.ts`
- **Understanding the output format?** -> this file
