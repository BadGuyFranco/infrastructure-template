---
description: Testing standards for test files
globs: ["**/*.test.ts", "**/*.spec.ts"]
---

# Testing Standards

## Structure

- **One test file per source file.** `user-service.ts` -> `user-service.test.ts` in the same directory or a `__tests__/` sibling.
- **Describe blocks mirror the public API.** One `describe` per exported function or class.
- **Test names state the expectation:** `it('returns 404 when user does not exist')` not `it('handles missing user')`.

## Assertions

- **Prefer specific matchers.** `toEqual` over `toBeTruthy`. `toHaveLength(3)` over `toBe(true)`.
- **One logical assertion per test.** Multiple `expect` calls are fine if they verify different aspects of the same operation. Multiple unrelated assertions belong in separate tests.
- **Assert the negative.** For every happy-path test, write at least one test for the failure case.

## Mocking

- **Mock at boundaries, not internals.** Mock HTTP clients, databases, and external services. Do not mock internal functions to make tests easier to write.
- **If a mock hides a real bug, the mock is wrong.** If bugs appear at the boundary you mocked, replace the mock with an integration test.
- **Count your mocks.** If a test file has more mock setup lines than assertion lines, the test is testing the mock, not the code.

## Test Data

- **Use factories, not fixtures.** Create test data programmatically with sensible defaults and overrides. Fixture files drift from reality.
- **No magic values.** `createUser({ name: 'test-user' })` not `createUser({ name: 'John' })`. Test data should be obviously fake.

## Performance

- **Tests must be fast.** Each test file should complete in under 5 seconds. Slow tests indicate missing mocks at I/O boundaries or unnecessary setup.
- **No `sleep` in tests.** If you need to wait for an async operation, use proper async patterns (await, polling with timeout).
