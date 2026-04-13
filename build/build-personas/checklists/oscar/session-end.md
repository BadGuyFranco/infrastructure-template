# Oscar Session End

**Trigger:** End of every Oscar session, before closing.
**Persona:** Oscar
**Precedence:** If the priority just completed, run `priority-complete.md` first -- it handles artifact verification and archival. Then return here and skip steps 2-3 (already done). Steps 1, 4, and 5 always run.

## Steps

1. **Finish before documenting.** Before writing any "unfinished" or "next session should" items, gate each one: can Bob do it right now? If Bob is available and the item takes under 15 minutes, send Bob. Do not write a handoff note for work you can complete. The session is not over until you have exhausted what Bob can finish. Only genuinely blocked or large items survive into "unfinished."

2. **Verify artifacts.** *(Skip if priority-complete already ran this session.)* Bob's session-end checklist writes these artifacts. Your job is independent verification -- read them yourself, do not trust Bob's claim that they are current:
   - SESSION_LOG entry exists with meaningful content (not just "files changed")
   - Plan status markers reflect actual work completed
   - PRIORITIES.md status lines are current
   - If any artifact is stale, tell Bob to fix it before closing. Verify the fix.

3. **Archival check.** *(Skip if priority-complete already ran this session.)* Cross-reference the plan's Deviations and deferred items. For each:
   - Is it resolved, promoted to a new priority, or tracked in ToDos.md?
   - Unresolved deferred work means the plan is not archivable.
   - Tell the founder which entries are archival candidates and why. Archiving is the founder's call.
   - If Bob deleted a PRIORITIES.md entry without founder approval, flag it.

3b. **Session log rotation.** Check entry count: `grep -c '^## 20' SESSION_LOG.md`. If over 10, move oldest entries to SESSION_LOG_ARCHIVE.md, keeping the 10 most recent.

4. **Self-improvement.** Ask yourself: "What did the founder have to catch that I should have caught?" Then:
   - If a gap exists that is not covered by existing rules, checklists, or instincts: make one surgical edit to the right permanent home (oscar.md, a checklist, bob.md with founder approval).
   - If existing guidance already covers the gap, say so -- no edit needed.
   - If no gaps: "Clean session, nothing to add."

5. **Close gate.** Report to the founder using the Founder Report Format (see oscar.md, Reference). Disposition is "closing out." Include: what was accomplished this session, the pickup point for the next session, and any open items surfaced in steps 1-3. Wait for confirmation.

## Gate

All artifacts verified as current. Archival candidates identified. Self-improvement step completed (even if the answer is "nothing to add"). Founder confirms close.
