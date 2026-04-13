# Oscar Session Start

**Trigger:** Start of every Oscar session, before any work begins.
**Persona:** Oscar

## Steps

1. **Show loaded directories.** Display every directory path you have loaded to the founder.

2. **Verify Bob's directories.** Send Bob: "List every directory path you have loaded in this session. Just the paths." Show the founder his response. Do not proceed until both lists are visible. This catches workspace misconfiguration before it wastes a session.

3. **Read context sources (surgical).**
   - `oscar.md` -- injected via system prompt. Verify it loaded (check you can recall the Rules). Do not re-read unless missing.
   - `PRIORITIES.md` -- headers and summaries only:
     ```bash
     grep -n '### \|^\*\*Summary:\*\*' build/PRIORITIES.md
     ```
     Do NOT full-read until the founder picks a priority.
   - `SESSION_LOG.md` -- latest entry only:
     ```bash
     # Read last ~40 lines
     Read build/SESSION_LOG.md with offset=(last line - 40), limit=40
     ```
   - Active plan -- CURRENT STATUS block only:
     ```bash
     grep -n 'CURRENT STATUS\|Current status' build/plans/*.md
     ```
     Then read just that section with offset/limit.
   - Do NOT read upstream AGENTS.md chain files. You are already oriented.

4. **Quick-check Bob.** Send a message to confirm Bob is alive and responding. If Bob's session died, relaunch. Steps 2 and 4 can be combined -- the directory question doubles as the alive check.

5. **Surface archive candidates.** From the grep output in step 3, identify any priorities with Complete, Closed, or equivalent status still in PRIORITIES.md. Present them to the founder for archival decision before showing the active list. Completed entries waste context tokens on every session.

6. **Present priorities.** Show the founder a numbered list of ALL non-archived priorities across every section: number, [SLUG], Who (Oscar or Bob), short description. Build this from the grep output in step 3, not from full-reading PRIORITIES.md. No recommendation -- let the founder choose.

7. **Receive direction.** After the founder picks a priority: full-read only that priority's entry from PRIORITIES.md (use offset/limit). If the priority has no plan (status "Not started" or "Needs planning"), load and execute `build-personas/checklists/oscar/pre-planning-eval.md` before sending Bob to plan. If the priority has an existing plan, read its CURRENT STATUS and drive Bob into the next phase.

8. **Post-startup compact.** Run `/compact` with the preservation template from oscar.md section on Context Discipline. The startup phase loads the most raw content and most of it is consumed by this point.

## Standing Rules (loaded into context every session)

- **No local E2E.** Never start local servers, launch local apps, or test against localhost. Never add localhost to production or staging trusted origins. All E2E/integration testing goes through staging. If staging is not ready, that is a blocker -- not a reason to test locally.

## Gate

Both directory lists visible. Context sources read. Bob alive. Archive candidates surfaced. Founder has chosen a priority. Post-startup compact done. Oscar is driving.
