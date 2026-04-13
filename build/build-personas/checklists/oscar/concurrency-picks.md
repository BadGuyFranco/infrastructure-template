# Concurrency Picks

**Trigger:** Founder says "next batch" or asks what priorities can run concurrently. May include running sessions: "next batch - running [SLUG-A], [SLUG-B]".
**Persona:** Oscar

Identify 2-3 priorities from the top of the queue that can run in parallel Bob sessions without conflicting. Each pick gets its own Oscar+Bob session pair.

## Inputs

- **Running sessions (if any).** The founder provides slugs of priorities already running concurrently. These constrain the picks -- new picks must not conflict with running priorities, not just with each other.
- **Component maps.** Your project's component map documents (e.g., `visualizations/COMPONENT-MAP.md` or similar). These are the verified conflict reference.

> **Creating component maps:** If your project does not yet have component maps, create them before using this checklist. A component map documents: (1) the logical zones/layers of your application, (2) which files belong to each zone/layer, (3) an overlap matrix showing shared boundaries between zones/layers, (4) dangerous parallel pairs -- combinations that conflict, and (5) safe parallel pairs. See the `visualizations/` directory for templates.

**Staleness check.** Each map has a `Last verified` date in its metadata block at the top. Count priorities in the `Archived -- Complete` section of PRIORITIES.md whose completion date is after that verification date. If 5 or more: tell the founder "Component maps are stale ([N] priorities executed since last verification on [DATE]). Recommendations may miss new conflicts. Proceed or refresh first?" Do not skip this check.

## Steps

### 1. Read the queue top

Read the top 6-8 queued priorities from PRIORITIES.md. For each, build a surface card (format below). Also build surface cards for any running priorities the founder provided.

### 2. Map code surfaces to components

**Surface card format** (one per priority):

```
[SLUG]
Zones: [zone numbers and names, or "none"]
Layers: [layer numbers and subsystems, or "none"]
Shared boundaries: [from Overlap Matrix, or "none"]
Source: priority entry | plan | agent trace
Confidence: documented | inferred
```

Fill each card using this decision tree:

**(a) Does the priority entry have a `Components:` field listing specific files or packages?** If yes: map those to zones/layers using the component maps. Set `Source: priority entry`, `Confidence: documented`. Done.

**(b) Does the priority have a plan with task-level items naming specific files?** If yes: read the plan's task inventory. Map named files to zones/layers. Set `Source: plan`, `Confidence: documented`. Done.

**(c) Does the priority entry describe the fix in enough detail to identify exact files** (e.g., "3 bugs in FileTabContext.tsx -- line 274, line 134")? If yes: map those files. Set `Source: priority entry`, `Confidence: documented`. Done.

**(d) None of the above.** Set `Confidence: inferred`. Proceed to step 3.

### 3. Resolve inferred surfaces (conditional)

Skip this step if all candidates have `Confidence: documented`.

For each priority with `Confidence: inferred`, spawn a sub-agent (type: Explore, thoroughness: very thorough) with this prompt:

```
Determine the code surface for priority [SLUG].

Priority entry:
[paste the full PRIORITIES.md entry]

Instructions:
1. Read the priority entry. Note any files, packages, or subsystems mentioned or implied.
2. If the entry references a plan file, read it. Extract task-level file references.
3. If the entry references ticket IDs, read TICKETS.md for those tickets. Look for file references.
4. For each file or package identified, trace one level of imports in each direction:
   - What does this file import from within the project?
   - What project files import this file?
5. Map all identified files to zones and layers per your project's component maps.
6. Check if any identified file appears in the Overlap Matrix of the component map.
7. Check if any import chain you traced is NOT documented in the component maps.

Return this exact format:
SLUG: [SLUG]
Files likely modified: [full paths, one per line]
Files likely read but not modified: [full paths, one per line]
Zones: [zone numbers and names]
Layers: [layer numbers and subsystems]
Shared boundaries: [list, or "none"]
Overlap Matrix hits: [rows matched, or "none"]
Map contradiction: [describe what the map gets wrong, or "none"]
```

After the agent returns:

- Fill in the surface card. Set `Source: agent trace`, `Confidence: documented` (the agent resolved it).
- If the agent reports a map contradiction: update the relevant component map immediately. Fix the incorrect claim. Add the correction to the map's change log with today's date.

### 4. Check conflicts and select

Work through candidates in priority order (highest first). The goal is 2-3 clean picks, not an exhaustive matrix.

**For each candidate, check it against running priorities and already-selected picks only.** Use the table below. Stop at the first BLOCK for that pair.

| Check | How to detect | Verdict |
|-------|---------------|---------|
| Same file modified by both | Both cards list the same file in their zones or layers. Or: Overlap Matrix row matched by both. | **BLOCK.** Cannot parallelize. |
| Same shared boundary | Both cards have the same entry in Shared boundaries. The critical boundaries depend on your project -- identify them in your component maps. | **BLOCK.** Cannot parallelize. |
| Dangerous Parallel Pair -- BLOCK | The pair matches a row in a Dangerous Parallel Pairs table with verdict BLOCK. | **BLOCK.** Cannot parallelize. |
| Dangerous Parallel Pair -- WARN | The pair matches a row with verdict WARN. | **CONDITIONAL.** Can parallelize. Copy the guardrail text from the map verbatim. Oscar enforces this guardrail during the sessions. |
| Dependency ordering | One priority's `Depends on` field names the other, or one produces output the other consumes. | **BLOCK.** Must be sequential. |
| Founder decision gate | Priority status says "needs founder decision" or has a `Research needed` section with open questions. | **FLAG.** Not a conflict, but this priority must be the founder's active session, not a background session. |
| Cross-repo coordination | Priorities touch different packages/repos but their surfaces hit the same row in a Cross-Repo Coordination table. | **CONDITIONAL.** Can parallelize only if the coordinated change is sequenced -- one session merges its cross-boundary change before the other starts consuming it. Record which side merges first. |

No match on any check = **SAFE.**

**Selection logic:**

1. Take the highest-priority candidate. Check it against all running priorities. If no BLOCK, it is pick #1.
2. Take the next candidate. Check it against running priorities AND pick #1. If no BLOCK, it is pick #2.
3. If a third pick is wanted: take the next candidate, check against running priorities, pick #1, and pick #2. If no BLOCK, it is pick #3.
4. If a candidate has a BLOCK, skip it and try the next one.
5. Stop as soon as you have 2-3 picks. Do not evaluate remaining candidates unless the founder asks.

**Selection criteria when multiple candidates pass:**

- Prefer items that uncheck launch gate conditions
- CONDITIONAL pairs are allowed only if the guardrail is concrete and Oscar can enforce it (not "be careful")
- FLAG items (founder decision gate) go in the founder's active session, not a background session

If only 1-2 candidates pass, say so. Do not force a pick. If zero candidates pass, report: "Queue is too sequential for safe concurrency" with the blocking reason.

### 6. Present

For each pick:

```
[SLUG] -- one-line summary
Surfaces: [from surface card -- zones and layers]
Running session conflicts: none | [guardrail from step 4]
Safe because: [cite specific map section, e.g., "Safe Parallel Pairs row 3: X vs Y"]
Phase: research | planning | execution
Founder input needed before start: no | [what decision]
```

For any CONDITIONAL pair in the batch:

```
Guardrail ([SLUG-A] + [SLUG-B]): [verbatim from map table]
Oscar enforcement: [how Oscar will enforce -- e.g., "Oscar reviews SLUG-A's shared/ changes before SLUG-B starts its phase"]
```

## Gate

Batch presented with all pairs having an explicit verdict (SAFE or CONDITIONAL with guardrail). No pair has an unresolved BLOCK. If no batch is possible, the output is: "Queue is too sequential for safe concurrency. [SLUG-X] and [SLUG-Y] conflict on [surface]. Recommend sequential execution, [SLUG] first because [reason]."
