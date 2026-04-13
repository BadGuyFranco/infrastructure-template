# Persona System Audit

**Trigger:** Founder requests a persona system review, or Oscar notices systemic drift (same type of mistake recurring across sessions, checklists not being followed, personas consistently forgetting steps).
**Persona:** Oscar

This is the meta-process -- improving how the build system improves itself. Walk through every active persona (read `build-personas/AGENTS.md` for the current list -- do not hardcode persona names).

## For Each Persona

1. **Checklist audit.** Read the persona's playbook and their checklists. Ask:
   - Are there procedural steps in the playbook that belong in a checklist? (Sequences of ordered steps that must all execute at a specific moment = checklist, not instinct.)
   - Are there checklist steps that are actually heuristics? (Judgment calls that don't have a fixed sequence = instinct, not checklist.)
   - Are any checklists missing? Look at SESSION_LOG for patterns: what steps are getting skipped or forgotten? That's a checklist gap.
   - Are any checklists stale? Do they reference files, commands, or processes that no longer exist?

2. **Routing table audit.** Read the persona's Routing table. Ask:
   - Does every checklist file in the persona's `checklists/` directory have a corresponding row in the Routing table?
   - Does every Routing table entry point to a file that exists?
   - Are the trigger descriptions accurate? Would the persona know when to load each checklist from the trigger description alone?

3. **Elegance check.** Read the persona's playbook against the elegance criteria:
   - Well structured -- layered for an LLM to read and operate, most important context first?
   - Not redundant or confusing -- no conflicting instructions, no duplicate guidance across the playbook and its checklists?
   - Concise -- the exact right number of tokens? No fluff, no narrative history?
   - Is the playbook growing instead of staying lean? If it's getting longer, something that should be a checklist or a rule in AGENTS.md is probably accumulating as instincts.

4. **Cross-persona consistency.** Ask:
   - Do all personas have a session-end checklist with a self-improvement step?
   - Do all personas have the meta-instinct about creating checklists for repeating patterns?
   - Are structural improvements from one persona being applied to others where they genuinely apply? (Not copying blindly -- only where the improvement is relevant.)

## System-Level Questions

5. **Is the improvement process itself working?** Ask:
   - Are session-end self-improvement steps actually producing edits, or are they being skipped?
   - Are the edits landing in the right places (checklists vs. instincts vs. rules)?
   - Is the checklist system being used, or are new procedures still being written as instincts?

6. **What would the founder catch that Oscar hasn't?** This is the hardest question. Step outside the system and look at it as the founder would. Where is the drift? Where is the friction? What is the system not seeing about itself?

## Gate

Every active persona reviewed. Routing tables verified. Elegance assessed. Cross-persona consistency checked. Findings presented to the founder with specific recommendations (not just observations).
