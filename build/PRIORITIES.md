<!-- SSOT for what to work on, in priority order. Read at session start.
For priority lifecycle methodology (research, plan, execute, final check),
see plans/AGENTS.md § Priority Lifecycle.
Items use stable slugs. Position = priority order.
Completed entries: update status, but ONLY the founder deletes entries. Never delete
or archive a priority without explicit founder approval.

ENTRY FORMAT (queued items):
- Owner: Oscar (or whichever orchestrator persona). One line, explicit.
- Summary: One-line description.
- What: 2+ lines. What the work IS, plus enough context and decision framing to drive planning.
- Why: 1 line. Why it matters or what's blocked without it.
- Unblocks: 1 line. What this enables downstream.
- Depends on / Constraint: 1 line if applicable.
- Status: 1 line. Current state + what's needed to start.
- NO new Note entries. Research goes into plans when promoted.
- Entries should be as long as needed to fully scope the planning process.
  Active items may be longer. -->

# Priorities

Last updated: {DATE}

## Project State

{PROJECT_NAME} is {ONE_SENTENCE_DESCRIPTION}.

**Lifecycle:** Pre-launch.
**What's built:** {BRIEF_SUMMARY_OF_CURRENT_STATE}
**Team:** Founder ({FOUNDER_NAME}) + AI technical lead (Claude).

## Launch Gate

> Conditions that must be true before launch. This is not a task list — each condition maps to one or more priorities in the queue. The founder curates this list. Items are checked off when the condition is verified, not when the underlying priority is marked complete.

- [ ] {EXAMPLE_GATE_CONDITION_1}
- [ ] {EXAMPLE_GATE_CONDITION_2}

## Active Stack

### {Example Priority Title} [{EXAMPLE-SLUG}]
**Owner:** Oscar
**Summary:** {One-line description of the work}
**What:** {What the work IS. Include enough context and decision framing to drive planning. 2+ lines.}
**Why:** {Why it matters or what's blocked without it.}
**Unblocks:** {What this enables downstream.}
**Depends on:** Nothing.
**Components:** {Which parts of the codebase are affected.}
**Status:** Not started. Needs research and planning. (Created: {DATE})

## Queued

> Items below are sequenced after the Active Stack. Each needs a research and planning phase before execution begins. When an active stack item completes, promote the next queued item. Order reflects dependency chains: items that inform or unblock later items come first.

## Deferred

> Items explicitly deferred. Each has a trigger condition for re-evaluation.

## Archived

> Completed priorities live as HTML comments above the Active Stack section. Format:
> <!-- [SLUG] archived {DATE}. {1-2 sentence summary of what was delivered.} Plan: plans/archive/{plan-file}. Sessions {N-M}. -->
