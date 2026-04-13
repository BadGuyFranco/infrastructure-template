<!--
PLAN: [Short title]
PRIORITY: [SLUG] -- [Priority title from PRIORITIES.md]
CURRENT STATUS: Not started.

STATUS MARKERS:
- [ ] Not started
- [~] In progress
- [x] Complete
- [!] Blocked
- [--] Skipped / not applicable

UPDATE RULES:
- Update status markers as items complete.
- Update CURRENT STATUS (above) every time meaningful work is done -- this is the crash-recovery line.
- Update PRIORITIES.md `**Status:**` line when plan status changes.
- When all tasks are complete, run the Final Check section before archiving.
- Only after Final Check passes: delete priority entry from PRIORITIES.md, then move this file to archive/.

PLAN SIZE: If a plan exceeds 30 tasks, split into independently executable phases. Each phase has its own commit point and can start from a clean context. A 179-task plan cannot be held in context and becomes a document to manage, not a tool to execute.

PLAN CREATION PROCESS:
This plan was created following the process in PRIORITIES.md:
1. RESEARCH -- All architecture docs, code, ADRs, and current state were audited before writing this plan.
   Every task below is grounded in verified current state, not assumptions.
2. PLAN -- This document. Verified end-to-end: executing tasks in order produces the intended result.
3. EXECUTE -- A new session executes this plan from the CURRENT STATUS line.
4. FINAL CHECK -- Mandatory gate before archiving. All docs verified accurate, all living references updated, QA verdict received.

AUTHORITY:
- [What can be executed autonomously vs. needs founder input]

CONTEXT:
- [Enough background that a new session can execute without re-reading the source conversation]
- [Why this work is needed -- reference the priority item]
- [What's already built / current state -- verified during research phase]

KEY CONCEPTS:
- [Definitions a new context needs to understand the plan]

RESEARCH NOTES:
- [Key findings from the research phase that informed plan structure]
- [Current state discoveries that differ from what architecture docs claim]
- [Dependencies or blockers identified during research]
-->

# [Plan Title]

**Priority:** [SLUG] -- [Title]
**Created:** YYYY-MM-DD
**Type:** [review | build]

## Pre-reads

Read these before starting:
- [ ] [file path -- why it matters]
- [ ] [file path -- why it matters]

## Authority

[What can be executed autonomously vs. needs founder input]

## Key Concepts

[Definitions a new session needs to understand the plan]

## Research Notes

[Key findings from research that informed plan structure. Current state discoveries
that differ from architecture docs. Dependencies or blockers identified.]

## Scope

**In scope:**
- [Explicit list of what this plan covers]

**Out of scope:**
- [Explicit list of what this plan does NOT cover, with rationale]

## Risks

| Risk | Status | Mitigation | Notes |
|------|--------|------------|-------|
| [What could go wrong] | Active | [How we address it] | |

<!-- Status: Active (monitoring), Mitigated (reduced), Realized (occurred), Retired (no longer applies).
     Update as work progresses. If a risk realizes, log the response in the plan header or relevant task. -->

## Tasks

<!-- Structure this section to fit the work.
     Review plan: Part 1 (mechanical), Part 2 (docs), Part 3 (decisions), Part 4 (deferred)
     Build plan: Phases with dependencies, scope boundaries, acceptance criteria

     INDEPENDENCE: When phases have no dependencies between them, annotate so the
     executor can parallelize. E.g.: "Phases 2-3 are independent." The plan describes
     what can run in parallel -- the executor decides how. -->

### Phase 1: [Title]

- [ ] Task description (reference specific files, interfaces, current state)
- [ ] Task description

### Phase 2: [Title]

- [ ] Task description

### Documentation Updates

<!-- REQUIRED. Every plan must update docs for components it touches. These are not optional cleanup.
     Delete any line that genuinely does not apply (component not touched), but do not skip this section. -->

- [ ] Update ARCHITECTURE.md for [component] -- reflect changes to [what changed]
- [ ] Update ARCHITECTURE.md `last-verified` and `verified-by` fields for [component]
- [ ] Update decisions/README.md -- [new ADR added / ADR status changed]
- [ ] Update [other living doc] -- [what reference changed]

## Deviations

<!-- Record any deviations from the original plan here. If a task reveals the plan's
assumptions were wrong, log: what was expected, what was found, and how you adjusted.
Pattern of 3+ deviations = stop and re-plan with the user. -->

## Verification

- [ ] [Command or check that confirms the work is done]
- [ ] [Spot-check or test]

## Final Check

<!-- MANDATORY GATE. Do not archive this plan until every item below passes.
     This section runs AFTER all tasks and verification are complete. -->

- [ ] All ARCHITECTURE.md files for touched components are accurate (spot-check 2-3 claims against code)
- [ ] All ARCHITECTURE.md `last-verified` dates are updated to today
- [ ] No stale references in ROUTING.md, AGENTS.md, or other living docs that point to changed paths/interfaces
- [ ] Tests pass (run test suite for touched components)
- [ ] PRIORITIES.md `**Status:**` line is current
- [ ] SESSION_LOG.md has a final summary entry for this plan's work
- [ ] QA report received -- verdict is PASS or CONDITIONAL PASS with all conditions resolved. Do NOT archive this plan until QA has returned a real verdict. A plan with "awaiting QA" status must not be moved to archive/.

## Progress Summary

| Phase | Items | Done | Status |
|-------|-------|------|--------|
| Phase 1 | 0 | 0 | Not started |
| Phase 2 | 0 | 0 | Not started |
| Doc Updates | 0 | 0 | Not started |
| Verification | 0 | 0 | Not started |
| Final Check | 7 | 0 | Not started |
| **Total** | **0** | **0** | **Not started** |
