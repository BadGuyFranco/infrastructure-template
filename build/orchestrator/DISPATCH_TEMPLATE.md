# Dispatch Prompt Template

Copy-paste reference for structuring sub-agent prompts. See `../AGENTS.md` for dispatch rules and model routing.

## Dispatch Modes

| Tool | How It Works |
|------|-------------|
| **Claude Code** | Lead (Opus) spawns sub-agents via the Agent tool. Automated. Parallel supported. Lead reviews output in same session. |
| **Cursor** | Lead writes the prompt. Founder pastes into new context window. Sequential only. |

## Template

```
## Pre-flight Reads
[Exact file paths to read first -- always include AGENTS.md, ARCHITECTURE.md, CODE_STANDARDS.md]

## Context
[What's already built. Current state. Why this work is needed.]

## Task
[Specific, verifiable objective. What "done" looks like.]

## Scope
- Files to create or modify: [exact paths]
- Files NOT to touch: [explicit exclusions]

## Rules
- Follow build/standards/CODE_STANDARDS.md
- [Task-specific constraints]
- [Testing requirements]

## Verification
Run before returning:
- {YOUR COMMANDS} -- typecheck
- {YOUR COMMANDS} -- test
- If any test fails: fix, rebuild, re-test until green. Report what failed and how it was fixed.

## Self-Review
Before returning, review your work:
- What are you worried about? Fix it or flag it.
- Cross-reference one type and one behavior against the component's ARCHITECTURE.md.
- Follow build/standards/DOCUMENTATION_STANDARDS.md same-commit rule.

## Completion Report
When done, report:
- What was built (1-2 sentences)
- Test results (count, pass/fail)
- Issues found and deferred (if any)
- Confidence level and concerns
```

## Dependency Order

When dispatching work that spans services, respect the build order defined in your project's dependency graph. Example for a typical services monorepo:

shared > database > auth > security > billing > file-sync > llm-gateway > search > smart-layer > execution > scheduler > messaging > api > server
