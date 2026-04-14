# Ticket Review

**Trigger:** Founder requests bug review, or Oscar initiates between priorities when open bug count is unknown or growing.
**Persona:** Oscar

Review all open tickets, cluster related bugs, send Bob diagnostic homework on the highest-value clusters, and draft 1-2 fix priorities for founder approval.

## Steps

1. **Pull open tickets.** Fetch all open bugs and tasks:

   ```bash
   gh issue list --state open --label "bug"
   gh issue list --state open --label "critical"
   gh issue list --state open --label "task"
   gh issue list --state open --label "feature"
   ```

2. **Build the bug table.** For each open bug, record: issue number, title, component label, severity label, date filed, and any referenced files. If a ticket lacks severity, assign one using the guidelines in TICKETS.md. Present the table to yourself -- do not show raw JSON to the founder.

3. **Triage pass.** For each bug, classify:
   - **Stale?** Filed 3+ sessions ago with no comments or status changes. May be fixed already, outdated, or forgotten.
   - **Duplicate?** Same root cause as another open bug. Note which tickets overlap.
   - **Already covered?** Bug is in scope of an existing active or queued priority. Note which one -- it does not need a new priority.

4. **Cluster.** Group remaining bugs (not stale-and-likely-fixed, not duplicates, not already covered) by proximity:
   - Same component
   - Same code path or shared root cause (inferred from description, referenced files)
   - Same user-facing symptom area

   A cluster can be one bug if it stands alone. Name each cluster with a short descriptive label.

5. **Severity-rank clusters.** Score each cluster:
   - Highest individual severity in the cluster
   - Number of bugs in the cluster
   - User-facing impact (launch-blocking > degraded experience > cosmetic)
   - Whether a fix would close multiple tickets at once

   Rank clusters. The top 1-2 become priority candidates.

6. **Bob diagnostic homework.** For each top cluster (max 2), send Bob a focused diagnostic message. Do not ask Bob to fix anything -- ask him to investigate and report back. Template:

   > "Diagnostic request. These bugs may share a root cause: [list issue titles + numbers]. Read [referenced files]. Answer: (1) What is the root cause of each? (2) Do they share a root cause? (3) What is the fix approach -- files touched, risk level, estimated scope? (4) Any dependencies or blockers?"

   Evaluate Bob's response (phase-transition steps 1-2 apply). Push if his answers are vague or he minimizes complexity.

7. **Draft priorities.** For each cluster that survived triage and has Bob's diagnosis:
   - Draft a PRIORITIES.md entry (What, Why, Depends on, Components, Status: "Not started. Diagnosis complete, needs planning.")
   - Include Bob's root cause findings in the What section
   - Reference issue numbers so the priority links back to the bugs
   - Do NOT write the entry to PRIORITIES.md -- present it to the founder

8. **Ticket hygiene.** While reviewing, fix what you can:
   - Close confirmed duplicates (`gh issue close N --comment "Duplicate of #M"`)
   - Add severity labels to tickets filed without one
   - Add comments to stale tickets noting current status (`gh issue comment N --body "Verified still open as of session X"`)

9. **Report to founder.** Present:
   - Bug count: total open, by severity, by component
   - Clusters identified, ranked
   - 1-2 draft priorities with Bob's diagnostic findings
   - Any tickets closed as duplicates or already-covered
   - Any tickets that need founder judgment (ambiguous severity, unclear if still relevant)

## Gate

All open bug tickets reviewed. Clusters identified and ranked. Bob's diagnostic homework received and evaluated for top clusters. Draft priorities prepared for founder review. Ticket hygiene actions (duplicates, severity, comments) executed. Founder has a clear picture and actionable draft priorities to approve or edit.
