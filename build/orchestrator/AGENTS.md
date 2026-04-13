# Build Orchestrator

Dispatch prompt template and automation scripts for sub-agent work.

Session protocol, behavioral rules, dispatch rules, and model routing live in `../AGENTS.md` (the session file). This directory holds reference artifacts used during dispatch.

## Contents

| File | Purpose |
|------|---------|
| `DISPATCH_TEMPLATE.md` | Copy-paste prompt template for structuring sub-agent prompts |
| `QA_DISPATCH_TEMPLATE.md` | QA-specific dispatch template (context isolation enforced) |
| `RESEARCH_DISPATCH.md` | Reference menu for structuring research sub-agents |
| `CODEX_REVIEW_TEMPLATE.md` | Bolt-on section for adding a Codex (GPT) second-opinion review to any dispatch |

## Routing

- **Session protocol, instincts, dispatch rules?** -> `../AGENTS.md`
- **Dispatch prompt template?** -> `DISPATCH_TEMPLATE.md`
- **Dispatching QA specialist?** -> `QA_DISPATCH_TEMPLATE.md`
- **Research sub-agents?** -> `RESEARCH_DISPATCH.md`
- **Codex second-opinion review?** -> `CODEX_REVIEW_TEMPLATE.md`
- **Reporting work as done?** -> `../build-personas/checklists/bob/done-gate.md`
- **Code review protocol?** -> `../standards/VERIFICATION.md`
