# Architectural Health Check

**Trigger:** Session start (after session-start checklist) and phase transitions (after phase-transition checklist) for any priority that modifies services, state management, or core infrastructure code. Also triggered when Oscar notices patterns that smell like architectural drift.
**Persona:** Oscar

## Steps

### At Session Start

Run these checks after the standard session-start checklist, before picking up work.

1. **File size scan.** For the active priority's key source files, check line counts:
   ```bash
   wc -l <key-files>
   ```
   Flags:
   - Any single file over 500 lines: ask Bob what responsibilities it handles and whether any can be extracted.
   - Any file that grew by more than 100 lines since the last session: ask Bob to justify the growth. Check with `git log --oneline --since="2 days ago" -- <file> | wc -l` for commit velocity.
   - Any file with more than 30 commits in the last 7 days: high churn suggests the file is absorbing too many changes. Ask: "Is this file becoming a catch-all?"

2. **Fix-cycle detection.** Check recent git history for repeated fixes to the same files:
   ```bash
   git log --oneline -20 -- <key-directory>
   ```
   Flags:
   - Same file fixed in 3+ of the last 10 commits: ask Bob "are we fixing the same class of bug repeatedly?"
   - Commit messages containing "fix" followed by another "fix" to the same area within 2 sessions: whack-a-mole signal. Stop and diagnose the root cause before more fixes.

3. **Test strategy check.** For the active priority's test files:
   - Count mock/spy usage: `grep -c "mock\|spy\|vi\.fn\|jest\.fn" <test-files>`
   - If any test file has more mocks than assertions, the tests may be testing the mock rather than the behavior.
   - Ask Bob: "Which boundaries are we mocking in tests? Are those the same boundaries where bugs have appeared?" If yes, the mocks are hiding the bugs.

### At Phase Transitions

Run these checks after the standard phase-transition checklist, before approving the next phase.

4. **Responsibility audit.** Ask Bob: "List every responsibility this file/module handles." If Bob says "and" more than twice in one description, the module is accumulating responsibilities. Push for extraction plan before continuing.

5. **Source-of-truth check.** For any data that the phase modified or introduced:
   - "Where is this data stored?"
   - "If I restart the app, does it survive?"
   - "If two components disagree about this value, which one wins?"
   If the answers are unclear or split across multiple stores, flag it. Every piece of state should have one authoritative source, documented.

6. **Dead feature scan.** For any new code path introduced this phase:
   - "Is this read path exercised in production, or only in tests?"
   - "Is this safety feature (logging, intent recording, validation) consumed by anything, or is it write-only?"
   Write-only safety features are dead on arrival. Either wire up the consumer or remove the feature.

7. **Boundary coupling check.** For any module modified this phase:
   - Count distinct imports: `grep "^import" <file> | wc -l`
   - If a module imports from more than 8 distinct packages/siblings, it knows too much. Push for re-layering.
   - Check for reach-through imports (importing from `../sibling/src/internal/`): these couple to internal structure.

8. **Integration test coverage.** After any phase that modifies module boundaries:
   - "Do we have an integration test that exercises this boundary with real components (not mocks)?"
   - If the answer is no, the boundary is untested at the level where bugs actually appear. Flag it as a gap.

## Severity Levels

- **Flag:** Note in session log, ask Bob about it, accept a reasonable answer.
- **Stop:** Do not proceed to the next phase until the issue is addressed. Document the finding in the plan.
- **Escalate:** Surface to the founder using the Decision Presentation Format. The issue affects architectural direction.

| Check | Threshold | Severity |
|-------|-----------|----------|
| File over 500 lines | 500-800: Flag. 800+: Stop. | Varies |
| Growth > 100 lines/session | Flag | Flag |
| 30+ commits/7 days to one file | Stop | Stop |
| Same-area fix 3+ times in 10 commits | Stop | Stop |
| More mocks than assertions in test file | Flag | Flag |
| Mocked boundary = bug boundary | Stop | Stop |
| In-memory-only state for durable data | Stop | Stop |
| Write-only safety feature | Flag | Flag |
| Module with 8+ distinct imports | Flag | Flag |
| Modified boundary with no integration test | Flag first time, Stop if pattern repeats | Varies |

## Gate

At least steps 1 and 2 executed at every session start. At least steps 4 and 5 executed at every phase transition. Findings documented in session log if any check flags or stops.
