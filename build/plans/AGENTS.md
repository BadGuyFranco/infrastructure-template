# Plans

Structured execution plans for multi-session priorities, architecture reviews, and cross-component work.

## What Is a Plan?

A plan is a self-updating document that drives execution of a priority item across sessions. It is the SSOT for execution progress. It is NOT a priority stack (that's PRIORITIES.md) or an inbox (that's ToDos.md).

| Artifact | Purpose | Updated By |
|----------|---------|------------|
| **Plan** | How to execute a priority. Tracks tasks, progress, decisions. | The session working on the plan |
| PRIORITIES.md | What to work on, in order. The plan updates this. | The active plan (not sessions directly) |
| SESSION_LOG.md | What happened, session by session. | Every session, incrementally |
| BUILD_STATUS.md | Per-component build log. | Sessions that touch that component |
| ToDos.md | Unvetted ideas inbox. | Anyone |

## When to Create a Plan

- **When starting work on a priority item.** The first action on any multi-session priority is to create a plan here. The plan IS the context-independent prompt -- any session can pick it up cold. PRIORITIES.md says *what* and *why*; the plan says *how*.
- After an architecture review (monthly or milestone-triggered)
- After a cross-component analysis that surfaces more than 5 actionable items
- When a refactor spans multiple sessions and needs persistent tracking

For single-session work that still benefits from structured tracking, use `_MINI_TEMPLATE.md`. For truly trivial work, use ToDos.md or dispatch directly via the orchestrator.

## Plan Format

Use `_TEMPLATE.md` for multi-session plans, or `_MINI_TEMPLATE.md` for single-session work that benefits from plan structure (context, tasks, verification -- no phases, progress tables, or final check gates).

For full plans, every file must include these **required sections** regardless of plan type:

1. **Header block** (HTML comment) with:
   - **Priority link** -- which PRIORITIES.md item this plan executes (e.g., "Priority #6: Test Company")
   - **Current status** -- one-line summary updated every time work is done (e.g., "Phase 2 of 4 complete. Fixtures updated, seed script pending."). If a session dies mid-work, the next session reads this line and knows where things stand.
   - Status marker legend (`[ ]`, `[~]`, `[x]`, `[!]`, `[--]`)
   - Update rules (how to mark progress, including: update PRIORITIES.md status line when plan status changes)
   - Authority (what can be executed autonomously vs. needs founder input)
   - Context (enough background that a new session can execute without re-reading the source conversation)

2. **Tasks with status markers** -- the shape depends on the work (see plan types below).

3. **Verification** -- how to confirm the work is actually done (commands, spot-checks, tests).

4. **Progress summary table** at the bottom -- updated as items complete.

### Plan Types

The task structure is flexible. Use whichever fits the work:

**Review plan** (architecture reviews, audits):
- Part 1: Mechanical fixes -- no decisions needed, exact files, exact changes
- Part 2: Documentation gaps -- pre-reads included, no founder input needed
- Part 3: Decisions needed -- options (A/B/C) for founder to choose
- Part 4: Out of scope -- deferred items with "Why Deferred" and "Tracked In"

**Build plan** (feature work, test data, integration):
- Pre-reads -- files the session must read before starting
- Phases -- ordered steps with dependencies between them. If feasibility is uncertain, Phase 1 should prove the riskiest piece before expanding.
- Scope boundaries -- what to touch and what NOT to touch
- Acceptance criteria -- what "done" looks like, concretely

Both types use the same header, status markers, verification, and archival protocol.

## Naming Convention

`YYYY-MM-DD-{slug}.md` -- e.g., `2026-03-09-architecture-review.md`

## Priority Lifecycle (4 Steps)

Multi-session priorities go through a four-step process. Single-session work can dispatch directly without a plan.

### Step 1 -- Research
Before writing a plan, research thoroughly. Do NOT write the plan during this step.

**Before dispatching agents, write your assumptions.** One paragraph: what you believe is true about the problem, the codebase state, and the likely approach. This makes bias visible. Agents can then challenge specific assumptions rather than exploring aimlessly.

**Dispatch across at least 2 different angles.** See `../orchestrator/RESEARCH_DISPATCH.md` for 6 standard focus areas. Pick the ones relevant to the problem. You are not limited to these -- craft new focus areas when the problem demands it. Launch multiple agents per area when depth matters (e.g., 3 codebase audit agents examining different subsystems).

**Surface contradictions in your synthesis.** When agents disagree, that is the highest-value finding -- investigate it. If all agents agree, either the answer is obvious or the research was too narrow. Consolidated findings go into the plan's RESEARCH NOTES section.

### Step 2 -- Plan
Create a plan in this directory following `_TEMPLATE.md`. The plan must be self-contained: a new session can execute it cold. Verify every task references real files, real interfaces, real current state. Every plan must include tasks to update ARCHITECTURE.md, BUILD_STATUS.md, and any living docs. Walk through end-to-end, present to founder: "Ready to execute?"

### Step 3 -- Execute
The session reads the plan from the CURRENT STATUS line. The plan owns updating the PRIORITIES.md status line as work progresses. When confirmed complete, the founder decides when to delete the priority entry.

### Step 4 -- Final Check
Mandatory gate before archiving. Load and execute `build-personas/checklists/bob/close-priority.md` -- it has the full numbered procedure (11 steps from task verification through Talia dispatch to plan archival). The founder decides when to delete the PRIORITIES.md entry -- do not delete it autonomously.

**PRIORITIES.md entries should be lean.** Research context goes into plans, not into the priority queue. When a priority is promoted, research findings from PRIORITIES.md notes move into the plan's RESEARCH NOTES section.

## Plan Execution and Archival

Once a plan exists, this is the execution flow:

1. The plan links back to the priority. PRIORITIES.md links forward to the plan (`**Plan:**` field).
2. Sessions read the plan from the CURRENT STATUS line, execute items, update status markers.
3. Update SESSION_LOG.md incrementally. The plan tracks *what to do*; the session log tracks *what was done and when*.
4. When all items are `[x]`, `[--]`, or promoted elsewhere, confirm with the founder that the plan is complete.
5. Execute archival: update SESSION_LOG, move the plan to `archive/`. The founder decides when to delete the PRIORITIES.md entry.

**The plan owns PRIORITIES.md status updates** (updating the Status line as work progresses). Structural changes -- deleting entries, reordering priorities, changing scope descriptions -- require founder approval. History lives in SESSION_LOG, plans/archive/, and git.

**Parallel sessions.** If multiple sessions are active on different priorities, each session should add its SESSION_LOG.md entry immediately with status IN PROGRESS so other sessions know. Coordinate via SESSION_LOG -- if you see another session is active, avoid editing the same files. Each plan only touches its own priority item in PRIORITIES.md.

**Abrupt session ends.** Sessions can die (context limit, connection drop, user closes). The plan's **Current status** line in the header exists for this reason -- it's updated every time meaningful work is done, not just at archival. The next session reads this line and picks up where the last one left off. Partial progress is always better than lost progress.

**Blocked items.** When a task is marked `[!]`:
1. Document what's blocking it in the task line (not just the marker).
2. If resolvable within the session's scope and authority, resolve it.
3. If not resolvable: stop and surface the blocker to the founder. Do not skip it and continue.
4. If the blocker depends on other work, the founder decides next steps (create a dependency plan, reorder priorities, or descope). Update CURRENT STATUS and PRIORITIES.md to reflect the pause and unblock condition.

**Scope changes.** If scope needs to change during execution:
1. Stop and surface the change to the founder. Do not expand or reduce scope autonomously.
2. Once approved, update the Scope section in the plan and document the rationale.
3. Update Risks if the change introduces new risks.
4. Update CURRENT STATUS to reflect the scope change.

## Active Plans

For active plans and their status, see [PRIORITIES.md](../PRIORITIES.md) -- each priority with a plan links to it via the `**Plan:**` field. Plan files live in this directory; PRIORITIES.md is the SSOT for which are active and their current status.

## Archived Plans

Archived plans live in `plans/archive/`. Use `ls plans/archive/` to browse completed plans.

| Plan | Completed | Summary |
|------|-----------|---------|
| *(Plans will be listed here as they are completed and archived)* | | |

## Research Files

Research files in `plans/research/` are permanent reference. They are not archived when their parent priority completes. Use `ls plans/research/` to browse.

## Routing

- **Continuing a plan?** -> Read the plan file directly. It contains all instructions.
- **Starting a new review?** -> Create a new plan file following the format above.
- **Confused about plans vs. other artifacts?** -> See the table at the top.
