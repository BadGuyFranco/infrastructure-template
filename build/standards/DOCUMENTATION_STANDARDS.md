# {PROJECT_NAME} -- Documentation Standards

These are the documentation standards for all {PROJECT_NAME} repositories. Any AI coding tool or human developer working on {PROJECT_NAME} MUST read and follow this file.

**The core rule: Documentation happens AS you build, not after.** If you write code, you write docs in the same commit. If you change behavior, you update docs in the same commit. There is no "we'll document it later."

---

## Why This Matters

{PROJECT_NAME} is built across multiple machines, multiple IDEs, and multiple AI tools. If it's not documented, it doesn't exist. If it's documented wrong, it's worse than not existing.

**The AI is the primary builder** (see `CODE_STANDARDS.md` -- Development Model). Architecture docs are its build spec. Documentation quality directly determines code quality.

---

## Documentation Types

### 1. Inline Code Documentation (Every Commit)

| What | When | Format |
|------|------|--------|
| File purpose comment | Every new file | 1-3 line comment at top |
| Exported function docs | Every exported function | JSDoc with @param, @returns |
| Complex logic comments | Non-obvious logic | Inline comment explaining WHY |
| TODO/FIXME markers | Deferred work | `// TODO:` or `// FIXME:` with context |

Defined in detail in `CODE_STANDARDS.md`.

### 2. README.md (Every Significant Directory)

Every directory a developer or AI tool might enter should have a README answering: **What is this?** / **How do I set it up?** / **How do I use it?** / **What should I know?**

**Create READMEs for:** every repo root, every major feature directory. Not every tiny utility folder.
**Update READMEs when:** setup steps, commands, or entry points change, or when the existing README would confuse a reader.

### 3. AGENTS.md (Every Directory That AI Tools Enter)

AGENTS.md files are routers for AI tools. **Update when:** you add a new subdirectory, add a key file, change routing, or introduce cross-component dependencies.

### 4. ARCHITECTURE.md (Per Component)

Describes the **current state** of the component -- what it does, how it works, how it connects to others. NOT a decision log (rationale lives in `decisions/`). Reference decision records by ADR number.

**YAML frontmatter required:**
```yaml
---
last-verified: 2026-02-27
verified-by: cascade
---
```

**Maturity tags on buildable sections:**

| Tag | Meaning |
|-----|---------|
| `DECIDED` | Designed, zero code. Blueprint only. |
| `BUILDING` | Actively being built. Clear when done. |
| `SCAFFOLDED` | Skeleton exists -- types, stubs, interfaces. Not functional. |
| `ALPHA` | Core works. Not fully tested or production-ready. |
| `SHIPPED` | Implemented, tested, integrated. |
| `HARDENED` | Production-proven. Edge cases handled. Monitoring in place. |

**Format:** `### Feature Name (SHIPPED)`. Tag sections describing buildable systems/features. Don't tag informational sections (principles, tech stack, scope, cross-references).

**Progression:** Update tags in the same commit as code changes. A `DECIDED` section with working code is a documentation bug. If `BUILDING` persists 7+ days with no progress, reset to `DECIDED` and note why.

**When to update:** behavior changes, new subsystems, technology changes, cross-component dependency changes, maturity changes.

**How to update:** describe current state, reference ADRs by ID (never duplicate decision content), update frontmatter timestamps, ensure maturity tags reflect reality.

**CRITICAL: If you change code but don't update ARCHITECTURE.md, the documentation is now wrong.**

### 4b. Architecture Decision Records (decisions/)

Every significant architecture decision gets its own file in `decisions/`. See `decisions/_TEMPLATE.md` for format and `decisions/README.md` for the index.

**Qualifies as ADR:** technology choices, architectural patterns, business model decisions, security decisions, process decisions.
**Does NOT need ADR:** bug fixes, implementation details, refactors that don't change behavior, UI polish.

**Decision Record Lifecycle:**

| Status | Meaning | Can Edit? |
|--------|---------|-----------|
| `proposed` | Under discussion | Yes, freely |
| `accepted` | Agreed upon, ready for implementation | Yes, with Decision History entry |
| `implemented` | Code matches the decision, verified | Yes, with Decision History entry |
| `deprecated` | No longer relevant | Only to mark deprecated |

**ADRs are living documents.** Update in place -- never create a new ADR to supersede an old one. The Decision section always reflects the current decision; the Decision History section records every change. Git preserves the full audit trail.

**Archiving:** When an ADR is fully absorbed into another, move it to `decisions/archive/` with full original content. Update the README index. ADR number gaps are expected.

**ADR vs. ARCHITECTURE.md:**

| Content | Where | Why |
|---------|-------|-----|
| Decisions and reasoning | ADR | Rationale is the ADR's job |
| Buildable specs (schemas, APIs, directory trees) | ARCHITECTURE.md | Specs change with implementation |
| Trade-offs and constraints | ADR | Stable reasoning |
| Implementation status | ADR (checklist) | Tracks progress |

**ADRs must not contain buildable specifications.** Structural details belong in ARCHITECTURE.md.

**YAML frontmatter required:**
```yaml
---
id: ADR-NNNN
title: Short descriptive title
status: proposed | accepted | implemented | deprecated
date: YYYY-MM-DD
last-updated: YYYY-MM-DD
affects: []
last-verified: null
verified-by: null
---
```

**Decision History section (required, bottom of every ADR):**
```markdown
## Decision History
| Date | Change | Reason |
|------|--------|--------|
| 2026-02-24 | Initial decision | [Original context] |
```

### 4c. Verification Stamps

Every ARCHITECTURE.md and decision record has `last-verified` and `verified-by` in frontmatter.

**Verification rule:** Before starting work on any component, read its ARCHITECTURE.md. Spot-check 2-3 claims (a type definition, an integration point, a behavioral assertion) against actual code. If accurate, update timestamps. If inaccurate, **fix the doc first.**

**Staleness:** If `last-verified` is 30+ days old, verify before relying on it. Any AI tool or human can verify.

**Alignment rule:** If implementation deviates from ARCHITECTURE.md, determine which is wrong before proceeding.

### 4d. Architecture Composability (Layer 1)

| File | Required? | Purpose |
|------|-----------|---------|
| `ARCHITECTURE.md` | Yes, if component has sub-components or significant decisions | Current state, decisions, status |
| `AGENTS.md` | Yes, always | AI routing |
| `README.md` | Only if dir is a code package | Human setup/dev instructions |

**Self-contained context rule:** Reading a component's ARCHITECTURE.md and AGENTS.md must be sufficient to understand it without reading the parent.

Each ARCHITECTURE.md must include: purpose (1-2 paragraphs), sub-components with descriptions, key decisions or ADR references, integration points, implementation status, V1 scope.

### 4e. The Fractal Rule

The documentation pattern repeats at every level of nesting. Parent docs contain cross-cutting concerns and a component map. Child docs are self-contained for their domain. Layer 1 (documentation composability) is defined here. Layer 2 (code composability) is defined in `CODE_STANDARDS.md`.

### 4f. ToDos.md (The Inbox)

Running backlog of ideas, improvements, bugs, and features NOT yet fully designed.

**Belongs:** feature ideas, bugs noticed during work, research tasks, items needing promotion into architecture.
**Does NOT belong:** build status (use maturity tags), decision rationale (use ADRs), duplicates of architecture sections.

**Lifecycle:** Idea -> discussed/designed -> ADR if needed -> ARCHITECTURE.md section as (DECIDED) -> ToDos.md item DELETED (not checked off). ToDos.md is ephemeral; resolved items are removed entirely. History lives in git.

### 5. CHANGELOG.md (Per Repo)

Format: Keep Unreleased section with Added/Changed/Fixed/Removed subsections.
**Add entries for:** feature additions, behavior changes, bug fixes, dependency updates affecting behavior.
**Skip:** reformatting, comment updates, test-only changes.

### 6. API Documentation

**Principle: The types ARE the docs.** API docs are auto-generated from TypeScript types and Zod schemas.

Every API procedure must have: JSDoc comment (1-2 sentences), Zod input schema with `.describe()` on every field, output schema, standardized error codes.

You don't update API docs separately -- update the code and docs update themselves. But you MUST add validation/descriptions when creating procedures and update them when behavior changes (same commit).

### 7. External User Documentation (When Features Ship)

For user-facing features: help text in UI (tooltips, placeholders, empty states), feature descriptions for marketing/help/onboarding, clear non-technical actionable error messages.

---

## The Same-Commit Rule

**If you change code, you update docs in the same commit.**

| Code Change | Required Doc Update |
|------------|-------------------|
| New file | File purpose comment |
| New exported function | JSDoc block |
| New feature directory | README.md |
| Architecture decision change | ARCHITECTURE.md |
| Bug fix | CHANGELOG entry |
| Feature addition | CHANGELOG + inline docs |
| Behavior change | CHANGELOG + affected docs |

If an AI tool skips the doc update, it is violating this standard.

---

## The Documentation Review Checklist

- [ ] New files have a purpose comment at the top
- [ ] New exported functions have JSDoc
- [ ] Complex logic has explanatory comments
- [ ] README.md is current for affected directories
- [ ] AGENTS.md is current if directory structure changed
- [ ] ARCHITECTURE.md is current if design decisions changed
- [ ] CHANGELOG.md has an entry for user-visible changes
- [ ] Error messages are clear and actionable
- [ ] No stale documentation left behind
- [ ] Decision records exist for architecture decisions (valid YAML frontmatter)
- [ ] ARCHITECTURE.md references ADRs by ID (not restated)
- [ ] `last-verified` updated in any ARCHITECTURE.md you confirmed as accurate
- [ ] `decisions/README.md` index updated for new decision records
- [ ] New component directories have AGENTS.md and ARCHITECTURE.md (if significant)
- [ ] Component ARCHITECTURE.md is self-contained (readable without parent)

---

## The Push-Back Protocol for Documentation

**You MUST flag when:**
- A code change affects behavior but no docs are being updated
- A README is stale or an ARCHITECTURE.md contradicts the implementation
- A new feature has no inline documentation
- Error messages are technical jargon instead of user-friendly text
- A CHANGELOG entry is missing for a significant change

Flag it, fix it now. Don't defer.

---

## What Good Documentation Looks Like

```typescript
// GOOD file header:
/** Billing pre-flight service. Checks user balance before any LLM call
 *  to enforce hard pre-pay limits. Called by the LLM router on every request. */

// GOOD function doc:
/** Check if a user has sufficient balance for an estimated LLM request.
 *  Includes a 5% buffer -- allows the request but flags it as last before hard stop.
 *  @param userId - The authenticated user's ID
 *  @param estimatedCost - Estimated cost in USD cents
 *  @returns { allowed, remainingBalance, isLastRequest } */

// GOOD inline comment (explains WHY, not WHAT):
// Check permissions BEFORE loading content to avoid leaking metadata
// (like file existence) to unauthorized users. See: ARCHITECTURE.md -- Data Permissions
if (!await userCanAccess(userId, documentId)) {
  throw new PermissionDeniedError({ userId, documentId });
}
```
