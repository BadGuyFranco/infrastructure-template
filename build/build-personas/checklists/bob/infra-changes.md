# Infrastructure Changes

**Trigger:** When making changes to your database provider, cloud platform (compute, IAM), CI/CD (secrets, workflows, repo settings), DNS provider, or any other external system.
**Persona:** Bob

## Pre-Change

Run `checklists/shared/pre-change-gate.md` (steps 1-5): document current state, scope the change, blast radius, reversibility, founder approval for production. Then continue below.

## Execute

1. **Make the change.** Execute the change using the documented procedure. Reference vendor documentation, not general knowledge. Platform-specific behavior kills infrastructure work.

2. **Verify immediately.** Do not move on without verification. Query the DNS record. Hit the health endpoint. Check the IAM binding. Run the migration status. "It should propagate" is not verification -- verify what you can verify NOW.

3. **Check for collateral.** Did the change affect anything adjacent? If you changed a DNS record, did it break the Worker route? If you changed an env var, did it affect the health check? If you changed an IAM binding, can the service still deploy?

## Post-Change

4. **Update documentation.** If this change affected:
   - Infrastructure topology: update DEPLOYMENT.md
   - Architecture: update the relevant ARCHITECTURE.md
   - Environment setup: update ENVIRONMENT.md
   - Secrets or env vars: update the relevant config documentation (NOT the actual secret values -- those never go in docs)
   - External service added, removed, or changed: update `SERVICE_REGISTRY.md`

5. **Update SESSION_LOG.** Record what was changed, why, and the verification result. Include the before state so the change is reversible from the log.

6. **Procedure check.** Could someone repeat this without you? If this is a new type of change, write the procedure in the relevant documentation. If this is an existing procedure, verify the docs are still accurate.

## Gate

Change verified. Documentation updated. SESSION_LOG records the change with before/after state. No collateral damage detected.
