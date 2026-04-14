# Deploy to Staging or Production

**Trigger:** When deploying {PROJECT_NAME} services to staging or production.
**Persona:** Bob
**Reference:** `DEPLOYMENT.md` for bootstrap history. Your CI/CD pipeline configuration for the deploy workflow. Architecture decision records for environment topology.

## Pre-Deploy

1. **Confirm environment.** State the target environment (staging or production) and the trigger mechanism (e.g., push to `main` for staging, version tag for production). Say it before proceeding.

2. **Founder approval for production.** Staging is autonomous. Production requires explicit founder confirmation before proceeding.

3. **Local full CI pipeline.** Run the complete CI sequence before pushing — not just tests:
   ```bash
   # Lint
   {YOUR DEPLOY COMMANDS}  # e.g., pnpm exec eslint 'services/**/*.ts' --max-warnings 0

   # Build
   {YOUR DEPLOY COMMANDS}  # e.g., npx turbo run build --filter='./services/*'

   # Typecheck
   {YOUR DEPLOY COMMANDS}  # e.g., npx turbo run typecheck --filter='./services/*'

   # Test
   {YOUR DEPLOY COMMANDS}  # e.g., npx turbo run test --filter='./services/*'

   # Verify build artifacts
   {YOUR DEPLOY COMMANDS}  # e.g., node build/orchestrator/scripts/verify-build.js
   ```
   All steps. In this order. If any step fails, fix everything before pushing. Do not push after fixing one failure and hope the rest pass — run the full sequence again.

4. **Lockfile sync.** If any `package.json` was modified (yours or prior sessions), the lockfile may be stale:
   ```bash
   pnpm install --frozen-lockfile
   ```
   If this fails, run `pnpm install` (without `--frozen-lockfile`) to regenerate, then commit the updated lockfile alongside the changed `package.json` files. CI uses `--frozen-lockfile` and will fail on any mismatch.

5. **Surgical commits.** When the working tree has uncommitted changes from other priorities, stage only your files by name. Never `git add -A` or `git add .`. List the files you plan to stage and confirm before committing. Check `git status --short` after staging -- only your files should have markers in the first column.

6. **Validate env blob before pushing secrets.** Before pushing environment secrets to your CI/CD system, validate the local env file:
   ```bash
   # No single or double quotes around values (many parsers fail on literal quotes)
   grep "='" services/.env.staging && echo "FAIL: single quotes found" && exit 1
   grep '="' services/.env.staging && echo "FAIL: double quotes found" && exit 1
   # No PORT line (cloud platforms typically inject it)
   grep "^PORT=" services/.env.staging && echo "FAIL: PORT must not be set" && exit 1
   # Required keys present (customize for your project)
   for key in DATABASE_URL BETTERAUTH_SECRET ANTHROPIC_API_KEY ENCRYPTION_KEY; do
     grep -q "^$key=" services/.env.staging || echo "MISSING: $key"
   done
   echo "Env blob format OK"
   ```

7. **Pending database migrations.** Check whether your deploy pipeline handles migrations automatically or if they need manual execution. To generate a new migration:
   ```bash
   cd services/database
   pnpm db:generate    # generates SQL from schema changes
   # Review the generated SQL in migrations/NNNN_*.sql
   # Commit alongside schema changes
   ```

## Deploy -- Staging

8. **Push to main.** `git push origin main`. This triggers your deploy pipeline.

9. **Retrigger without empty commits.** If a deploy needs re-running (e.g., after updating a secret), re-run the existing workflow — do not create empty commits. Empty commits pollute git history and trigger unnecessary rebuilds.

10. **Monitor deploy.** Watch your CI/CD dashboard for completion. Total time varies by project.

11. **Verify health check.** Check your deploy logs for health check results:
    ```bash
    # Manual health check (replace with your staging URL)
    curl -s https://staging.example.com/health | jq .
    ```
    Expect: `status: "ok"`, all components healthy. If you have a smoke test script, run it per `checklists/shared/deploy-verification.md`.

12. **Do not tag for production until BOTH CI and staging deploy pass.** Verify both pipelines show success on the same commit before proceeding to production.

## Deploy -- Production

13. **Tag the release.** Only after step 12 confirms both CI and staging are green:
    ```bash
    git tag v<version>
    git push origin v<version>
    ```

14. **CI gate.** If your deploy pipeline has a CI gate, monitor it. Production deploy should not proceed until CI is green.

15. **Monitor production deploy.** Watch for the production deploy step to complete.

16. **First deploy of a new service.** If this is the first-ever deploy to a cloud service, IAM or authentication bindings may need manual configuration. Check your cloud provider's documentation for making the service publicly accessible.

17. **Verify production health check.** Same as staging (see `checklists/shared/deploy-verification.md` for pass criteria):
    ```bash
    # Replace with your production URL
    curl -s https://api.example.com/health | jq .
    ```

## Post-Deploy

18. **Soak test gate (runtime-affecting priorities only).** If the current priority changes runtime behavior (API routes, database queries, service communication, connection pools, caching, auth, or deployment topology), run a soak test against staging before declaring the priority complete. See `checklists/shared/deploy-verification.md` for commands, pass criteria, and the "changes runtime behavior" rubric. Record results in the SESSION_LOG entry. Skip this step for documentation-only, config-only, or frontend-only priorities.

19. **If a revision fails to start, diagnose before bypassing.** Check your cloud platform's logs for the failing revision. Do not force traffic to a failing revision or patch environment variables outside the pipeline -- these create drift between your secrets and what is running. If the pipeline can't deploy it, fix the root cause and redeploy through the pipeline.

20. **Update SESSION_LOG.** Record: environment, version/tag, health check result, any issues.

21. **Update documentation.** If this deploy changed infrastructure (new env vars, new secrets, new services, IAM changes), update DEPLOYMENT.md. If an external service was added or changed, update `SERVICE_REGISTRY.md`.

## Production Environment Secrets

**Maintain a local production env file** (gitignored) as the source of truth for your production secrets in CI/CD. If it does not exist, reconstruct it from your cloud platform's current configuration before making changes.

When production environment variables need updating:

1. Edit the local production env file.
2. Values that MUST differ from staging: `DATABASE_URL` (production database), `NODE_ENV` (`production`), `LOG_LEVEL` (`warn`).
3. Run the env blob validation from step 6 against the production file.
4. Push the updated env to your CI/CD secrets store.
5. Do not delete the local file — it is the only readable copy of the production env. CI/CD secrets are typically write-only.

## Rollback

22. **Cloud revision rollback.** Route 100% traffic to the previous revision using your cloud platform's traffic management CLI.

23. **Database rollback.** Write a corrective forward migration (no down migrations). For catastrophic data issues: use your database provider's point-in-time recovery if available.

24. **Broken tag.** Delete and re-tag after fixing:
    ```bash
    git tag -d v<version>
    git push origin :refs/tags/v<version>
    # fix, commit, push, verify CI + staging
    git tag v<version>
    git push origin v<version>
    ```

## Gate

Health check returns `ok` with all components healthy. SESSION_LOG updated. DEPLOYMENT.md current if infrastructure changed.
