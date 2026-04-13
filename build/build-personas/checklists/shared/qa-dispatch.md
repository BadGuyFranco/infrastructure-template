# QA Dispatch

**Trigger:** Referenced by other checklists when Talia QA verification is needed.
**Persona:** Shared

## Steps

1. **Prepare dispatch.** Use `orchestrator/QA_DISPATCH_TEMPLATE.md`. Include spec references and acceptance criteria. Exclude implementation notes and confidence levels (context isolation).
2. **Dispatch Talia.** Send the dispatch. Talia runs independently and returns a QA Report with a verdict.
3. **Handle blocks.** If Talia returns BLOCK, fix the reported issues and re-dispatch.
4. **Escalation.** After 2 rounds of BLOCK on the same concern, escalate to founder. Do not attempt a third fix without founder input.

## Gate

Talia verdict is PASS or CONDITIONAL PASS. Any CONDITIONAL items documented.
