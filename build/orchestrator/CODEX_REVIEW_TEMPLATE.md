# Codex Second-Opinion Review

Bolt-on section for adding a Codex (GPT) second-opinion review to any sub-agent dispatch. Not a standalone dispatch type -- augments the existing templates.

## Drop-In Block

Add this section to a sub-agent dispatch prompt. Placement varies by template (see Integration below).

```
## Codex Second-Opinion Review

After completing your primary work, run a Codex review of your own output. This is non-mandatory -- if Codex is unavailable or times out, continue without it and note `codex-review: skipped (reason)`.

### What to send Codex

Construct a single prompt that includes:
1. **Source file paths** -- list the files Codex should read. Codex reads them fresh from disk, giving it independent context. For large changesets, send only the diff and spec references instead of full file paths.
2. **Your conclusions** -- your findings, verdicts, or deliverables.
3. **A review question** from this menu (pick the one that fits your dispatch type):
   - Build verification: "What did this verification miss? Are there contradictions between the spec and the implementation? What edge cases were not tested?"
   - Research: "What evidence in the source material contradicts these findings? What alternative interpretations were not considered? What was assumed but not verified?"
   - Dependency/blast-radius: "What consumers of this interface were missed? What transitive dependencies were not traced? What build or test configurations would break?"

CRITICAL: Always include source file paths or diffs. If Codex only sees your conclusions, it will critique your writing style instead of finding real issues.

### How to evaluate Codex findings

For each finding Codex returns, classify it:
- **Valid** -- Codex found something real that you missed. Incorporate it.
- **Overstated** -- Codex identified a real tension but misread the design intent. Note it briefly.
- **Noise** -- Codex pattern-matched on surface overlap without understanding intentional design. Discard it.

Do not blindly accept or blindly discard. Use your judgment.

### How to report

Append to your output:

**Codex Review:**
- Status: [completed / skipped (reason)]
- Findings evaluated: [N]
- Valid: [list -- 1 line each]
- Overstated: [list -- 1 line each]
- Discarded as noise: [count]
- Changes to my conclusions: [what I updated based on valid findings, or "none"]
```

## Prompt Skeleton

One reusable skeleton. Adapt the review question from the menu above.

```
Review this [dispatch type] analysis. Source material follows.

FILES: [file paths -- Codex reads them from disk]
SPEC REFERENCES: [ARCHITECTURE.md sections, ADR numbers, or schema files]

CLAUDE'S [VERDICT/FINDINGS/ASSESSMENT]:
[paste your output]

REVIEW QUESTION: [pick from menu above]
```

## Integration by Template

| Template | Where to insert the drop-in block | Where to append the Codex Review output |
|----------|----------------------------------|----------------------------------------|
| `DISPATCH_TEMPLATE.md` | After Verification, before Self-Review | New bullet block in the Completion Report |
| `QA_DISPATCH_TEMPLATE.md` | After the mandatory pre-step and test execution, before producing the QA Report | New section in the QA Report, after Deferred |
| `RESEARCH_DISPATCH.md` | After completing the research, before returning findings | New field in the suggested output format, after Implications |

## Why

Claude and GPT fail differently. Claude is stronger at architecture, edge cases, and intent preservation. GPT/Codex is stronger at mechanical verification, dependency tracing, and catching policy contradictions across documents. Running both on the same material catches issues neither finds alone.

## When to Use

- Cross-document policy or spec verification
- Dependency or blast-radius analysis
- Review of another persona's output
- Any task where the lead persona suspects Claude may satisfice

Do NOT use for simple single-file tasks, single-command verifications, or code generation (Codex reviews only -- Claude writes all code).
