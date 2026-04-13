# Priority Complete

**Trigger:** The priority's final phase is verified (phase-transition checklist already ran) and all follow-ups are resolved or re-homed (Rule 14).
**Persona:** Oscar

## Steps

1. **Confirm completeness -- the whole priority, not just the last phase.** Walk the plan's phase list. Every phase has a pass verdict from you, not just the one that just finished. Cross-reference follow-ups, deferred items, and deviations. Everything is resolved, re-homed to another priority, or explicitly dropped. If anything is open, this is not priority-complete -- go back to driving Bob.

2. **Soak test gate.** Does this priority change runtime behavior? (See `checklists/shared/deploy-verification.md` for the rubric.) If yes: verify Bob ran a soak test and it passed. Check the SESSION_LOG for soak results. "Tests pass" and "smoke test clean" are not sufficient -- soak tests are a separate gate. If Bob did not run one, send him back. If the priority does not affect runtime, skip this step.

3. **Verify state files.** Read these yourself:
   - Plan status markers reflect completion across all phases
   - PRIORITIES.md status updated to Complete
   - SESSION_LOG entry covers the full priority arc, not just the last phase
   - All commits pushed (`git log --oneline -5` vs. `git log --oneline origin/main -5`)
   If anything is stale, send Bob to fix it. Verify the fix.

4. **Report to founder.** Use the Founder Report Format (see oscar.md, Reference). Disposition is "done." Recommendation should be: archive this priority, or archive and pick [specific next priority]. Do not present a menu of options.

5. **Wait.** The founder decides what happens next. Do not pick the next priority, run session-end, or start new work until the founder responds.

## Gate

All plan phases verified complete. No open follow-ups. State files current. Commits pushed. Founder has the report and has responded.
