---
description: TypeScript coding standards for all .ts and .tsx files
globs: ["**/*.ts", "**/*.tsx"]
---

# TypeScript Standards

## File Size

- **Hard limit: 300 lines.** If a file exceeds 300 lines, split it before adding more code. The PostToolUse hook enforces this automatically.
- **Target: 200 lines.** Aim for 200 lines or fewer. Files between 200-300 are a signal to plan a split.

## Type Safety

- **Never use `any`.** Use `unknown` and narrow with type guards, assertions, or conditional checks. The PostToolUse hook flags `any` usage automatically.
- **No `@ts-ignore` or `@ts-expect-error`** without an adjacent comment explaining why and a ticket reference for removal.
- **Prefer explicit return types** on exported functions and public methods. Inference is fine for internal helpers.

## Imports

- **No circular imports.** If two files import from each other, extract the shared type or function into a third file.
- **No reach-through imports.** Do not import from `../sibling/src/internal/`. Import from the package's public API.
- **Sort imports:** external packages first, then internal packages, then relative imports. One blank line between groups.

## Naming

- **Files:** kebab-case (`user-service.ts`, not `UserService.ts`)
- **Types/interfaces:** PascalCase (`UserProfile`, `CreateWorkspaceRequest`)
- **Functions/variables:** camelCase (`getUserById`, `isAuthenticated`)
- **Constants:** UPPER_SNAKE_CASE for true constants (`MAX_RETRY_COUNT`), camelCase for derived values

## Error Handling

- **Throw typed errors.** Do not throw raw strings. Create or use project error classes.
- **Catch specific errors** when the handler differs by error type. A bare `catch (e)` that logs and rethrows is noise.
- **Never swallow errors silently.** Every catch block must log, rethrow, or return an error result.

## Comments

- **No obvious comments.** `// increment counter` above `counter++` wastes tokens.
- **Explain WHY, not WHAT.** Code shows what; comments explain non-obvious reasoning.
- **TODO format:** `// TODO(persona): description -- YYYY-MM-DD` so staleness is detectable.
