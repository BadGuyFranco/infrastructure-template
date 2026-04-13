# {PROJECT_NAME} -- Architecture Decision Records

This directory contains all architecture decisions for {PROJECT_NAME}. Each decision is a standalone, numbered, living document with a lifecycle status.

**Rules:**
- One decision per file. Each file follows `_TEMPLATE.md`.
- **ADRs are living documents.** When a decision evolves, update the existing ADR in place. Do not create a new ADR for the same concept.
- Every change to an accepted ADR requires a Decision History entry (date, what changed, why).
- ADRs contain reasoning and trade-offs. Buildable specs (directory trees, schemas, config formats) belong in ARCHITECTURE.md.
- Status lifecycle: `proposed -> accepted -> implemented -> deprecated`
- Git preserves the full history of every ADR version for audit purposes.

---

## Decision Index

| ID | Title | Status | Date | Affects |
|----|-------|--------|------|---------|
| <!-- [ADR-0001](0001-your-first-decision.md) --> | <!-- Title --> | <!-- proposed/accepted/implemented/deprecated --> | <!-- YYYY-MM-DD --> | <!-- components --> |

---

## Categories

Use these categories to organize decisions as the index grows:

| Category | Covers |
|----------|--------|
| **Product** | Vision, interaction model, user model, pricing |
| **Architecture** | Tech stack, service decomposition, data model, API design |
| **Infrastructure** | Hosting, CI/CD, environments, monitoring |
| **Security** | Auth, permissions, credential management, data isolation |
| **Process** | Documentation standards, build process, testing strategy |

## Quick Filters

**By status:**
- **Implemented:** (none yet)
- **Accepted:** (none yet)
- **Proposed:** (none yet)
- **Deprecated:** (none yet)

**By component:**
<!-- Update these as components are defined:
- **Services:** ADR-...
- **Frontend:** ADR-...
- **Infrastructure:** ADR-...
-->

## Numbering Convention

- ADRs are numbered sequentially: `0001`, `0002`, `0003`, ...
- Never reuse a number, even if the ADR is deprecated.
- Archived/superseded ADRs move to `archive/` but retain their number.
- The README index always includes all ADRs regardless of status.
