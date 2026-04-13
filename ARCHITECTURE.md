---
last-verified: null
verified-by: null
---

# {PROJECT_NAME} Architecture -- Overview

This is the high-level architecture overview for {PROJECT_NAME}. It describes what the project is, the non-negotiable principles, how the components relate to each other, and where to find detailed architecture for each component.

**This document is current state only.** For rationale behind any decision, see the relevant decision record in `decisions/`. For the full index: `decisions/README.md`.

---

## What {PROJECT_NAME} Is

<!-- 2-3 sentence description of the product/system. What problem does it solve? Who is it for? What makes it different? -->

---

## Platform Principles

These are non-negotiable. Every component must respect them. They are repeated in each component's architecture doc where relevant.

<!-- Fill in your project's principles. Examples of common principles:

| Principle | Rule |
|-----------|------|
| **Portability** | Every service uses standard protocols. No vendor lock-in. Migration is annoying, never a rewrite. |
| **Premium UX** | Every interaction feels premium. Charge premium, deliver premium. |
| **Pre-pay only** | Users cannot exceed limits without paying first. Architecturally enforced. |
| **Per-user credentials** | Connector API keys/tokens are never shared. Always per-user, even within an organization. |
| **Permission-aware AI** | All data access including RAG respects user permissions. Built into schema from day one. |

Remove principles that don't apply, add your own. -->

---

## Component Map

<!-- Describe the high-level components and how they relate. Use an ASCII diagram and a responsibility table.

Example structure:

```
┌──────────────────────────────────────────────────────┐
│                  {PROJECT_NAME} System                │
│                                                       │
│  ┌──────────────┐    HTTPS/WS    ┌────────────────┐  │
│  │  Frontend     │◄─────────────►│  Services       │  │
│  │  (Web/App)    │               │  (Cloud backend) │  │
│  └──────────────┘               └────────┬────────┘  │
│                                          │            │
│                                          │ connects   │
│                                          │            │
│                                 ┌────────┴────────┐  │
│                                 │  Database        │  │
│                                 │  (Neon PostgreSQL)│  │
│                                 └─────────────────┘  │
└──────────────────────────────────────────────────────┘
```
-->

### Component Responsibilities

<!-- Fill in your components:

| Component | What It Does | Detailed Architecture |
|-----------|-------------|----------------------|
| **Frontend** | User-facing web application. | `{project-name}-web/ARCHITECTURE.md` |
| **Services** | Cloud backend. Auth, billing, API, business logic. | `{project-name}-services/ARCHITECTURE.md` |
| **Build** | Build process: code standards, documentation standards, testing architecture, orchestration, task tracking. | `build/AGENTS.md` |
-->

### How They Connect

<!-- Describe the protocols and patterns used for communication between components:

| Connection | Protocol | Purpose |
|-----------|----------|---------|
| Frontend <-> Services | **tRPC over HTTPS** | Type-safe API calls |
| Frontend <-> Services | **WebSocket** | Real-time updates, streaming |
-->

### Interface Contracts

<!-- Describe how components maintain compile-time and runtime safety across boundaries.

Common layers:
1. **tRPC** -- end-to-end TypeScript type safety for API routes
2. **Shared Types Package** -- WebSocket messages, event types, shared enums
3. **Contract Tests** -- runtime validation of cross-component behavior

Evolution rules:
- New fields are optional (backward compatibility)
- Removed fields go through deprecation
- New message types are additive
- Breaking changes require a version bump
-->

---

## Key Architectural Decisions (Summary)

Each decision is documented in full in its own decision record in `decisions/`. This table is for orientation only -- the ADR is the source of truth.

<!-- Fill in as decisions are made:

| Decision | Summary | ADR |
|----------|---------|-----|
| Tech stack | {description} | [ADR-0001](decisions/0001-tech-stack.md) |
| Auth strategy | {description} | [ADR-0002](decisions/0002-auth-strategy.md) |
-->

---

## Opinionated Stack

This project uses an opinionated infrastructure stack. See `DEPENDENCIES.md` for the full list with version requirements and verification commands.

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Runtime** | Node.js 20+ | LTS only |
| **Package manager** | pnpm | Workspace support required |
| **Language** | TypeScript | Strict mode |
| **Database** | Neon PostgreSQL | Serverless Postgres, branching for preview environments |
| **Auth** | BetterAuth | Self-hosted, social login, SSO-ready |
| **Cloud** | GCP (Cloud Run, GCS) | Project: `{GCP_PROJECT_ID}`, Region: `{GCP_REGION}` |
| **Payments** | Stripe (optional) | Pre-pay enforcement |
| **Monorepo** | pnpm workspaces + Turborepo | Shared types via workspace protocol |
| **Testing** | Vitest | Unit + integration, co-located with source |
| **Linting** | ESLint | Flat config |
| **CI/CD** | GitHub Actions | On push to main and PRs |

---

## CI/CD

<!-- Describe your CI/CD pipeline. Example:

**GitHub Actions CI** runs on every push to `main` and every pull request targeting `main`.

Pipeline: `pnpm install --frozen-lockfile` -> `turbo run typecheck` -> `turbo run test` -> verify-build checks

- Typecheck fails fast -- tests are skipped if any package has a TypeScript error.
- Tests run unit-only by default. Integration tests that require `DATABASE_URL` self-gate via `describe.skipIf`.
- No deploy steps -- deployment is a separate workflow.

Workflow file: `.github/workflows/ci.yml`
-->

---

## Maturity Stages

Use these tags in `ARCHITECTURE.md` Implementation Status tables and in `BUILD_STATUS.md` to communicate component maturity:

| Stage | Meaning |
|-------|---------|
| **not-started** | No code exists. Decision may or may not be made. |
| **scaffolded** | Directory, package.json, and ARCHITECTURE.md exist. No functional code. |
| **in-progress** | Active development. Some functionality works. |
| **mvp** | Minimum viable implementation. Works for the critical path. |
| **shipped** | Production-ready for V1 scope. Tests passing, docs current. |
| **mature** | Battle-tested. Edge cases handled. Performance optimized. |

---

## Verification Stamps

Every `ARCHITECTURE.md` carries YAML frontmatter with verification metadata:

```yaml
---
last-verified: YYYY-MM-DD    # when this doc was last checked against code
verified-by: human | claude   # who verified it
---
```

**Rule:** Before starting work on a component, read its `ARCHITECTURE.md`, spot-check 2-3 claims against code, and update the stamp. If claims are wrong, fix the doc before proceeding.
