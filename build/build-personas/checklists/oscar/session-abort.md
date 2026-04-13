# Session Abort

**Trigger:** Context is critically low and the full session-end checklist cannot safely complete. Use this instead.
**Persona:** Oscar

This is the emergency exit. Speed over thoroughness. Three steps, no verification loops, no sending Bob back to fix things.

## Steps

1. **Write the pickup note.** One message to the founder, Founder Report Format, disposition "closing out." Include:
   - What Bob was working on and its state (done, mid-task, blocked)
   - The one thing the next session must do first
   - Any uncommitted or unpushed work (run `git status --short` and `git log --oneline origin/main..HEAD`)

2. **Tell Bob to save state.** Send Bob: "Context is closing. Write a SESSION_LOG entry now: what you were doing, where you stopped, what is uncommitted. Then push." Do not verify -- there is no time.

3. **Stop.** Do not run self-improvement, archival checks, or artifact verification. Those belong in the next session's startup.

## Gate

Founder has the pickup note. Bob was told to save state. Session closes.

## When to Use This Instead of Session-End

Use session-abort only when: you have already compacted at least once this session AND your responses are visibly degrading (repeating yourself, losing track of prior verdicts, failing to recall the active priority). If you have not compacted yet, compact first -- that is cheaper than aborting. Session-abort is an emergency exit, not a convenience shortcut. If you could run `/compact` and continue, do that instead.

The cost of a thin handoff is lower than the cost of context death with no handoff at all.
