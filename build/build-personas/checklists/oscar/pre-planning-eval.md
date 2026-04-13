# Pre-Planning Evaluation

**Trigger:** Founder picks a priority that has no plan (status "Not started" or "Needs planning"). Before sending Bob to plan, Oscar evaluates the priority independently.
**Persona:** Oscar

## Why This Exists

Oscar has jumped into planning without a full grasp of what the priority is trying to accomplish. Bob plans fast, but plans built on a misunderstood purpose waste sessions. This checklist forces Oscar to understand the priority, form an opinion, and confirm alignment with the founder before Bob touches it.

## Steps

1. **What purpose does this priority serve?** Restate it in your own words -- not by quoting the PRIORITIES.md entry. What problem does it solve for the user, the product, or the business? If you cannot articulate this in two sentences without referencing the priority entry, you do not understand it well enough to direct Bob.

2. **Is the purpose stale?** Read the priority's creation date and the work that has happened since. Has the problem been partially addressed by other completed priorities? Have dependencies shifted? Has the codebase changed in ways that alter the scope or approach? If the priority was written 5+ sessions ago, assume drift -- verify against the current state.

3. **What does this touch and what is the risk?** Identify the components, packages, and code surfaces this priority will modify. For each: what is the blast radius if it goes wrong? What is well-tested vs. fragile? What other active or queued priorities share those surfaces? Risk mitigation is not "be careful" -- name the specific tests that exist, the tests that are missing, and what Bob should verify at each phase boundary.

4. **Does this need abstraction or componentization?** Is Bob about to build something that should be a reusable component, a shared utility, or an extension of an existing pattern? Check whether the codebase already has a partial solution. "Build a new thing" when "extend the existing thing" is the right answer wastes effort and creates maintenance surface. Also check: does this priority introduce a pattern that other queued priorities will need? If so, the abstraction should be designed now, not retrofitted later.

5. **What does "done" look like?** Articulate acceptance criteria before Bob plans. What must be true for this priority to be complete? What does the user see? What does the system do? What tests must pass? If you cannot state this clearly, the priority needs scoping from the founder, not planning from Bob.

6. **Are there product decisions the founder needs to make first?** Check the priority's "Research needed" section if it has one. Look for unresolved options, conditional scope, or open questions. If Bob plans around unresolved decisions, the plan will have conditional branches or assumptions that need to be unwound later. Surface these now.

7. **What existing work informs this?** Check SESSION_LOG for prior diagnostic sessions, research docs in `plans/research/`, ticket context, and completed priorities that touched the same area. Bob should receive this context in his planning prompt -- not rediscover it.

8. **Does the sequencing make sense?** Is this the right priority to do now given the current active stack, queued items, and launch gates? Does finishing this unblock other work? Could another priority be done first that would make this one cheaper or unnecessary? This is not second-guessing the founder -- it is catching stale sequencing assumptions.

9. **Confirm with the founder.** Present your understanding: purpose (step 1), staleness assessment (step 2), risk map (step 3), abstraction needs (step 4), acceptance criteria (step 5), and any open decisions (step 6). This is a conversation, not a report -- ask where you are uncertain, absorb the founder's corrections. Only after the founder confirms: send Bob to plan.

## Gate

Oscar can articulate the priority's purpose, risk, and acceptance criteria without quoting the PRIORITIES.md entry. Staleness checked against current codebase state. Abstraction and componentization needs identified. Product decisions surfaced. Existing prior work identified for Bob's context. Founder has confirmed Oscar's understanding. Bob has not been contacted.
