# Research Dispatch

Reference menu for structuring research sub-agents. See `../plans/AGENTS.md` Step 1 for when and how to use this.

## Focus Areas

Use these as a starting menu. Pick the ones relevant to the problem. Add your own when the problem demands it.

| # | Focus Area | What the agent investigates |
|---|---|---|
| 1 | **Codebase audit** | What exists today. Read actual code, types, interfaces, tests. Map current state vs. documented state. Find stale assumptions. |
| 2 | **Pattern analysis** | What architectural patterns are relevant. How similar problems are already solved in this codebase. |
| 3 | **Best practices** | Industry and domain standards, conventions, known pitfalls. What a staff engineer would expect. |
| 4 | **Prior art** | How others have solved this. Open source implementations, libraries, well-known approaches. |
| 5 | **Radical alternatives** | Challenge the framing. What if the problem is stated wrong? What unconventional or cross-domain approaches exist? |
| 6 | **Falsification** | What would prove our current approach is wrong? Actively stress-test the leading hypothesis. Find the failure modes. |

## Dispatch Guidance

- Frame each agent as open-ended research, not confirmation. Do NOT bias agents toward the current proposal.
- Each agent gets a specific question, not just a focus area. "What patterns does our codebase use for credential injection?" is better than "investigate patterns."
- Ground research in real use cases, not test fixtures.

## Suggested Output Format

Each research agent should return:

```
**Question investigated:** [1 line]
**Key findings:** [3-5 bullets, evidence-based]
**Contradictions with known facts:** [if any -- flag these prominently]
**Implications for the plan:** [what this changes or confirms]
```

This is a suggestion, not a mandate. The goal is structured findings that make synthesis practical -- not walls of text the lead has to wade through.
