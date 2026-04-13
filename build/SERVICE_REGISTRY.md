# {PROJECT_NAME} Service Registry

Single source of truth for every external service {PROJECT_NAME} depends on. All personas reference this file to understand what services exist, what they do, and what breaks if they fail.

**Maintenance rule:** When adding, removing, or changing an external service dependency, update this file in the same commit.

**Credential rule:** This file documents what services exist and how they connect. It never contains secrets, API keys, or passwords. Credential locations are listed so personas know where to find them.

**Test behavior key:** Each service entry includes a "Test behavior" line so personas know what is real vs. mocked in test and local dev environments.

**Last verified:** {DATE}

---

## Cost Summary

Approximate monthly cost at zero users (development/staging only). Update when adding services or changing plans.

| Service | Cost Model | Estimated Monthly (pre-launch) |
|---------|-----------|-------------------------------|
| {Database Provider} | {cost model} | ~${AMOUNT} |
| {Cloud Provider} | {cost model} | ~${AMOUNT} |
| {LLM Provider} | Per-token | Variable |

---

## Core Infrastructure

Services the product cannot function without. If any of these fail, user-facing functionality degrades or stops.

### {Database Provider} (e.g., PostgreSQL)

- **Purpose:** Primary database. Relational storage, vector search, row-level security for permissions.
- **Used by:** {project-name}-services (all components via database/)
- **Env vars:** `DATABASE_URL`
- **Credentials:** Location where credentials are stored (e.g., `memory/connectors/{provider}/.env`)
- **Environments:** Production branch, staging branch
- **If it goes down:** All API calls fail.
- **Fallback:** {Backup/migration strategy}
- **Test behavior:** {How tests handle this dependency -- real DB, mock, in-memory, etc.}
- **Status page:** {URL}
- **Cost model:** {Pricing model}

### {Cloud Compute Provider} (e.g., Cloud Run, ECS, Railway)

- **Purpose:** Hosts the backend services.
- **Used by:** {project-name}-services
- **Env vars:** Injected via CI/CD secrets
- **Credentials:** Location of service account or deploy credentials
- **Domains:** `{STAGING_DOMAIN}`, `{PRODUCTION_DOMAIN}`
- **If it goes down:** Entire backend offline.
- **Fallback:** {Rollback or migration strategy}
- **Test behavior:** Local dev runs directly (no container). CI builds container but does not deploy.
- **Status page:** {URL}
- **Cost model:** {Pricing model}

---

## AI Providers

### {Primary LLM Provider} (e.g., Anthropic)

- **Purpose:** Primary LLM provider. Powers the core AI experience.
- **Used by:** {project-name}-services (llm-gateway/ or equivalent)
- **Env vars:** `{PROVIDER}_API_KEY`
- **Credentials:** Location of API key
- **If it goes down:** AI features fail. May route to fallback providers if configured.
- **Test behavior:** {Real API key or mock}
- **Status page:** {URL}
- **Cost model:** Pay-per-token

---

## Not Yet Integrated

Services with credentials available but not yet consumed:

| Service | Credential Location | Likely Future Use |
|---------|-------------------|-------------------|
| {Example} | {path} | {purpose} |

## Removed Services

Services that were previously used but are no longer needed. Documented here so they don't resurface.

| Service | Removed | Reason |
|---------|---------|--------|
| {Example} | {date} | {why removed, what replaced it} |
