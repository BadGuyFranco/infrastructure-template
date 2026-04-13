# Close Priority

**Trigger:** When all tasks in a plan are complete and you are ready to close out a priority.
**Persona:** Bob

This checklist is the Final Check gate from `plans/AGENTS.md`. Nothing archives until every step passes.

## Steps

1. **All tasks resolved.** Every task in the plan is `[x]`, `[--]`, or promoted elsewhere. No `[ ]` or `[~]` items remaining.

2. **Deferred items accounted for.** Cross-reference the plan's Deviations and deferred items. Every deferred item must be: promoted to a new priority, added as a carry-forward on another priority, logged in ToDos.md, or explicitly descoped with founder approval. Unresolved deferred work means not archivable.

3. **Documentation congruence.** Load and execute `../shared/doc-congruence.md`.

4. **Test verification.** Load and execute `../shared/test-verification.md`.

5. **Artifact sync.** Load and execute `../shared/artifact-sync.md`. Ensure the final SESSION_LOG entry summarizes what was delivered for this priority.

6. **QA dispatch.** Load and execute `../shared/qa-dispatch.md`. Context: final regression sweep before archival. This is the last verification gate.

7. **Archive the plan.** Move the plan file to `plans/archive/`. Update the Current Plans table in `plans/AGENTS.md` -- remove from Current, add to Archived with completion date and summary.

8. **Inform the founder.** Present which entries are candidates for archival from PRIORITIES.md and why. Archiving the priority entry is the founder's call.

## Gate

Plan archived. All artifacts current. Talia verdict is PASS or CONDITIONAL PASS. Founder informed of completion. Priority entry updated (not deleted).
