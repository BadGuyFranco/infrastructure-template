# Infrastructure Template

[![Validate Template](https://github.com/BadGuyFranco/infrastructure-template/actions/workflows/validate-template.yml/badge.svg)](https://github.com/BadGuyFranco/infrastructure-template/actions/workflows/validate-template.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A production-grade project infrastructure template for teams building with [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Multi-persona AI build system with orchestration, quality checklists, and native Claude Code integration.

Built from the system used to ship [CoBuilder](https://cobuilder.me) -- extracted, templatized, and open-sourced.

## What This Is

A ready-to-use project scaffold that gives you:

- **A persona system** -- named AI roles (Builder, QA Specialist, Build Orchestrator) with distinct tool permissions, behavioral constraints, and context disciplines
- **Native Claude Code integration** -- `.claude/agents/`, `.claude/rules/`, `.claude/hooks/`, and `.claude/settings.json` configured out of the box
- **An orchestration layer** -- Oscar (build orchestrator) drives Bob (builder) via tmux, evaluating work quality while the founder watches
- **A checklist system** -- procedural steps loaded at the moment they matter, not memorized at session start
- **A complete build process** -- priorities, plans, session logs, standards, dispatch templates, and quality gates

## The Persona System

```
┌─────────────────────────────────────────────────────┐
│                     Founder                          │
│              (watches both terminals)                │
└──────────┬──────────────────────┬───────────────────┘
           │                      │
           │ picks priority       │ reads Oscar's
           │ makes decisions      │ terminal directly
           ▼                      │
┌─────────────────────┐           │
│       Oscar          │           │
│  Build Orchestrator  │           │
│  (Claude Code/Opus)  │           │
│                      │           │
│  - Reads process     │           │
│    artifacts         │           │
│  - Evaluates work    │           │
│  - Cannot edit code  │           │
│  - Drives Bob via    │           │
│    tmux              │           │
└──────────┬──────────┘           │
           │                      │
           │ send-to-bob.sh       │
           ▼                      │
┌─────────────────────┐           │
│        Bob           │◄──────────┘
│  Builder / Architect │
│  (Claude Code/Opus)  │
│                      │
│  - Writes code       │
│  - Runs tests        │
│  - Updates docs      │
│  - Dispatches Talia  │
│    for QA            │
└──────────┬──────────┘
           │
           │ sub-agent dispatch
           ▼
┌─────────────────────┐
│       Talia          │
│   QA Specialist      │
│  (Claude Code sub-   │
│   agent / Sonnet)    │
│                      │
│  - Spec-first        │
│    verification      │
│  - Cannot edit code  │
│  - Context-isolated  │
│    from Bob          │
└─────────────────────┘
```

**Why personas?** A single AI session accumulates context bias -- it becomes invested in its own approach. Structural separation (Oscar can't see Bob's code reasoning; Talia derives expectations from specs, not implementations) creates genuine independence. Oscar pushes Bob harder because he evaluates outcomes, not effort.

## Quick Start

```bash
# 1. Clone
git clone https://github.com/BadGuyFranco/infrastructure-template.git my-project
cd my-project

# 2. Run setup (interactive -- asks for project name, paths, accounts)
./setup.sh

# 3. Install dependencies (if using TypeScript checks)
# npm install  # or pnpm install

# 4. Start building
claude --agent bob
```

See [QUICKSTART.md](QUICKSTART.md) for the full walkthrough from clone to first orchestrated session.

## Directory Structure

```
.claude/
  agents/           # Persona definitions (bob.md, oscar.md)
  hooks/            # PostToolUse hooks (code hygiene checks)
  rules/            # Path-scoped coding standards (auto-load on file read)
  skills/           # Persona-specific checklist skills
  settings.json     # Project-level permissions, env vars, hooks

build/
  PRIORITIES.md     # What to build and why, in order
  SESSION_LOG.md    # Session handoff notes
  ENVIRONMENT.md    # Machine setup, Claude Code config, tool versions
  TICKETS.md        # Bug/task tracking convention
  plans/            # Structured execution plans
  standards/        # Code, documentation, and verification standards
  orchestrator/     # Dispatch templates for sub-agents
  quality/          # Testing architecture and review checklists
  build-personas/
    bob.md          # Builder playbook (instincts, rules, routing)
    oscar.md        # Orchestrator playbook
    talia.md        # QA specialist playbook
    _PERSONA_TEMPLATE.md
    Orchestrator-V3.command  # Double-click launcher
    checklists/     # Procedural steps for specific workflow moments
    scripts/        # Deterministic checks and tmux infrastructure

decisions/          # Architecture Decision Records (ADRs)
AGENTS.md           # Project entry point (personas, routing, conventions)
ARCHITECTURE.md     # System architecture overview
```

## Key Concepts

### AGENTS.md Convention

Every directory has an `AGENTS.md` as its entry point. When entering a directory, read its `AGENTS.md` before reading code or making changes. This creates a navigation chain that works for both humans and LLMs.

### Three Types of Guidance

| Type | What It Is | Where It Lives |
|------|-----------|----------------|
| **Instincts** | Always-on judgment heuristics | Persona playbooks |
| **Rules** | Hard constraints (always/never) | Persona playbooks |
| **Checklists** | Ordered steps for a specific moment | `checklists/` directory |

Checklists are loaded fresh at trigger time -- not memorized at session start. This solves the LLM attention problem: procedural steps buried in long documents get skipped under context pressure.

### Claude Code Integration

The template uses Claude Code's native features:

- **Agent files** (`.claude/agents/*.md`) -- frontmatter defines model, effort level, permission mode, disallowed tools, and hooks per persona
- **PreCompact hooks** -- inject preservation rules before context compaction so personas retain critical state
- **Path-scoped rules** (`.claude/rules/*.md`) -- coding standards that auto-load when matching files are read
- **Project settings** (`.claude/settings.json`) -- env vars that disable 1M context, adaptive thinking, and auto-memory for predictable sessions
- **PostToolUse hooks** -- async code hygiene checks after every file edit

### The Orchestrator

`Orchestrator-V3.command` is a double-click launcher that:

1. Lets you pick a Claude Code account (multi-account support)
2. Parses `PRIORITIES.md` and shows a priority menu
3. Launches Bob in a tmux session with auto-restart
4. Launches Oscar in a separate tmux session
5. Opens iTerm with side-by-side panes
6. Sends Oscar the initial prompt with the selected priority
7. Prevents system sleep while sessions are running

Oscar drives Bob autonomously within a priority. The founder watches, makes judgment calls, and intervenes when needed.

## Customization

After running `setup.sh`:

1. **Add your dev commands** to `build/AGENTS.md` (Local Development Commands section)
2. **Add workspace packages** to `AGENTS.md` (Code Repository table)
3. **Add cloud config** to `build/ENVIRONMENT.md`
4. **Create your first priority** in `build/PRIORITIES.md`
5. **Add project-specific personas** using `build/build-personas/_PERSONA_TEMPLATE.md`
6. **Add path-scoped rules** in `.claude/rules/` for your coding standards

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (standalone installer)
- Node.js >= 20 (for TypeScript checks and scripts)
- tmux + iTerm2 (for Oscar orchestration -- macOS; see ENVIRONMENT.md for Linux/WSL)
- GitHub CLI (`gh`) recommended

## License

MIT -- see [LICENSE](LICENSE).
