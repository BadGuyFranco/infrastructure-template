# Verification Standards

Code review protocol and component-level verification criteria.

## Done Gate

The post-build verification checklist has moved to `../build-personas/checklists/bob/done-gate.md`. Load and execute it before reporting work as complete. It includes: self-review, hygiene checks, typecheck/test, intent verification, UX verification, elegance checkpoint, congruence review, and QA dispatch.

## Component Verification Criteria

When touching a component, verify these properties. These are the criteria the done-gate checklist's "congruence review" step checks against.

### Automated (run every time)

1. `{YOUR COMMANDS}` -- typecheck passes with 0 errors
2. `{YOUR COMMANDS}` -- all tests pass, count matches expectations
3. No build artifacts committed (dist/, .next/, out/, *.tsbuildinfo)
4. No .env files committed

### Test Session Integrity (when session involved testing)

1. No files in the system under test were modified to make tests pass
2. No staging or production data was written without explicit founder approval
3. If a test failed due to missing infrastructure, the gap was reported -- not bridged by degrading the component

### Component Hygiene

1. ARCHITECTURE.md verification stamps current (last-verified date = today)
2. ARCHITECTURE.md maturity tags match actual code state
3. All new source files exported from barrel file (index.ts)
4. tsconfig.json extends base (if applicable)
5. package.json has "typecheck" script
6. Component has vitest.config.ts
7. No hardcoded values that should reference shared constants/enums

## Code Review Protocol

When conducting a code review (post-build or on-demand):

1. **Read the component's ARCHITECTURE.md** -- verify every claim against actual code
2. **Check type safety** -- look for `any`, bare `string` where enums belong, missing Zod validation
3. **Check barrel exports** -- every public type/service in src/ should be in index.ts
4. **Check test coverage** -- happy path + error path + boundary for every service function
5. **Check cross-component contracts** -- do imported types from siblings match what's exported?
6. **Check for drift** -- has the code moved away from what ARCHITECTURE.md describes?
7. **Check internal quality (spaghetti detection)** -- these catch tangled code inside clean interfaces:
   - **Separation of concerns:** Does any function mix I/O with business logic? Business rules should be testable without mocking I/O. If you cannot test the logic without standing up a database, HTTP client, or filesystem, the concerns are tangled.
   - **Single responsibility:** Describe each file in one clause, no conjunctions. "Fetches data AND transforms it AND persists it" is three files. A 150-line file that handles three unrelated responsibilities is a god service regardless of line count.
   - **Import fan-out:** Count distinct package-level imports per file. 6+ is a coupling signal -- the file knows too much about too many siblings. It should be split or re-layered.
   - **Reach-through imports:** Any import that bypasses a barrel file (`@{project-name}/foo/src/internal/thing` instead of `@{project-name}/foo`) couples to internal structure. These break silently when the sibling refactors.
   - **Nesting depth:** If control flow requires counting brackets to follow, it needs guard clauses, early returns, or helper extraction. 4 levels is a warning, 5 is a rewrite.
   - **Dependency direction:** High-level modules (orchestrators, services) should not import from low-level module internals. Dependencies should flow downward. Check that the dependency graph is layered, not a web.
8. **Report findings** as: must-fix (blocks commit), should-fix (next session), and verified-ok
