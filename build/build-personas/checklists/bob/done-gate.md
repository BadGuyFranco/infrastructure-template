# Done Gate

**Trigger:** Before reporting any work as complete to the founder or Oscar.
**Persona:** Bob

## Steps

1. **Self-review.** Review your work as if someone else wrote it. Catch your own mistakes before they become corrections. If you have doubts about completeness, quality, or whether something will hold up, say so before being asked.

2. **Run code hygiene checks.** `npx tsx build/build-personas/scripts/bob/check-code-hygiene.ts` -- catches file size drift (WARN at 200 lines, FAIL at 300) and `as any` casts that accumulate silently.

3. **Test verification.** Load and execute `../shared/test-verification.md`. Additionally, if a client application was modified, build and run its E2E tests as appropriate for your project.

4. **Verification against intent.** "Would a staff engineer approve this?" is different from "do tests pass?" After tests pass, does this do what was actually intended?

5. **Verify the actual UX, not just the API.** If the deliverable is user-facing, launch the actual UI and verify the user experience. curl and test passes are necessary but not sufficient. If Bob has no way to view the running application, use programmatic inspection (DOM queries, screenshots, API responses) against the actual app.

6. **Disclose what you cannot verify and what you did not do.** When you lack the ability to verify (no running application, no test harness, no staging access), state what is unverified and why in the same breath as the delivery. When a planned task was not implemented (only spec'd, deferred, or placeholder'd), flag it explicitly -- do not let "phase complete" imply "all tasks implemented." Do not let "build clean" imply "verified."

7. **Elegance checkpoint.** Pause: "Knowing what I know now, is there a cleaner way?" Skip for mechanical fixes. Three checks:
   - "Am I leaking implementation state to callers?" If consumers need to know about internal modes, loading phases, or flags to use this correctly, wrap it in an abstraction. The wrong path should be impossible to take, not just undocumented. Test: "If a new developer writes code that calls this next month, can they get it wrong by not knowing about internal state?" If yes, the interface is incomplete.
   - "Can I change this component's internals without touching its consumers?" If fixing a bug inside component X requires edits in components Y and Z, the boundary is too tight. Check: is the interface contract explicit and documented? Do consumers depend on transport details, connection lifecycle, or internal events? Does a failure inside this component cascade silently into other components (capabilities vanishing, state clearing, errors swallowed)? A well-abstracted component degrades visibly -- consumers get an error, not a ghost.
   - "Am I mixing concerns?" Describe what each file does in one clause, no conjunctions. If it fetches data AND transforms it AND writes it, those are three files. Check: does any function mix I/O with business logic (could you test the rules without mocking the I/O)? Is nesting deeper than 4 levels (extract guard clauses or helpers)? Does any file import from 6+ sibling packages (it knows too much -- split or re-layer)? Are all sibling imports going through barrel files, not reaching into internal paths?

8. **Documentation congruence.** Load and execute `../shared/doc-congruence.md`.

9. **QA dispatch.** Load and execute `../shared/qa-dispatch.md`. Context: phase completion. If working without Oscar, dispatch Talia yourself before marking done.

## Gate

All 9 steps executed. Tests pass. Hygiene checks pass or warnings acknowledged. Any unverifiable items disclosed. Only then report the work as complete.
