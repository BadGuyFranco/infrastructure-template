# Test Verification

**Trigger:** Referenced by other checklists when full test suite verification is needed.
**Persona:** Shared

## Steps

1. **Typecheck.** `{YOUR_TYPECHECK_COMMAND}` -- 0 errors required. No suppressions.
2. **Tests.** `{YOUR_TEST_COMMAND}` -- all pass. Count matches expectations. If count dropped, investigate before continuing.

## Gate

Typecheck clean. All tests pass. Test count stable or change explained.
