# QA Dispatch Template

Copy-paste reference for dispatching the QA specialist as a sub-agent. See `../AGENTS.md` for general dispatch rules and model routing. See `../build-personas/talia.md` for the QA specialist's full playbook.

## How Context Isolation Works

This template deliberately excludes builder implementation context. The QA specialist receives the spec and acceptance criteria, NOT the builder's implementation notes, confidence level, or summary of what was built. This separation is the primary safeguard against rubber-stamping -- if the tester knows what the builder thinks is working, they will unconsciously verify those claims rather than independently probing for failure.

**Do not add:** implementation summaries, "here is what I built" notes, confidence assessments, or suggested test areas. If it biases the tester, it does not belong.

## Dispatch Modes

| Tool | How It Works |
|------|-------------|
| **Claude Code** | Lead (Opus) spawns QA specialist as sub-agent via the Agent tool. Lead reviews QA Report in same session. |
| **Cursor** | Lead writes the prompt. Founder pastes into new context window. Sequential only. |

## Template

```
## Pre-flight Reads
[Exact file paths -- always include:]
- Component's AGENTS.md
- Component's ARCHITECTURE.md
- build/standards/CODE_STANDARDS.md
- build/build-personas/talia.md

## Context
[Spec-only context. Reference the ARCHITECTURE.md sections and ADRs that define expected behavior.
Do NOT include: builder's implementation notes, confidence level, or summary of what was built.]

- Component: [name and path]
- Spec references: [ARCHITECTURE.md sections, ADR numbers]
- Acceptance criteria: [specific, verifiable conditions that must be true]

## Task
Verify that implemented behavior matches the spec for [criteria].
Report what passes, what fails, what is ambiguous, and what was not testable.

## Dispatch Type
[build verification / E2E / regression sweep / scenario testing]

For scenario testing dispatches, also include:
- Scenario YAML path (from quality/testing/scenarios/scenarios/)
- Environment mode (local / staging)
- Expected preconditions (test user, credit balance, seeded state)

## Scope
- Files to read/test: [exact paths]
- Files NOT to modify: [QA specialist never modifies code under test -- this is a hard rule]
- Test commands: [specific commands to run]

## Mandatory Pre-step
Run deterministic checks before LLM-driven verification:
{YOUR COMMANDS}

## Output
Produce a QA Report per the format defined in the QA playbook:
- Deterministic checks (output from mandatory pre-step -- include full output)
- Verdict: PASS / CONDITIONAL PASS / BLOCK
- Tests run (count, pass/fail)
- Failures (expected vs actual, reproduction steps)
- Anomalies (passed but concerning)
- Probe log (what was tested that did not fail)
- Deferred (what could not be tested and why)
```

## Dependency Order

When dispatching QA work that spans services, respect the dependency order for test sequencing defined in your project's dependency graph.
