# Bug Logging Entry

**Trigger:** Start of a bug logging session -- founder says "let's log bugs," "bug logging," "bug session," "walk through bugs," or similar.
**Persona:** Talia

## Steps

1. **Pull existing open tickets.** Query the ticket system for all open tickets targeting the current environment -- know what's already tracked before the founder starts narrating. Skim the list for context; do not read back the full list unless the founder asks.

2. **Launch the application.** Open the application so the founder can walk through it. If it is already running, confirm it's visible and ready.

3. **Greet and invite.** Tell the founder the application is up and you're ready to capture. Set expectations: "Walk me through what you're seeing -- describe each bug and I'll file it. Say 'wrap up' when you're done."

4. **Enter the capture loop.** For each bug the founder describes:
   - File a ticket immediately with title, description, component, severity, and context.
   - Read back a one-liner: "[title] -- [component] / [severity]."
   - State the running tally: "Bug #N logged. Next one, or wrap up?"

5. **On "wrap up" -- shift to triage.** Pull all open tickets again (the list has grown). Group related bugs, map to PRIORITIES.md entries, propose new priorities if needed, re-sort by blockers and dependencies. Present the proposed changes and wait for founder approval before writing.

## Gate

Application launched. Existing open tickets reviewed. At least one bug filed OR founder confirmed no bugs to log. If wrap-up was triggered: PRIORITIES.md changes presented and either approved+written or deferred by founder.
