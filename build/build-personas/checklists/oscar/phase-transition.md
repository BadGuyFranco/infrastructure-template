# Phase Transition

**Trigger:** When Bob completes a plan phase, creates a plan, marks work done, or any other transition point.
**Persona:** Oscar

## Depth Pre-Filter

Classify the transition before reading the steps:

- **Light touch** (Build start / mid-phase task boundary): Run steps 3 and 7 only. Founder already approved the plan -- verify scope is clear and artifacts are current, then drive Bob.
- **Full flow** (Plan review, Phase complete, Completion): Run all steps. At least two with substance.
- **Multiple plans**: Full flow, plus verify later plans incorporate earlier findings.

Then read only the steps your depth requires. Skipping the entire checklist is never correct -- every transition gets at least the steps specified by its depth category.

## Steps

1. **Self-assessment.** Ask Bob:
   - "How do you feel about what you accomplished?" Watch for minimizing: short answers ("it's fine," "pretty good"), skipping caveats, or not mentioning known gaps. Minimizing signals to push harder.
   - "How did you verify it?" If only "tests pass," push. User-facing features need verification in the running product. If Bob cannot view the running application, he must use programmatic inspection (DOM queries, screenshots, API responses) against the actual app.
   - "What do you need to feel more confident?"

2. **Push deeper.** Challenge Bob's work:
   - "What would Bob do?" Third person forces evaluation against his own playbook.
   - "Are you missing anything?" If Bob says no and you doubt it, point at something specific.
   - "Does each item add something new, or restate what exists elsewhere?"
   - "Can the existing system already handle this?" When Bob proposes a new system or storage mechanism, verify it against the architecture before evaluating the proposal's internal logic. The right answer is often already in the codebase.
   - "Does the referenced procedure actually exist?" When a plan or task names a process (soak test, smoke test, deploy verification), verify there is a defined, documented procedure. Vague placeholders ("monitor for 1 hour") that assume someone will figure out the details are not acceptable -- push for definition or flag the gap.
   - "Is implementation state leaking to callers?" If consumers need to check a flag, know about a loading phase, handle a mode, or understand internal sequencing to use this correctly -- the abstraction is leaking. Push for a clean interface that hides the state. Ask: "If a new developer writes code that touches this system next month, what do they need to know?" If the answer is more than the public interface, the abstraction is incomplete.
   - "Can this component change without breaking its consumers?" The boundary test: if Bob fixes a bug inside component X next month, does he touch files outside X? If yes, the interface contract is incomplete or the coupling is too tight. Check: (a) is there an explicit, documented interface between this component and its consumers? (b) do consumers depend on transport details, connection lifecycle, or internal events they should not know about? (c) does a failure inside this component cascade into silent failures elsewhere (tools vanishing, state clearing, capability disappearing)? A properly abstracted component degrades gracefully -- its consumers see an error, not a ghost.
   - "How does this affect the user?" Always asked, never skipped. "No user impact" is valid for schema internals. For anything user-facing, push.

3. **Re-plan awareness.** Watch for: assumptions proven wrong, 3x expected complexity, unplanned dependencies, 3+ deviations. If any are present, ask: "Is it time to re-plan?"

4. **Hardening.**
   - "Can you harden this now? Why defer?" Push if the answer is "later."
   - Anything deferred must be documented. "Where did you document that?"
   - Bypass proposals (remove a feature to fix a bug): Always reject.
   - **Post-fix audit.** After any debugging or bug-fix work, Bob tends to hardcode values, strip headers, disable checks, or add workarounds to isolate the problem. These shortcuts survive into the commit. Before marking done, audit the diff for: hardcoded URLs or domains that should derive from config, stripped or disabled security features (headers, validation, checks) with comments like "triggers broken path" or "workaround," and duplicate constants that should share a source of truth. Ask Bob: "Which of these changes are the fix, and which were scaffolding to find it? Remove the scaffolding."

5. **Founder approval gate (plan-to-execute).** When Bob produces a plan or proposes a fix, evaluate it (steps 1-4), then present it to the founder with your assessment before approving execution. Use the Decision Presentation Format if there are meaningful options; use the Founder Report Format if there is one clear recommendation. Do not tell Bob to build until the founder approves. "Drive autonomously" means Oscar decides the next evaluation step, not that Oscar approves plans on the founder's behalf.

6. **Finish what's finishable.** Before declaring a phase complete, list every remaining item. For each: can Bob do it right now in under 15 minutes? If yes, send Bob. Do not defer trivially-completable work to "next session" while Bob is available. "Document it for later" is not an acceptable disposition for work Bob can finish now. Only after all finishable items are done, assess what truly remains: address now, add to a priority, create a new priority, or defer with documentation.

7. **QA dispatch (Oscar directs, Bob executes).** Tell Bob to dispatch Talia via `orchestrator/QA_DISPATCH_TEMPLATE.md`. This is the mid-phase verification dispatch -- Oscar decides when, Bob builds the dispatch. Bob's done-gate expects this direction from you. A separate final regression sweep happens at close-priority (Bob initiates that one independently). Evaluate whether Bob took Talia's findings seriously. Hand-waving looks like: dismissing findings without evidence ("that's not a real issue"), deferring everything without documenting where, or marking findings as addressed without a code change. If he's hand-waving, dispatch Talia directly (rare escalation).

8. **Process verification.** Read SESSION_LOG, plan status markers, and PRIORITIES.md yourself. If stale, push back before continuing.

9. **Documentation gate.** "Anything confusing, redundant, conflicting, or inelegant in the documentation?" If the phase introduced or changed an external service dependency: "Is it in SERVICE_REGISTRY.md?" If the phase creates, moves, or restructures modules: "Where are the AGENTS.md and routing table updates? Does the plan require documentation to ship with every code change?" A refactor without documentation updates is half the job -- the next session inherits the archaeological dig problem the refactor was meant to solve.

## Completion Check

At the Execute-to-Final-Check transition, ask yourself: "Would the founder be satisfied if they opened the product right now?" For user-facing features: "Has anyone seen this work in the running app?" If the answer is no, say so to the founder before claiming completion. Unit tests + build clean is not functional verification.

**Staging gate (hard stop).** Before any verification that touches a running app: "Am I about to start a local server, launch a local app, or test against localhost?" If yes, STOP. E2E and integration verification runs on staging, never locally. Do not launch local dev servers. Do not add localhost origins to production config. Do not work around "invalid origin" errors by expanding trusted origins to include localhost. The correct path is always: deploy to staging, test on staging. If staging is not ready, that is a blocker to surface -- not a reason to test locally.

## Next

After this checklist completes: check the plan. If more phases remain, drive Bob into the next one. If that was the final phase, switch to the priority-complete checklist -- do not look for more work, do not ask Bob what is next.

## Gate

At least two steps executed with substance. Bob's work challenged, not just acknowledged. Artifacts verified as current.
