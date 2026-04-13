# Housekeeping

**Trigger:** Founder requests priorities/plans review, or Oscar initiates between priorities during a quiet session.
**Persona:** Oscar

A comprehensive sweep of project state: priorities, plans, session log, service registry, ADRs, carry-forwards, and checklists. Oscar dispatches parallel sub-agents for each audit, synthesizes findings, and presents recommendations. Produces recommendations, not changes -- the founder decides.

## Steps

### 1. Dispatch audits

Launch the following sub-agents in parallel. Each agent returns structured findings in the format specified below. Oscar does not perform these audits inline -- the point is parallel execution and context isolation.

**Findings format** (all agents use this):
```
CATEGORY: [archive | fix-status | move-item | reorder | drop | promote | add-dependency | other]
ITEM: [specific item identifier -- priority slug, plan filename, ADR number, etc.]
SOURCE: [file path and line or section reference]
FINDING: [one-line description]
EVIDENCE: [what you checked to reach this conclusion]
RECOMMENDATION: [proposed action]
```

#### Agent A: Priority status and ordering

Scope: `PRIORITIES.md` queued and deferred sections.

**Status audit.** Read every entry. For each, check:
- Complete but not archived. Status says DONE, COMPLETE, CLOSED, or equivalent, but the entry is still in the queue. Assess: are there follow-ups or carry-forwards that need a home before archiving? If yes, identify where they land. If no, recommend archival.
- Incorrectly marked complete. Status says complete but carry-forwards, follow-ups, or open questions remain that are not tracked elsewhere. Flag -- not done.
- Orphaned work items. Follow-ups or carry-forwards sitting inside a completed priority that belong in an active priority. Identify destination and specific items.
- Stale status lines. Status references sessions, dates, or states that are no longer current.

**Ordering audit.** Read the queue top-to-bottom. For each pair of adjacent priorities:
- Dependency inversions. Does priority N+1 depend on output from priority N that sits below it? Flag.
- Transitive dependencies. Walk the full dependency graph, not just adjacent pairs. If A depends on B depends on C, and C is below A, flag the chain.
- Circular blocks. Any priority pair where each lists the other as a dependency.
- Launch-gate blockers. Does anything block a launch gate condition? Is it sequenced high enough?
- Shared code surfaces. Do priorities touch the same files/packages? Note sequencing requirements or concurrency opportunities.
- Trigger-blocked items. Queued items blocked by a trigger in the Deferred section. Research-only work that can proceed is fine -- note the distinction.

**Deferred section review.** For each deferred priority:
- Should any be promoted to the queue based on current progress or unblocked dependencies?
- Should any be dropped entirely (V2 concern, overtaken by events, no longer relevant)?

#### Agent B: Plans audit

Scope: `plans/` directory (exclude `plans/archive/`, templates).

Inventory all non-archived plans (including `plans/research/` and `plans/audits/`).

For each plan:
- Associated priority. Does the plan map to a current priority in PRIORITIES.md? If the priority was archived but the plan was not, recommend archiving.
- Stagnant plans. No activity for 3+ sessions. Check SESSION_LOG.md for last mention. If stagnant with no planned resumption, recommend archiving or note why on hold.
- Orphaned plans. Not referenced by any priority and not in active execution. Recommend archiving or associating.
- Research plans with unacted findings. Research complete but findings never consumed by a planning or build phase. Flag -- research that sits unread is wasted work.

#### Agent C: Session log hygiene

Scope: `SESSION_LOG.md` and `SESSION_LOG_ARCHIVE.md`.

- Rotation check. SESSION_LOG.md should have at most 10 entries. If it exceeds 10, move the oldest entries to SESSION_LOG_ARCHIVE.md (append at the top, add a comment noting the rotation date and session range). Update the archive comment at the bottom of SESSION_LOG.md.
- Stale references. Entries referencing archived priorities, renamed slugs, or deleted plans.
- Unresolved items. Any session entry that notes "follow up next session" or equivalent where the follow-up never happened. Flag with the session number and the unresolved item.

#### Agent D: Service registry audit

Scope: `SERVICE_REGISTRY.md`.

- Credential staleness. Services with credentials that may have rotated or expired. Check documented rotation schedules or last-verified dates.
- Added/removed services. Services in the codebase (imports, API calls, config references) not in the registry, or registry entries for services no longer used.
- API access gaps. Services listed but with no documented API access method (no CLI, no API key location, no OAuth flow). These are services Oscar cannot verify and Bob cannot automate -- they require founder action until documented.
- Consistency. Do registry entries match the actual credential locations on disk and in environment files?

#### Agent E: ADR hygiene

Scope: `decisions/` directory and `decisions/README.md`.

- Accepted vs. implemented. For each accepted ADR, spot-check whether the codebase reflects the decision. Full verification is out of scope -- check the primary artifact (the file, type, or config the ADR specifies). Flag drift.
- Superseded markings. ADRs that have been effectively replaced by a later decision but not marked superseded. Check cross-references between ADRs.
- Undocumented decisions. Decisions made in SESSION_LOG or PRIORITIES.md (especially founder decisions) that warrant an ADR but don't have one. Look for "founder decision" markers in carry-forwards and status lines.
- README accuracy. Does `decisions/README.md` list all ADRs? Are statuses current? Any ADR files not listed?

#### Agent F: Carry-forward completeness

Scope: `PRIORITIES.md` (archived comments and active entries), `plans/archive/`, `SESSION_LOG.md`.

- Trace every carry-forward. For each archived priority (HTML comments in PRIORITIES.md) and each archived plan, find every carry-forward item. Verify each landed in an active priority or was explicitly dropped.
- Orphaned carry-forwards. Items that were carried forward but the destination priority was also archived, or the destination doesn't mention the item. These are lost work items.
- Implicit carry-forwards. Work items mentioned in session log entries for completed priorities that were never formally carried forward. Check the last 2-3 session entries for each archived priority.

#### Agent G: AGENTS.md accuracy

Scope: every `AGENTS.md` file in the repository.

AGENTS.md is the mandatory first-read entry point for every directory. Stale routing wastes Bob's context on phantom paths and misses real ones. This agent verifies every AGENTS.md reflects the actual codebase.

**Inventory.** Glob for all `**/AGENTS.md` files. For each:

- **Routing table vs. directory contents.** Every path in the routing table must resolve to an existing file or directory. Every significant subdirectory or module file must appear in the routing table. Flag phantom entries (point to deleted/moved files) and missing entries (exist on disk but not routed).
- **References to removed systems.** Grep for known removed or renamed systems in your project. Any mention of deprecated or removed components is stale.
- **Cross-references.** Links to other AGENTS.md files, ARCHITECTURE.md files, BUILD_STATUS.md files, or plan files must resolve. Dead links are stale references.
- **Description accuracy.** One-line descriptions of routed items should reflect what the item actually does now, not what it did before refactoring. Spot-check 2-3 descriptions per file against the actual code or document.

**Coverage gaps.** Identify directories that contain significant code or documentation but have no AGENTS.md file. Not every directory needs one -- only directories that Bob enters as a work target (service packages, feature modules, infrastructure directories). Leaf directories with a single file do not need routing.

#### Agent H: Checklist self-review

Scope: `build-personas/checklists/oscar/` and `build-personas/checklists/AGENTS.md`.

- Accuracy. Do checklist steps match current process? Reference files that no longer exist, steps that reference removed priorities, or procedures that have changed.
- Routing table. Does the routing table in `oscar.md` match the checklist inventory? Any checklists not routed, or routes pointing to missing checklists?
- Coverage gaps. Are there recurring procedures Oscar performs that are not captured in any checklist? Check SESSION_LOG for repeated patterns.
- Staleness. Checklists that reference specific priority slugs, session numbers, or tools that have changed.

### 2. Synthesize and triage findings

Wait for all agents to return. Deduplicate across agents -- multiple agents may flag the same item from different angles. Sort every finding into one of two buckets:

**Bucket 1: Oscar fixes autonomously.** Mechanical corrections that have a single correct answer and no scope, priority, or strategic implications. Oscar dispatches sub-agents (or acts directly) to make these changes immediately. Examples:

- Fix stale status lines (wrong session number, outdated date, renamed slug)
- Archive completed priorities that have no open carry-forwards
- Archive orphaned or stagnant plans whose priority is already archived
- Update decisions/README.md to list missing ADR entries
- Mark superseded ADRs when a later ADR explicitly replaces them
- Fix stale references in session log entries (renamed slugs, deleted plans)
- Correct checklist routing table mismatches
- Move carry-forwards that have an obvious single destination priority
- Remove registry entries for services confirmed no longer in the codebase

**Bucket 2: Founder decides.** Anything involving scope, priority ordering, strategic direction, or ambiguity. Oscar presents these with evidence and a recommendation but does not act. Examples:

- Reordering priorities (dependency logic may be correct but strategic intent overrides)
- Dropping priorities or deferring to V2
- Promoting deferred items to the queue
- Adding new dependency relationships between priorities
- Decisions that need ADRs (the decision itself is the founder's, Oscar drafts the ADR after)
- Carry-forwards with ambiguous destinations (could land in multiple priorities)
- Service registry gaps that require founder credentials or account access
- Items where agents disagree or evidence is inconclusive

### 3. Execute autonomous fixes

For Bucket 1 items, dispatch sub-agents to make the corrections in parallel. Each agent:
- Makes the edit
- Verifies the result (re-reads the file, confirms the change is correct)
- Returns a one-line summary of what changed

Oscar logs all autonomous fixes so the founder can review after the fact.

### 4. Present founder decisions

Present Bucket 2 items to the founder. For each:
- The finding (one line)
- The evidence (which agent found it, what they checked)
- Oscar's recommendation
- Why this requires a founder decision (what is ambiguous or strategic)

Group by impact: highest-impact items first. If the founder approves items, execute immediately. Note deferred items for next housekeeping run.

## Gate

All eight audits returned findings. Findings triaged into autonomous fixes and founder decisions. Autonomous fixes executed and logged. Founder decisions presented with evidence and recommendations. No strategic or scope changes made without founder confirmation.
