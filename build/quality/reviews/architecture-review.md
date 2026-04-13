# Architecture Review Process

A comprehensive, recurring review of {PROJECT_NAME}'s entire architecture -- tech stack, documentation, gaps, risks, security, and mitigations. Run this review regularly to catch drift, contradictions, and blind spots before they become problems.

**Cadence:** Monthly (minimum). Additionally before any major milestone (first alpha, first beta, launch).

**Output:** A timestamped report in this directory: `YYYY-MM-DD-architecture-review.md`

**SOC 2 alignment:** If you target SOC 2 compliance, this review embeds security best practices early so you're on the path -- not over-engineering, just building good habits. The standalone `security-checklist.md` in this directory can also be run independently for compliance or due diligence purposes.

---

## Review Checklist

Every review covers all sections below. No "light" mode. If you're running the review, you're running the full review.

**Risk Factor ratings** appear on each checklist item to help prioritize findings:

| Rating | Meaning | Action |
|--------|---------|--------|
| Urgent | Blocks shipping or creates immediate exposure. Fix now. | Address before next milestone |
| Soon | Not blocking but grows worse over time. Plan it. | Address within 1-2 sprints |
| Defer | Good practice but safe to defer until later phase. | Track in ToDos.md, revisit at next review |

### 1. Tech Stack Audit

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | List every technology in the stack (from AGENTS.md files and ARCHITECTURE.md docs) | Soon | Unlisted tech creates blind spots in security and licensing reviews |
| [ ] | For each technology: Is it still the right choice? Any new entrants that change the calculus? | Defer | Rarely urgent unless a technology is deprecated or compromised |
| [ ] | Are there overlapping dependencies? (Two libraries doing the same thing?) | Defer | Adds bundle size and maintenance burden but not a blocker |
| [ ] | Are there conflicting dependencies? (Version conflicts, incompatible assumptions?) | Soon | Version conflicts cause subtle bugs that are hard to diagnose later |
| [ ] | Check package.json files (where they exist) against architecture claims | Soon | Drift between docs and reality erodes trust in the architecture |
| [ ] | Are all chosen technologies actively maintained? Any approaching EOL? | Soon | Unmaintained deps become security liabilities |
| [ ] | Are there licensing concerns? (Especially for desktop distribution) | Urgent | Licensing violations can block distribution entirely |

### 2. Architecture Coherence

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | Read all ARCHITECTURE.md files end to end | Soon | Foundation for every other check -- stale docs mislead builders |
| [ ] | Do cross-references between docs actually match? | Soon | Broken cross-refs cause components to be built against wrong assumptions |
| [ ] | Are the same concepts described consistently across docs? (Same terminology, same behavior) | Defer | Inconsistent terminology confuses but rarely blocks |
| [ ] | Do the component responsibilities in the infrastructure overview match what each component's ARCHITECTURE.md actually describes? | Soon | Misaligned responsibilities cause integration failures |
| [ ] | Are there implicit assumptions in one doc that contradict explicit statements in another? | Urgent | Hidden contradictions cause costly rework once discovered in code |

### 3. Documentation Completeness

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | Every buildable component/section has a maturity tag: (DECIDED), (SCAFFOLDED), (ALPHA), (SHIPPED), or (HARDENED) | Soon | Missing tags make it impossible to know what's safe to build on |
| [ ] | No buildable section is missing a maturity tag | Soon | Same as above |
| [ ] | No maturity tag is incorrect (e.g., tagged DECIDED but code exists -> should be ALPHA) | Soon | Wrong tags give false confidence about component readiness |
| [ ] | Every ADR in `decisions/README.md` has a corresponding section in an ARCHITECTURE.md | Defer | Orphaned ADRs are confusing but not dangerous |
| [ ] | No orphaned ADRs (accepted but never referenced) | Defer | Same as above |
| [ ] | No undocumented decisions (decisions made in architecture docs without an ADR, where one is warranted) | Soon | Undocumented decisions get relitigated, wasting time |
| [ ] | ToDos.md contains only open items (ephemeral rule enforced) | Defer | Stale todos are noise but not harmful |
| [ ] | DOCUMENTATION_STANDARDS.md is current and followed | Defer | Standards drift is slow -- catch it periodically |

### 4. Gap Analysis

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | Are there features implied by the architecture but never specified? | Defer | Unspecified future features are fine -- just don't build toward them blindly |
| [ ] | Are there user journeys that aren't covered? (First-time user, returning user, team admin, billing admin) | Soon | Missing journeys surface as UX gaps during alpha |
| [ ] | Are there edge cases mentioned but not addressed? (Offline behavior, concurrent edits, large files) | Soon | Unaddressed edge cases become the bugs users find first |
| [ ] | Are there integration points between components that aren't fully specified on both sides? | Urgent | Underspecified integration points cause the most expensive rework |
| [ ] | Are there third-party integrations mentioned but not architected? | Soon | Third-party assumptions change -- better to validate early |
| [ ] | Are there sections that are too thin to actually build from? (Would a developer know what to do?) | Soon | Thin sections cause builders to guess, creating drift from intent |

### 5. Risk Register

Identify and categorize risks:

| Risk Category | What to Look For | Risk Factor |
|--------------|-----------------|-------------|
| **Technical** | Unproven technology choices, single points of failure, scaling bottlenecks, performance cliffs | Soon |
| **Dependency** | Critical reliance on third parties (LLM providers, auth, database, etc.), vendor lock-in | Soon |
| **Complexity** | Over-engineered sections, unnecessary abstraction layers, features that could be simpler | Defer |
| **Build Order** | Circular dependencies between components, features that can't be built incrementally | Urgent |
| **Security** | Gaps in the security architecture, unvalidated assumptions about auth/encryption -- **run Security Audit for detailed coverage** | Urgent |
| **Cost** | LLM cost assumptions that may not hold, infrastructure costs at scale | Soon |
| **Team** | Architecture that requires expertise the team doesn't have, bus factor risks | Soon |
| **Timeline** | Features that are much larger than they appear, hidden complexity | Soon |

For each risk identified:
- **Severity:** Critical / High / Medium / Low
- **Likelihood:** Likely / Possible / Unlikely
- **Current mitigation:** What's already in place (if anything)
- **Recommended action:** What should be done

### 6. Mitigation Review

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | For every risk identified in previous reviews: Is the mitigation still valid? | Soon | Stale mitigations create false sense of security |
| [ ] | Have any mitigations been implemented since the last review? | Defer | Tracking progress -- not urgent if risks are stable |
| [ ] | Are there risks that have increased in severity since last review? | Urgent | Escalating risks need immediate re-evaluation |
| [ ] | Are there new risks that weren't present in the last review? | Soon | New risks should be captured before they grow |

### 7. Build Order Feasibility

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | Can the system be built incrementally in the order implied by priorities and maturity tags? | Soon | Non-incremental builds force big-bang integration -- risky |
| [ ] | Are there hard dependencies that force a specific build order? Are they documented? | Urgent | Undocumented hard deps cause blocked sprints |
| [ ] | Is there a critical path? What's on it? | Soon | Knowing the critical path prevents accidental delays |
| [ ] | Are there components that could be built in parallel? | Defer | Optimization -- nice to know but not blocking |
| [ ] | What's the minimum viable slice that could be deployed? | Soon | Defines the alpha milestone -- important for planning |

### 8. ADR Health

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | Are all ADRs in `decisions/` still valid? | Defer | Stale ADRs cause confusion but rarely block work |
| [ ] | Should any ADRs be superseded based on new information or changed requirements? | Soon | Outdated ADRs lead to building on reversed decisions |
| [ ] | Are there decisions made since the last review that should have ADRs but don't? | Soon | Undocumented decisions get relitigated |
| [ ] | Is the ADR index (`decisions/README.md`) current and complete? | Defer | Index hygiene -- catch it periodically |

### 9. Security Audit

Run through the standalone `security-checklist.md` in this directory. That checklist is the detailed reference -- this section ensures security is never skipped during an architecture review.

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | Run `security-checklist.md` end to end | Urgent | Security gaps compound -- catching them early is 10x cheaper than post-launch |
| [ ] | All Urgent items from the security checklist are addressed or have a mitigation plan | Urgent | Urgent security items can block launch or create liability |
| [ ] | All Soon items from the security checklist are tracked in ToDos.md | Soon | Ensures nothing falls through the cracks between reviews |
| [ ] | Security findings are included in the Risk Register (above) | Soon | Security risks must be visible alongside other project risks |

### 10. Cross-Component Consistency

The sections above review each component's internal quality. This section checks whether components **agree with each other** and with the ADRs. This is a full sweep -- read AGENTS.md chains, templates, config files, and ADRs across all components.

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | **Terminology consistency:** Do all living specs use the same terms for the same concepts? | Soon | Terminology drift confuses builders and AI sessions, causing wrong assumptions |
| [ ] | **Template-spec alignment:** Do provisioning templates match what ARCHITECTURE.md and ADRs describe? | Soon | Templates are what actually gets deployed -- if they're wrong, every new instance is wrong |
| [ ] | **ADR-reality alignment:** For each ADR marked "implemented", verify that the implementation matches what the ADR decided | Soon | ADRs say what we decided; reality may have drifted during implementation |
| [ ] | **Cross-component contracts:** Where one component references another's structure, verify both sides agree on the contract | Urgent | Broken cross-component contracts cause integration failures |
| [ ] | **Config format consistency:** Do all components that read config files expect the same schema? | Soon | Schema disagreements cause silent failures |

**How to run this section:**

1. For each component, read the AGENTS.md entry point and follow the routing chain to understand current structure.
2. Read all ADRs (or at minimum, all ADRs referenced in ARCHITECTURE.md files).
3. Run grep sweeps for known patterns and any terminology changes from recent ADRs.
4. Cross-check: for every assumption one component makes about another, verify the other component's docs confirm it.
5. Document findings in the report.

**Output:** Findings from this section that require more than 5 action items should produce a structured plan in `build/plans/` (see `plans/AGENTS.md` for the plan format). Smaller findings go directly into the review report's action items.

### 11. Priority Reconciliation

Before finalizing findings, cross-reference every finding against `PRIORITIES.md` to determine whether the issue is already planned, partially addressed, or genuinely new. This prevents the review from flagging work that's already queued, and ensures review recommendations land in the right place.

| | Check | Risk Factor | Why |
|---|-------|-------------|-----|
| [ ] | Read `PRIORITIES.md` (active stack, queued, and deferred sections) | Required | Foundation for all checks below |
| [ ] | For each finding: is it already covered by an existing priority? If so, annotate the finding with the priority slug and downgrade severity if appropriate | Required | Prevents duplicate work and false urgency |
| [ ] | For findings that map to existing priorities: does the priority's description adequately capture the issue? If not, recommend adding a note | Soon | Ensures the priority session has full context when it starts |
| [ ] | For findings that are genuinely new: recommend whether they warrant a new priority, a note on an existing one, or a ToDos.md entry | Required | Every finding must have a home |
| [ ] | Are any existing priorities stale or resolved? | Defer | Hygiene; prevents stale priorities from occupying queue slots |
| [ ] | Does the review suggest reordering priorities? If so, note the reasoning but do not reorder -- flag for founder decision | Soon | Priority order is a founder decision, not a review output |

**How to run this section:**

1. Read `PRIORITIES.md` in full (active, queued, deferred).
2. For each finding in the report, search for matching priority by keyword, component, or slug.
3. Annotate matched findings: "Already tracked as [SLUG]" or "Partially covered by [SLUG] -- recommend adding note about X."
4. For unmatched findings, recommend placement: new priority, note on existing priority, or ToDos.md.
5. Add a Priority Reconciliation section to the report summarizing the mapping.

---

## Report Format

Every review report follows this structure:

```markdown
# Architecture Review -- YYYY-MM-DD

## Summary
[2-3 sentence overall assessment]

## Findings

### Urgent (must address before next milestone)
| # | Finding | Section | Risk Factor | Recommendation |
|---|---------|---------|-------------|----------------|

### Soon (should address within 1-2 sprints)
| # | Finding | Section | Risk Factor | Recommendation |
|---|---------|---------|-------------|----------------|

### Defer (track and revisit next review)
| # | Finding | Section | Risk Factor | Recommendation |
|---|---------|---------|-------------|----------------|

## Security Audit Summary
[Key findings from security-checklist.md -- urgent items, new risks, resolved items since last review]

## Risk Register Update
[New risks, changed risks, resolved risks since last review -- including security risks]

## Tech Stack Changes
[Any recommendations to add, remove, or swap technologies]

## Priority Reconciliation
[For each finding: is it already tracked in PRIORITIES.md? Map findings to priority slugs. Identify genuinely new items that need a priority, a note, or a ToDos.md entry. Flag any stale or resolved priorities.]

## Action Items
[Numbered list of specific actions with owners and target dates. Actions that map to existing priorities should reference the slug rather than creating parallel work.]

## Next Review
[Recommended date for next review]
```

---

## How to Run This Review

1. Open this checklist alongside the architecture docs
2. Work through sections 1-10 systematically -- do not skip sections
3. For each checklist item, note findings in the report
4. Severity ratings must be justified (not just a gut feeling)
5. Every finding must have a specific recommendation
6. **Run section 11 (Priority Reconciliation) before finalizing.** Cross-reference every finding against PRIORITIES.md. Annotate findings that are already tracked. Downgrade severity for issues with existing plans. Add notes to existing priorities where the finding adds new context.
7. The report is committed to `build/quality/reviews/` with today's date
8. Action items from the report become:
   - **Notes on existing priorities** if the finding maps to a queued or active priority
   - **Direct architecture doc edits** if the fix is obvious
   - **ToDos.md entries** if they need design or research
   - **A structured plan in `plans/`** if section 10 (cross-component consistency) produces more than 5 action items -- see `plans/AGENTS.md` for the plan format
   - **New priority entries** only if the finding is genuinely untracked and warrants a priority slot
