# Codebase Audit

**Trigger:** Founder requests a code review sweep, or Oscar initiates one between priorities.
**Persona:** Oscar (with Bob for ambiguous findings)

A standing process for comprehensive code review across a scoped area of the codebase. Each run produces a dated findings document. Findings are triaged into priority actions.

## Inputs

Before starting, define:
- **Scope:** Which services/components (e.g., "server + billing", "renderer", "execution + scheduler"). One scope per run. Full codebase = multiple runs.
- **Concern lens (optional):** Security, error handling, test coverage, architectural drift, dead code, consistency. Omit to scan all concerns.

## Steps

1. **Survey.** Read AGENTS.md, ARCHITECTURE.md, and BUILD_STATUS.md for the scoped components. For each AGENTS.md: verify routing table entries resolve to existing files/directories, check for references to removed or renamed systems, and confirm descriptions match current code. Flag stale entries as findings before proceeding. Identify: entry points, service boundaries, recent changes (git log), areas with low test coverage or known tech debt. Build a target list of 6-12 investigation areas.

2. **First swarm.** Spawn parallel investigation agents (one per area). Each agent gets a specific question: "In [area], look for [concern]. Report: what you found, severity (critical/moderate/low), evidence (file:line)." Collect results.

3. **Triage round 1.** Evaluate agent findings. Discard false positives. Group related findings. Identify areas that need deeper investigation -- ambiguous results, suspected but unconfirmed issues, patterns that appear in multiple places.

4. **Deep-dive swarm.** Spawn targeted agents for the areas from step 3. These agents get narrower scope and harder questions. For findings that require build-depth judgment, ask Bob: "Is this intentional or a bug? What's the history?"

5. **Validate and classify.** Group confirmed findings into logical areas. For each group, classify:
   - **(a) New priority.** The group requires a full plan-build cycle. Draft a PRIORITIES.md entry.
   - **(b) Amend existing priority.** The finding is related to an existing priority. Note which one and what to add.
   - **(c) Defer to post-V1.** Real issue but not launch-blocking. Note it for future version.
   - **(d) Not actionable.** Intentional design, acceptable tradeoff, or false positive. Drop it.

6. **Write findings document.** Create `plans/audits/YYYY-MM-DD-[scope-slug]-audit.md` with: scope, methodology, findings grouped by area, classification (a/b/c/d), and recommendations. Only items classified a/b/c surface to the founder.

7. **Report to founder.** Present findings that meet the a/b/c threshold. For each: what was found, evidence, classification, and recommended action.

## Composability Check ([COMPOSE])

Run during every audit, after step 5. Separate from the concern-based findings -- this is standing hygiene.

1. **Scan for oversized files.** In the scoped components, find all `.ts` files >500 lines (exclude tests, node_modules, dist).
2. **Filter by Bob's read frequency.** Keep files that Bob reads on >50% of tasks -- inferred from role: DI containers, main entry points, central pipelines, route files, core services.
3. **Assess seams.** For each candidate, check for natural internal seams: section markers, logical groups that don't cross-reference heavily, extractable helper/type blocks.
4. **Assess value before recommending.** For each candidate that passes steps 1-3, answer:
   - **Read pattern:** Does Bob need isolated sections (lookup-style, like a DI container), or does he need full pipeline context when he reads this file? Lookup-style files benefit most from splitting. Pipeline files often require reading multiple split files anyway, negating the savings.
   - **Token math:** Estimate tokens saved per read x estimated reads over remaining sessions. Compare against the session cost to execute the split (~1 session per file).
   - **Threshold:** Only recommend candidates where the split saves Bob meaningful comprehension effort, not just line count. If Bob would read 3 of 4 split files on a typical task, the split adds navigation cost without reducing tokens.
5. **Log candidates that clear the value threshold.** Add to the audit findings document (step 6) with: file path, line count, proposed seam, estimated split sizes, and the value assessment from step 4. Surface to the founder as part of the audit report.

Criteria:
- File is >500 lines
- Bob reads it on >50% of tasks
- File has natural internal seams
- Split preserves the public API (same exports, same types)
- Split provides real comprehension savings, not just smaller files

## Gate

- Findings document exists with dated artifact
- Every finding has a classification (a/b/c/d) with rationale
- Only a/b/c items surfaced to founder
- Composability check completed: candidates with positive value assessment logged to audit findings document and surfaced to founder
- PRIORITIES.md updated if founder approves new or amended priorities
