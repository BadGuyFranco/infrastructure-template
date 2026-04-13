# Build Personas

Persona-specific playbooks for the build process. Each persona has: instincts (always-on judgment heuristics), operational rules (hard constraints), communication style, and routing to checklists (procedural steps for specific workflow moments).

Shared process (dev commands, routing, dispatch, session lifecycle) lives in `../AGENTS.md`. Persona identity and act-vs-ask rules live in `../../AGENTS.md`. This directory holds the operational playbooks -- how each persona thinks and works during a session.

## Active Personas

| Persona | Playbook | Focus |
|---------|----------|-------|
| Bob | `bob.md` | Builder / orchestrator / architect. Systems thinking, production-quality code, documentation rigor. |
| Talia | `talia.md` | QA specialist. Test plans, E2E verification, integration testing, regression sweeps, post-build integrity checks. |
| Oscar | `oscar.md` | Build orchestrator. Asks the founder's questions so the founder doesn't have to. Conversation-driven process oversight via Claude Code (Opus 4.6). |

## Adding a New Persona

1. Create a new `.md` file in this directory named after the persona (lowercase). Use `_PERSONA_TEMPLATE.md` as a starting point.
2. Structure it with these sections: Routing (to checklists), Instincts (always-on heuristics), Operational Rules (hard constraints), Communication, Session Startup.
3. Create a `.claude/agents/{persona}.md` file with frontmatter (model, effort, permissionMode, disallowedTools, hooks). See existing agent files for the format. This is how Claude Code identifies and configures the persona at launch.
4. Add a row to the table above
5. Add the persona to the Personas section in `../../AGENTS.md` (identity and act-vs-ask)
6. Add a one-line summary to `../../../AGENTS.md` (top-level)
7. Create a subdirectory in `checklists/` for the persona's workflow checklists
8. If the persona is an orchestrator (like Oscar), add tmux scripts in `scripts/{persona}/` and update `Orchestrator-V3.command` with a menu entry

Each persona starts with a clean instinct set. Corrections are absorbed directly into persona instincts during the session they occur (see bob.md "Absorb corrections immediately"). Do not copy another persona's instincts unless they genuinely apply.

## Shared: Ticketing

All personas use the ticketing system for tracking bugs, tasks, features, and support requests. Convention and enum values are in `../TICKETS.md`. See `../TICKETS.md` for curl command examples. Each persona's playbook documents what types of tickets they file and when. Always check existing open tickets before filing to avoid duplicates.

## Persona Checklists

Procedural step sequences for specific workflow moments. If it's an ordered sequence of steps that must all execute at a specific moment, it's a checklist -- not an instinct.

Checklists live in `checklists/` with one subdirectory per persona. See `checklists/AGENTS.md` for the conventions, format template, and full index.

| Persona | Checklists | Key Triggers |
|---------|-----------|--------------|
| Bob | `checklists/bob/` | Done gate, deploy, close priority, session end, infra changes |
| Oscar | `checklists/oscar/` | Session start, session end, phase transitions, pre-planning eval, persona system audit, codebase audit, housekeeping, concurrency picks, ticket review, priority complete, session abort |
| Talia | `checklists/talia/` | Dispatch entry (first steps of any dispatch) |

## Persona Scripts

Deterministic checks that personas own and run. If a verification can be deterministic, it must be a script -- not an instinct the LLM might skip.

Scripts live in `scripts/` with one subdirectory per persona. See `scripts/AGENTS.md` for the framework, output format, and template.

| Persona | Scripts | When to Run |
|---------|---------|-------------|
| Bob | `scripts/bob/` | `check-session-ready` at startup, `check-code-hygiene` after builds, `check-commit-ready` before commits |
| Talia | `scripts/talia/` | `run-all` as mandatory first step before any LLM-driven QA verification |
| Oscar | `scripts/oscar/` | Launch infrastructure (`launch-bob.sh`, `wait-for-bob.sh`) and Bob interaction (`send-to-bob.sh` with behavioral re-anchoring). Launched via `Orchestrator-V3.command`. |

```bash
# Run all checks for a persona
npx tsx build/build-personas/scripts/<persona>/run-all.ts

# Run a single check
npx tsx build/build-personas/scripts/bob/check-session-ready.ts
```
