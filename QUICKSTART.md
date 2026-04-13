# Getting Started

How to go from "I have this template" to "I'm building."

## Step 1: Replace Placeholders

Find and replace these placeholders across all files:

| Placeholder | Replace With | Example |
|-------------|-------------|---------|
| `{PROJECT_NAME}` | Your project's display name | "Acme Platform" |
| `{project-name}` | Kebab-case slug | "acme-platform" |
| `{PROJECT_ROOT}` | Absolute path to project root | `/Users/me/acme-platform` |
| `{MONOREPO_ROOT}` | Absolute path to monorepo root | `/Users/me/acme-platform` |
| `{FOUNDER_NAME}` | Your name | "Jane" |
| `{GCP_PROJECT_ID}` | GCP project ID (if using GCP) | "acme-prod-123" |
| `{GCP_REGION}` | GCP region | "us-central1" |
| `{API_STAGING_URL}` | Staging API base URL | "https://staging.acme.com" |
| `{DATE}` | Today's date | "2026-03-30" |

Placeholders you can leave until the relevant system is set up: `{API_STAGING_URL}`, `{ORG_NAME}`, `{ORG_SLUG}`, `{ORG_UUID}`, `{SYSTEM_USER_UUID}` (ticketing system -- see Step 6).

## Step 2: Verify Dependencies

1. Follow `DEPENDENCIES.md` to install the required runtime (Node.js 20+, pnpm, Git).
2. Follow `build/ENVIRONMENT.md` to set up CLIs and auth (GitHub CLI, cloud provider CLI, Claude Code).
3. Run the verification checklist at the bottom of `ENVIRONMENT.md` to confirm everything works.

## Step 3: Set Up Your Monorepo

Create your workspace packages (see the Component Map template in `ARCHITECTURE.md`). Each package needs at minimum:

- `package.json`
- `AGENTS.md` (AI routing)
- `ARCHITECTURE.md` (if the component has significant decisions or sub-components)

Add a root `package.json` with pnpm workspace configuration and a `turbo.json` for task orchestration.

## Step 4: Fill In Your Project Context

1. **`ARCHITECTURE.md` (root):** Fill in "What {PROJECT_NAME} Is", Platform Principles, and Component Map.
2. **`build/PRIORITIES.md`:** Replace the example priority with your actual first priority.
3. **`build/AGENTS.md` -- Local Development Commands:** Add your actual dev server, typecheck, test, and lint commands.
4. **`build/standards/CODE_STANDARDS.md`:** Replace all `{YOUR COMMANDS}` placeholders with actual commands.
5. **`build/standards/VERIFICATION.md`:** Replace `{YOUR COMMANDS}` with your typecheck and test commands.

## Step 5: First Session

1. Open Claude Code in your project root.
2. The AI reads `AGENTS.md` and defaults to the Bob persona.
3. Bob reads `build/PRIORITIES.md` to see what to work on.
4. Build. Bob follows CODE_STANDARDS and uses the done-gate checklist when finishing work.
5. At session end, Bob executes the session-end checklist.

That's it. The rest of the infrastructure grows with your project.

## Step 6: Set Up Later (When Needed)

**Ticketing system** (`build/TICKETS.md`): Requires a running API with ticket endpoints. Until then, use GitHub Issues or a simple markdown log. Replace the `{API_STAGING_URL}`, `{ORG_NAME}`, `{ORG_SLUG}`, `{ORG_UUID}`, and `{SYSTEM_USER_UUID}` placeholders when your ticket API is live.

**Oscar orchestration** (`build/build-personas/oscar.md`): Requires macOS with tmux and iTerm2. See oscar.md -- Platform Requirements for setup and non-Mac alternatives.

**Testing layers 2-5** (`build/quality/testing/ARCHITECTURE.md`): The testing architecture describes 5 layers. Only Layer 1 (unit tests) is immediately actionable for new projects. Layers 2-5 are design specifications to implement as your project matures.

## What to Adopt When

| Phase | What to Use | Why Now |
|-------|------------|---------|
| **Day 1** | AGENTS.md routing, PRIORITIES.md, bob.md, CODE_STANDARDS, done-gate, session-end | Minimum structure for consistent builds |
| **Week 2** | Plans system, SESSION_LOG, DOCUMENTATION_STANDARDS, dispatch templates | Multi-session work needs persistent tracking |
| **Month 1** | Talia (QA), QA dispatch, testing architecture, ADRs | Quality verification becomes a real concern |
| **Mature** | Oscar (orchestration), full checklist system, architecture reviews | Process oversight adds value at scale |
