# Deploy Verification -- Smoke and Soak Tests

**Shared checklist.** Referenced by Bob (runner), Oscar (verifier), and Talia (QA scope).

## Smoke Test

**What:** Post-deploy sanity check. Is this deployment alive and able to serve requests?
**When:** After every staging and production deploy. Automated in your deploy pipeline, but verify manually too.
**Who runs it:** Bob, as part of the deploy checklist.
**Pass criteria:** Health endpoint returns `ok` with all components passing. One authenticated API call returns HTTP 2xx within 5 seconds. Total time < 30 seconds.

```bash
# Replace with your actual staging/production URL
curl -s https://staging.example.com/health | jq .
```

<!-- If you have a smoke test script, invoke it here:
npx tsx build/quality/testing/smoke/smoke-test.ts
-->

**Exit codes:** 0 = pass, 1 = fail (with diagnostic output).

## Soak Test

**What:** Sustained varied traffic for a fixed duration. Surfaces memory leaks, connection pool exhaustion, latency drift, and other problems that only appear under load or over time.
**When required:** Before declaring a priority complete, if that priority changes runtime behavior (API routes, database queries, service orchestration, connection handling, caching, or deployment topology). Not required for documentation-only, config-only, or frontend-only priorities.
**Who runs it:** Bob, against staging, after the build is deployed and smoke-tested.
**Who verifies:** Oscar, at priority-complete. Talia, if dispatched for build verification or regression sweep on that priority.

**Pass criteria -- universal kill criteria (K0):**

| ID | Threshold |
|----|-----------|
| K0-ERR | Error rate < 1% cumulative |
| K0-HEALTH | Health endpoint `ok` at every poll |
| K0-P95 | Overall p95 latency < 2000ms |
| K0-MEM | Memory growth < 50% RSS over test duration |

Domain-specific criteria are defined per scenario. All K0 + domain criteria must hold for the entire run.

<!-- Replace with your actual soak test command when you build one:
npx tsx build/quality/testing/soak/harness.ts \
  --scenario=<path-to-scenario> \
  --duration=15m
-->

**Exit codes:** 0 = all pass, 1 = any fail, 2 = crash.
**Report:** Soak results (pass/fail, duration, any violated criteria) must be recorded in the SESSION_LOG entry for the priority.

## Roles

| Persona | Responsibility |
|---------|---------------|
| **Bob** | Runs smoke test after every deploy (deploy checklist). Runs soak test before declaring a runtime-affecting priority complete. Reports results in SESSION_LOG. |
| **Oscar** | At priority-complete: if the priority changes runtime behavior, verify Bob ran a soak test and it passed. "Tests pass" is not sufficient for runtime priorities -- ask for soak results. At phase-transition: if Bob references a soak or smoke test, verify the procedure exists and was actually executed (not just planned). |
| **Talia** | Soak test results are in scope for build verification and regression sweep dispatches on runtime-affecting priorities. If soak was required but not run, report it as a gap. If soak results show borderline criteria (e.g., K0-P95 at 1900ms), flag it as an anomaly. |

## How to Determine "Changes Runtime Behavior"

A priority changes runtime behavior if it modifies any of: API route handlers, database queries or schema, service-to-service communication, connection pools or caching, background job processing, authentication or authorization flow, deployment topology or infrastructure. When in doubt, run the soak -- false positives cost 15 minutes, false negatives cost production incidents.
