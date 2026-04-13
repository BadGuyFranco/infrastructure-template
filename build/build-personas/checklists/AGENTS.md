# Checklists

Procedural step sequences that personas execute at specific workflow moments. Each checklist is a focused document loaded on-demand -- not at session start.

## Why Checklists Exist

The build process has three types of guidance:

| Type | What It Is | Where It Lives | How the LLM Uses It |
|------|-----------|----------------|---------------------|
| **Instincts** | Heuristics that shape judgment. Always on. | Persona playbook (`bob.md`, etc.) | Internalized at session start, applied through reasoning |
| **Rules** | Hard constraints. Always/never. | Persona playbook (Operational Rules) | Matched against actions as guardrails |
| **Checklists** | Ordered steps for a specific workflow moment. | This directory | Loaded fresh at the trigger point, executed sequentially |

**The problem checklists solve:** Procedural steps buried in long persona documents get skipped under context pressure. The LLM's attention moves on. Checklists are loaded at the moment they matter, so they get full attention.

**The principle:** If it's a sequence of steps that must all execute in order at a specific moment, it's a checklist. If it's a judgment heuristic that shapes thinking, it's an instinct. If it's a mechanical verification, it's a script.

## Format

Every checklist follows this structure:

```markdown
# [Checklist Name]

**Trigger:** [When to run this checklist -- the workflow moment]
**Persona:** [Who runs it]

## Steps

1. **[Action name].** [Clear instruction with exact commands if applicable]
2. **[Action name].** [Clear instruction]
...

## Gate

[What must be true before moving on. The completion condition.]
```

- **Numbered steps, not bullets.** Numbers signal sequence. Every step executes in order.
- **Gate section at the end.** Prevents the LLM from skipping the last few steps -- the gate is the proof that all steps ran.
- **Self-contained.** Each checklist includes enough context to execute without re-reading the persona playbook. Reference specific commands, file paths, and script names.

## Structure

```
checklists/
  AGENTS.md              -- this file
  shared/                -- Cross-persona checklists (referenced by multiple personas)
  bob/                   -- Bob's workflow checklists
  oscar/                 -- Oscar's workflow checklists
  talia/                 -- Talia's workflow checklists
  {persona}/             -- Additional persona checklists as needed
```

Shared checklists are referenced from multiple persona routing tables or playbooks. They are not persona-specific -- any persona that needs the procedure can reference it.

## How Personas Use Checklists

Each persona playbook has a **Routing** table that maps workflow moments to checklists:

```markdown
## Routing

| When | Checklist |
|------|-----------|
| Reporting work as complete | `checklists/bob/done-gate.md` |
| End of session | `checklists/bob/session-end.md` |
```

When the persona reaches that workflow moment, they read and execute the checklist. The checklist is fresh context -- it gets full attention because it was just loaded, not remembered from session start.

## How to Add a New Checklist

1. Create a new `.md` file in the persona's subdirectory
2. Follow the format above (trigger, steps, gate)
3. Add a row to the persona's **Routing table in their playbook** (e.g., `bob.md`, `oscar.md`)

## Meta-Rule

**If a procedure repeats, make it a checklist.** If you find yourself executing the same 3+ steps in the same order for the same kind of task, that's a checklist waiting to be extracted. Create the checklist, add it to the persona's routing table, and note it in the session log.

## Routing

**Checklist routing lives in the persona playbooks — not here.** Each persona's `.md` file has a Routing table that maps workflow moments to checklists. That table is the SSOT. Do not duplicate it here — duplicate routing tables drift (this file was already stale when this rule was added).

To find which checklists exist for a persona, read their playbook:
- Bob: `bob.md` -> Routing table
- Oscar: `oscar.md` -> Routing table
- Talia: `talia.md` -> Routing table
- Additional personas: `{persona}.md` -> Routing table
