# Build

Shared build process for all personas. Standards, orchestration, quality, and task tracking.

## Personas

Persona playbooks live in `build-personas/`. Read the playbook for your active persona before starting work.

| Persona | Playbook | Focus |
|---------|----------|-------|
| Bob | `build-personas/bob.md` | Builder / orchestrator / architect |
| Talia | `build-personas/talia.md` | QA specialist. Test plans, E2E, integration, regression, post-build integrity. |
| Oscar | `build-personas/oscar.md` | Build orchestrator. Process oversight via conversation-driven evaluation (Claude Code, Opus 4.6). |

If no persona is specified, default to Bob.

## Local Development Commands

<!-- {YOUR DEV COMMANDS}
Replace this section with your project's actual development commands.
Include:
- How to start the backend (e.g., dev server command, port, environment variables)
- How to start the frontend (e.g., dev server, web client)
- How to run typechecks, tests, and linting
- Service dependency order (if applicable)
- Any dev-bypass modes for auth or other subsystems

Guidelines:
- All commands should run from {MONOREPO_ROOT}
- These must be the ONLY correct commands. Do not let sub-agents invent alternatives.
- Specify the correct package manager (pnpm, npm, yarn) and runner (turbo, nx, lerna).
- Include health check URLs and expected outputs where applicable.
-->

## Design Principles

- **Completeness over compactness.** Do not split files, entries, or documents to hit arbitrary size limits. Optimize for completeness per purpose. A 40-line priority entry that fully scopes the planning process is better than a 5-line stub that forces re-discovery. Split when there is a genuine separation of concerns, not when a line count feels high.

## Session Weight Classes

Context tokens spent on process docs are tokens not available for code. Manage this actively.

| Weight | When | What to Read | Approx. Token Cost |
|--------|------|-------------|-------------------|
| **Light** | Quick fix, single-file change, bug with exact location | Persona playbook (skim), PRIORITIES.md (active entry only) | ~2,000 tokens |
| **Standard** | Feature work within one component, plan execution | Persona playbook, PRIORITIES.md, active plan (CURRENT STATUS only), SESSION_LOG (latest entry), component ARCHITECTURE.md | ~5,000 tokens |
| **Full** | Cross-component work, new priority research, architecture decisions | All Standard reads + CODE_STANDARDS, DOCUMENTATION_STANDARDS, relevant ADRs, multiple ARCHITECTURE.md files | ~10,000 tokens |

**Rules:**
- Default to Standard. Escalate to Full only when cross-component reasoning is needed.
- Never front-load all docs "just in case." The routing tables exist so you can find docs when you need them, not read them preemptively at startup.
- Checklists are loaded at trigger time, not session start. This is by design -- they get fresh attention and don't consume context during the build phase.
- If context is running low during a session, compact process docs first. Your judgments about the code matter more than the text that produced them.
- Oscar sessions are inherently lighter than Bob sessions: Oscar reads state files, not code. See `build-personas/oscar.md` -- Context Discipline.

## During a Session

- Update SESSION_LOG.md incrementally as you work, not just at the end. A partial entry is infinitely better than no entry.
- Fix bugs when you find them. File a ticket for every bug -- if already fixed, file it as resolved. For bugs fixed in under 5 minutes, the resolved ticket is the record, not a gate.

## Dispatch Rules and Model Routing

**Model routing:** The lead always runs on Opus.

| Model | When to Use | Examples |
|-------|-------------|----------|
| **Opus** | Cross-component reasoning, architecture decisions, debugging across boundaries | Wiring services, designing subsystems, root-cause across 10+ files |
| **Sonnet** | Clear task with moderate complexity, judgment needed | Building a service from spec, writing tests, refactoring a module |
| **Haiku** | Output clearly defined, no creativity needed | File exploration, pattern searching, config updates, boilerplate |

Default to Sonnet for coding. Haiku for exploration. Opus only for cross-component reasoning.

**Dispatch rules:**
1. One concern per agent. Multi-component tasks get split.
2. Include pre-flight reads: component's AGENTS.md, ARCHITECTURE.md, CODE_STANDARDS.md.
3. Include scope boundaries: what to touch, what NOT to touch.
4. Include verification commands: typecheck and test before returning.
5. Parallel when independent. Sequential when dependent.

**Dispatch template:** Use `orchestrator/DISPATCH_TEMPLATE.md` for the prompt structure.

## Session End

Every persona has a session-end checklist in `build-personas/checklists/<persona>/session-end.md`. Load and execute yours. The checklist is the SSOT for session-end procedure. Do not rely on memory -- load the checklist fresh.

## Self-Maintenance

**Every session:** Absorb corrections directly into permanent destinations (see bob.md "Absorb corrections immediately"). Verify dev commands are accurate before running them for the first time in a session. Self-improvement at session end is part of every persona's session-end checklist -- bias toward NOT editing unless certain the change will improve the next session.

**Periodic (founder-triggered or when drift is noticed):**
- Spot-check the routing chain: are all AGENTS.md routing tables pointing to valid destinations?
- Have any recent corrections been placed in the wrong destination or missed entirely? Spot-check persona playbooks and standards for consistency.
- Is this session file consistent with the current codebase state?
- grep for TODO/FIXME staleness
- grep for `as any` -- are any avoidable?
- Verify all cross-references in AGENTS.md files
- Verify all ARCHITECTURE.md verification stamps (<30 days)
- Flag drift to the founder.

## Key Documents

| Document | Purpose |
|----------|---------|
| `SESSION_LOG.md` | Session handoff. Reverse-chronological. What happened, what's unfinished, pickup instructions. |
| `PRIORITIES.md` | Priority stack. SSOT for what to work on and why, in order. |
| `standards/CODE_STANDARDS.md` | How we write code. Commenting, file organization, naming, refactor protocol, push-back rules. |
| `standards/DOCUMENTATION_STANDARDS.md` | How we document. Same-commit rule, doc types, decision record lifecycle, verification stamps. |
| `standards/VERIFICATION.md` | Component verification criteria and code review protocol. Post-build procedure is in `build-personas/checklists/bob/done-gate.md`. |
| `TICKETS.md` | Bug filing convention. How to use the integrated ticketing system. |
| `orchestrator/QA_DISPATCH_TEMPLATE.md` | QA dispatch template for Talia. Context isolation enforced -- spec only, no builder notes. |
| `ENVIRONMENT.md` | Local dev machine setup: tools, CLIs, settings, verification checklist. Not read every session -- on demand only. |
| `LESSONS.md` | Retired. Corrections now go directly to their permanent destination (see bob.md "Absorb corrections immediately"). |
| `ToDos.md` | Ephemeral inbox. Unvetted ideas, research tasks. Deleted once promoted or completed. |

## Contents

| Folder | Purpose |
|--------|---------|
| `standards/` | Code standards, documentation standards, and verification checklists |
| `orchestrator/` | Dispatch prompt template for sub-agent work |
| `quality/` | Testing architecture, reviews, security checklists |
| `plans/` | Structured execution plans for multi-session priorities |
| `build-personas/` | Persona-specific playbooks (instincts, rules, routing to checklists) |
| `build-personas/checklists/` | Procedural step sequences for specific workflow moments (done gate, deploy, session end, etc.) |
| `build-personas/scripts/` | Deterministic validation scripts per persona |

## Routing

- **Starting a session?** -> Read your persona playbook in `build-personas/`, then Session Startup from that playbook
- **Which persona?** -> `build-personas/AGENTS.md`
- **What are we doing and why?** -> `PRIORITIES.md`
- **What happened last session?** -> `SESSION_LOG.md`
- **How to write code?** -> `standards/CODE_STANDARDS.md`
- **How to document?** -> `standards/DOCUMENTATION_STANDARDS.md`
- **Reporting work as done?** -> `build-personas/checklists/bob/done-gate.md`
- **Code review protocol?** -> `standards/VERIFICATION.md`
- **How to dispatch a sub-agent?** -> `orchestrator/DISPATCH_TEMPLATE.md`
- **How to dispatch Talia for QA?** -> `orchestrator/QA_DISPATCH_TEMPLATE.md`
- **How to structure research?** -> `orchestrator/RESEARCH_DISPATCH.md`
- **Testing architecture, strategy, or test accounts?** -> `quality/testing/AGENTS.md`
- **Architecture review process?** -> `quality/reviews/architecture-review.md`
- **Corrections and quality patterns?** -> Directly in persona playbooks (`build-personas/`), standards, or AGENTS.md. No staging file.
- **Filing or tracking bugs?** -> `TICKETS.md` (convention + curl command examples)
- **Open tasks and ideas?** -> `ToDos.md`
- **Starting a multi-session priority?** -> Create a plan in `plans/` first. See `plans/AGENTS.md` for lifecycle.
- **Architecture visuals?** -> `standards/VISUALIZATION.md` for how to build them. Each component has a `diagrams/` folder (one file per visual, Mermaid or HTML). These are for the founder, not for LLM context.
- **Setting up a new machine?** -> `ENVIRONMENT.md`
- **Tool or CLI not working?** -> `ENVIRONMENT.md` (verification checklist)
- **Oscar's launch infrastructure or tmux scripts?** -> `build-personas/scripts/oscar/AGENTS.md`
- **Oscar's playbook or conversation flow?** -> `build-personas/oscar.md`
- **Deploying to staging or production?** -> `build-personas/checklists/bob/deploy.md`
- **Closing out a priority?** -> `build-personas/checklists/bob/close-priority.md`
- **Changing external infrastructure?** -> `build-personas/checklists/bob/infra-changes.md`
- **Checklist conventions or adding a new checklist?** -> `build-personas/checklists/AGENTS.md`
- **Scenario inventory for research/design?** -> `build-personas/checklists/shared/scenario-inventory.md`
- **Architectural health monitoring?** -> `build-personas/checklists/oscar/architectural-health.md`
