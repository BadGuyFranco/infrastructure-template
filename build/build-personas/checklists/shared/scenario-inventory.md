# Scenario Inventory

**Shared checklist.** Enumerate concrete real-world scenarios before building, so design-level gaps surface before the plan is written -- not after Phase 3 when rework is expensive.

**Trigger:** Research/design phase of any priority with 3+ planned phases, or that touches user data, filesystem, security boundaries, or concurrent system state. For smaller work (bug fixes, config changes), replace with a single "what could this break?" line in the research output.

**Personas:** Bob generates. Oscar verifies coverage. Founder reviews and augments before plan execution begins.

## Steps

### Generate (Bob)

1. **User actions.** List 3-5 things a user will physically do beyond the happy path. Think: delete, rename, move, use while offline, use mid-operation, use with unexpected input, use from a different client, use at scale.

2. **System states.** List 2-3 concurrent or unusual system states the feature must handle. Think: service mid-write, sync running, network dropped, another user acting on the same resource, app open vs. closed, server restart mid-operation.

3. **Failure modes.** List 2-3 ways this can break. Think: disk full, permissions denied, corrupt data, timeout, upstream service down, malformed response, partial write.

4. **Recovery.** For each failure mode: what does the user see? How do they return to a working state? "They lose data" or "they don't know anything happened" are design gaps, not acceptable answers.

5. **Format each scenario:**
   - **Trigger:** specific user action or system event
   - **Expected:** what should happen
   - **Verify:** test case, manual check, or staging scenario that confirms it

6. **Cap at 5-10 scenarios.** Prioritize by likelihood and severity. The inventory should be scannable in under 2 minutes. If you have more than 10, you are listing implementation details, not scenarios.

7. **Include as `## Scenario Inventory` in the research output,** alongside findings, risks, and approach options.

### Dual-model review (Bob, required)

Claude and GPT fail differently. A single model generating scenarios has systematic blind spots -- the same categories of edge cases will be missed every time. Dual-model generation directly addresses this.

8. **Dispatch a Codex sub-agent** with the feature context (architecture docs, affected files, research findings so far) and ask it to independently generate a scenario inventory using the same categories (user actions, system states, failure modes, recovery) and the same format (trigger/expected/verify).

9. **Synthesize.** Merge both inventories. Flag scenarios that only Codex found (these are the blind spot catches -- pay attention to them). Flag overlaps (high-confidence scenarios both models identified). Drop duplicates. The merged inventory replaces the single-model version in the research output.

10. **If Codex is unavailable,** continue with the single-model inventory and note `codex-scenarios: skipped` in the research output. Never block research on Codex availability. But recognize that the single-model list has unmitigated blind spot risk -- the founder review (step 14) becomes even more critical.

### Verify coverage (Oscar)

11. **Inventory exists.** If the research output has no scenario inventory and the priority meets the trigger threshold, send Bob back before approving the plan.

12. **Every scenario has a disposition.** Each must map to one of:
    - A specific plan task that handles it (cite the task number)
    - A specific test case that verifies it
    - An explicit deferral with reasoning and founder sign-off

    "Considered" is not a disposition.

13. **Smell check.** If the feature touches filesystem + network + concurrent writes and Bob listed 3 scenarios, push back. Every category (user actions, system states, failure modes, recovery) should have entries unless a category genuinely does not apply.

14. **Codex delta check.** If Codex was used, verify that Codex-only scenarios got serious treatment -- not dismissed as "already covered" without a specific task or test citation. Codex-only findings are the whole point of dual-model review.

15. **Founder review.** Route the scenario inventory to the founder before plan execution begins. Oscar does not approve scenarios alone. The founder adds scenarios Bob and Oscar missed -- this is the highest-leverage founder touchpoint in the build process.

## Gate

- Scenario inventory exists in research output (or justified skip for small work)
- Dual-model review completed (or `codex-scenarios: skipped` noted)
- Every scenario maps to a plan task, test, or founder-approved deferral
- Founder has reviewed and augmented the list before execution begins
