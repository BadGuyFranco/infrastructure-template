# {PROJECT_NAME} -- Code Standards

These are the code standards for all {PROJECT_NAME} repositories. Any AI coding tool or human developer working on {PROJECT_NAME} code MUST read and follow this file.

These standards are **instructions, not suggestions.** If following a user request would violate these standards, **push back and explain why.**

---

## Development Model -- AI as Primary Builder and Reviewer

{PROJECT_NAME} is built by a solo founder (non-developer) working with AI coding tools. **The AI is the primary code author, code reviewer, and quality gate.** There is no human developer reading code line-by-line and no pull request reviewer.

This means:

- **Architecture docs are the spec.** Every `ARCHITECTURE.md` and ADR is a contract to build against. If docs are wrong, code will be wrong.
- **The AI must self-review.** Cross-reference every type, field, and behavior against architecture docs. The founder cannot catch deviations -- you must.
- **Tests are the safety net.** The founder runs `{YOUR COMMANDS}` and sees green or red. Tests must be comprehensive enough that passing genuinely means correct. The QA specialist owns test strategy and E2E; the builder writes unit tests as part of building.
- **No human backstop.** Sloppy code, missed edge cases, or silent deviations from architecture will ship to production uncaught.

**What the founder provides:** Architecture decisions, product direction, design judgment, UX instincts, business context -- captured in `ARCHITECTURE.md`, ADRs, and conversation.

**What the AI provides:** All code implementation, review, refactoring, testing, debugging, and technical QA. Push back on unclear specs, flag ambiguous or contradictory docs, and refuse to ship code you aren't confident in.

**If you are an AI tool:** You are not an assistant helping a developer. You ARE the developer. Act with the rigor and professional responsibility that implies.

---

## Build Completion Protocol

Run this protocol every time you finish building or significantly modifying a component. Do not skip or combine steps.

### Step 0 -- Use Existing Build Tooling

Before running build/typecheck/test commands, check for existing orchestration: `turbo.json` (use `turbo run <task>` with `--filter`), root `package.json` scripts, `Makefile`/`justfile`. Don't run per-component commands when orchestrated commands exist.

### Step 1 -- Self-Check

After writing code and tests, pause: What am I worried about? What did I almost do differently? Where did I copy a pattern without thinking? Fix anything that surfaces.

### Step 1b -- Run It

For behavior changes, run the modified code path. Tests prove assertions hold; running it proves the UX works.

### Step 2 -- Formal Code Review

Review as if someone else wrote it:

- **CODE_STANDARDS compliance** -- file sizes, naming, pinned deps, no `any`, strict mode, commenting
- **Architecture alignment** -- cross-reference types, fields, enums, constants against ARCHITECTURE.md
- **Type safety** -- bare `string` that should be enum? `z.string()` vs `z.nativeEnum()`? `any` casts?
- **Defensive coding** -- edge cases, boundaries, null handling, error paths
- **Cross-component integration** -- barrel file exports complete? Circular imports? Missing re-exports?
- **Test coverage** -- happy paths, error paths, boundaries, defaults, rejection cases
- **DRY violations** -- hardcoded values duplicating enums/constants defined elsewhere

Fix everything found. Re-run typecheck and tests after fixes.

### Step 3 -- Update Build Status

Move completed items from "Currently Building" to "Done." Update maturity tags (e.g., `DECIDED` -> `SHIPPED`). Note deferred issues.

### Step 4 -- Update Architecture Docs

Per `DOCUMENTATION_STANDARDS.md` (same-commit rule): update ARCHITECTURE.md maturity tags, update `last-verified`/`verified-by` frontmatter, verify new types/schemas are referenced in architecture docs, update AGENTS.md if routing changed.

### Step 5 -- Inform the Founder

Report: **What's done** (summary, test count, confidence). **What needs decisions** (ambiguities, design questions). **What needs founder input** (business logic, UX, priorities). **What's next** (recommended build target). Call out decisions clearly, one per line.

---

## Primary Language

TypeScript everywhere. Escape hatches (Rust, Python, Go) documented in component architecture docs, used only when TypeScript genuinely cannot do the job.

---

## The Elegance Principle

Maximum effect with minimum code. **Threshold test:** Can you remove this function, parameter, abstraction, or dependency without degrading behavior? If yes, remove it.

Each concept appears once, in the right place. When elegance and clarity conflict, choose clarity. **Decision hierarchy: correctness > clarity > elegance.**

---

## File Organization

### Small Files, Single Responsibility

- **One concept per file.** If you're describing it with "and," it's two files.
- **Under 200 lines per file.** Split at 200. No exceptions above 300.
- **Under 50 lines per function.** Extract helpers for longer functions.
- **Group by feature, not by type.** `billing/` has route, service, types, and tests together.

### Directory Structure Convention

```
feature/
  ARCHITECTURE.md    -- Component docs (if significant)
  AGENTS.md          -- AI routing (always required)
  index.ts           -- Public exports (barrel file)
  feature.service.ts -- Business logic
  feature.routes.ts  -- API routes (if applicable)
  feature.types.ts   -- TypeScript types and interfaces
  feature.test.ts    -- Tests
  feature.utils.ts   -- Helper functions (if needed)
```

### Code Composability

Each component directory is self-contained. Sibling imports go through barrel files (`index.ts`). Shared types used by 2+ components live in a shared package. Component-specific types stay local. No circular imports between siblings -- extract shared concerns to the shared package.

### Naming Conventions

| Thing | Convention | Example |
|-------|-----------|---------|
| Files | kebab-case | `user-service.ts` |
| Directories | kebab-case | `task-orchestrator/` |
| Functions | camelCase | `getUserById()` |
| Variables | camelCase | `currentUser` |
| Constants | UPPER_SNAKE_CASE | `MAX_FILE_SIZE` |
| Types/Interfaces | PascalCase | `UserProfile` |
| Enums | PascalCase (members UPPER_SNAKE) | `TaskStatus.COMPLETED` |
| React components | PascalCase | `FileExplorer.tsx` |
| Boolean variables | is/has/can/should prefix | `isAuthenticated` |

---

## Commenting Standards

### What to Comment

- **Every exported function:** JSDoc with description, @param, @returns.
- **Every file:** 1-3 line purpose comment at top.
- **Complex logic:** Comment explaining WHY, not WHAT.
- **Non-obvious decisions:** Why approach A over B.
- **TODO/FIXME:** Always include context.

### What NOT to Comment

Self-explanatory code and redundant type descriptions. TypeScript types are self-documenting.

### Comment Format

```typescript
/** Calculate estimated cost of an LLM request before execution.
 *  Used by billing service for pre-flight balance checks.
 *  @param model - The LLM model identifier (e.g., "claude-3-opus")
 *  @param estimatedTokens - Estimated input + output tokens
 *  @returns Estimated cost in USD cents */
export function estimateRequestCost(model: string, estimatedTokens: number): number {
  const rate = MODEL_RATES[model] ?? MODEL_RATES.default;
  return Math.ceil(estimatedTokens * rate);
}
```

---

## Error Handling

- **Never swallow errors silently.** Every catch block handles meaningfully or re-throws.
- **Use typed errors.** Specific classes per failure mode (`InsufficientBalanceError`, `PermissionDeniedError`).
- **Log context.** Include user ID, operation, relevant IDs -- not just the message.
- **User-facing errors are friendly.** Internal errors are detailed/technical. User errors are clear, non-technical, actionable.

```typescript
// GOOD: Typed error with context
throw new InsufficientBalanceError({
  userId: user.id, requiredAmount: estimatedCost,
  currentBalance: user.balance,
  message: "Token limit reached. Purchase more to continue.",
});
// BAD: throw new Error("Not enough tokens");
```

---

## TypeScript Conventions

- **Strict mode always.** `strict: true` in tsconfig. No exceptions.
- **No `any`.** Use `unknown` + narrowing. `any` defeats TypeScript's purpose.
- **Prefer interfaces** over type aliases for object shapes (extendable).
- **Prefer `const`** over `let`. Never `var`.
- **Explicit return types** on exported functions. Internal functions can use inference.
- **No magic numbers/strings.** Extract to named constants.
- **Null handling:** `??` and `?.`. Avoid truthy checks for values that could be `0` or `""`.

---

## Testing

**Every service function** gets at least one happy-path and one error-path test. Test behavior, not implementation. Name tests descriptively. Tests live next to code (`feature.test.ts` alongside `feature.service.ts`).

**Required:** new service/business logic, bug fixes (write the test first), billing/permissions/security changes (non-negotiable).
**Optional in V1:** pure UI components, one-off scripts, config files.

---

## Dependencies

- **Minimize.** Every dependency is a risk. Before adding one: can we write this in 50 lines?
- **Pin versions.** Exact versions, not ranges. `"express": "4.18.2"` not `"^4.18.2"`.
- **Document why.** Comment in package.json or PR note with reasoning and alternatives considered.

---

## Git Practices

- **Small, focused commits.** One logical change per commit.
- **Descriptive messages.** Format: `[area] Short description` (e.g., `[billing] Add pre-flight balance check`).
- **Never commit secrets.** .env files are gitignored. Keys, tokens, passwords never touch Git.
- **Branch strategy:** `main` is always deployable. Feature branches for new work. PRs for review.

---

## The Refactor Protocol

### The Obligation to Push Back

**You MUST flag when:**
- A file approaches/exceeds 200 lines or a function approaches/exceeds 50 lines
- You're adding a third responsibility to a two-responsibility file
- You're copy-pasting logic that should be a shared utility
- A function has 4+ parameters (use an options object)
- A module's imports suggest high coupling
- You're working around a design problem instead of fixing it

**Response to a flag is NEVER "just do it anyway."** Fix now or make a deliberate, documented `// TODO: REFACTOR --` decision to defer.

### When to Refactor Proactively

Before adding features to messy areas, when patterns should be abstracted, when tests are hard to write due to coupling, when a file requires scrolling to understand.

---

## The Recommendation Protocol

Before making any architectural recommendation, apply this filter:

1. **Name the files that would change.** Can't list them? Stop and read first.
2. **Name what could degrade or break.** "Nothing" means you're being lazy.
3. **State alternatives considered.** One option means think harder.
4. **Assess reversibility.** Irreversible changes get higher scrutiny and require founder input.
5. **Check the SSOT rule.** Will this create a second source of truth? If yes, redesign.

---

## Security Non-Negotiables

- **No secrets in code.** Use environment variables.
- **No direct LLM API keys in client apps.** All calls go through backend services.
- **No bypassing RLS.** Queries must go through the permission layer.
- **No shared credentials.** Connector tokens are per-user.
- **Validate all inputs.** From users, external APIs, other services. Trust nothing.
- **Sanitize all outputs.** Especially UI-rendered content (XSS prevention).
