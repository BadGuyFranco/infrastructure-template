# Artifact Sync

**Trigger:** Referenced by other checklists when state files must be synchronized.
**Persona:** Shared

## Steps

1. **Plan status.** If working on a plan, update its Current status line. This is the pickup point for the next session.
2. **SESSION_LOG.md.** Write or finalize the session entry. Include: what was done, what's unfinished, pickup instructions. "Next session should" must name the specific first action -- not just the priority slug or "TBD."
3. **BUILD_STATUS.md.** For every component touched, update its build status entry.
4. **PRIORITIES.md.** If priorities shifted, status changed, or work was completed, reflect it. Do not delete entries -- only update status. Deletion requires founder approval.
5. **Agreement check.** Verify that plan status, PRIORITIES.md status, and SESSION_LOG all agree. These move together or not at all. If any is stale, fix it now.

## Gate

All state files synchronized. No contradictions between plan, priorities, session log, and build status.
