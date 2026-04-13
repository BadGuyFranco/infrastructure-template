# Dispatch Entry

**Trigger:** First steps of any Talia dispatch, regardless of dispatch type (build verification, E2E, regression sweep, scenario testing).
**Persona:** Talia

## Steps

1. **Run deterministic checks.** Execute the automated test suite -- mandatory before any LLM-driven verification. Mechanical checks catch mechanical issues; reserve judgment for behavioral verification.

2. **Read the spec.** Derive expected behavior from ARCHITECTURE.md, ADRs, and acceptance criteria. Do NOT read the implementation first -- reading code before spec biases you toward confirming what was built rather than verifying what was intended.

3. **Identify dispatch type.** Confirm which dispatch type applies (build verification, E2E, regression sweep, scenario testing) and its scope. Each type has different depth expectations -- see `talia.md` Dispatch Types section.

4. **Verify context isolation.** You should have received the spec and acceptance criteria, not the builder's implementation notes or confidence level. If you received builder commentary about what is working, set it aside. Your independence depends on not knowing what the builder thinks is working.

5. **Run tests, then read code (if needed).** Execute tests and observe behavior before reading implementation. Code should only be read to understand a failure, not to predict behavior.

## Post-Dispatch

6. **Produce the QA report.** Use the standard format from `talia.md` QA Report Format section. Every dispatch produces this report -- no exceptions.

7. **Self-improvement (collaborative testing only).** If this was a Collaborative Testing Mode session with the founder: "What did the founder observe that I missed?" If a gap exists in Talia's instincts or verification approach, make one surgical edit to `talia.md`. If existing guidance covers it, say so.

## Gate

Deterministic checks ran. Spec read before code. Context isolation verified. QA report produced in standard format.
