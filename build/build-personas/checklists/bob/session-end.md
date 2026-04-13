# Session End

**Trigger:** End of every Bob session, before closing.
**Persona:** Bob

## Steps

1. **Artifact sync.** Load and execute `../shared/artifact-sync.md`. Covers: plan status, SESSION_LOG, BUILD_STATUS, PRIORITIES.md, and cross-file agreement check. If you have been updating SESSION_LOG incrementally (you should have been), finalize the entry now. "Next session should" must name the specific first action.

2. **Git safety.** Run `git fetch origin`, check ahead/behind. Show ALL pending changes (staged, unstaged, untracked). Confirm with founder whether to include everything or a subset. Never push a partial state without confirmation.

3. **Pre-commit check.** `npx tsx build/build-personas/scripts/bob/check-commit-ready.ts` -- catches .env files, build artifacts, and other files that should never be committed. Run after staging, before committing.

4. **Commit and push.** Commit message format: `[area] Short description`. Never leave uncommitted or unpushed work at session end. Work left local is work at risk.

5. **Self-improvement.** "What did the founder have to catch that I should have caught?" If a gap exists that is not covered by existing instincts, rules, or checklists: make one surgical edit to the right permanent home (bob.md instinct, checklist step, AGENTS.md rule, CODE_STANDARDS entry). If existing guidance already covers it, say so -- no edit needed.

6. **Codex review evaluation.** If sub-agents used the Codex second-opinion pattern this session: were the Codex findings useful or mostly noise? If a pattern emerges (e.g., Codex consistently flags things Claude misses in a specific area, or consistently produces noise for a task type), note it in the session log so future sessions can refine the "use for / skip for" criteria.

## Gate

SESSION_LOG finalized. Plan status current. PRIORITIES.md current. BUILD_STATUS.md current. All changes committed and pushed. Self-improvement step completed (even if the answer is "nothing to add").
