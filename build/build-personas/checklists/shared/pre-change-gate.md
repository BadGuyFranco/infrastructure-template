# Pre-Change Gate

**Shared checklist.** Run before any change to an external system (infrastructure, vendor accounts, DNS, CRM, cloud services, etc.). Referenced by Bob (infra-changes) and any persona making external changes.

## Steps

1. **Document current state.** Before changing anything, capture what exists now. DNS records, env vars, IAM bindings, database schema, service configuration, CRM entities -- whatever is about to be touched. If something breaks, you need to know what to revert to.

2. **Scope the change precisely.** State exactly what is changing and what is NOT being touched. Infrastructure and ops changes often have adjacent configuration that looks related but is not. Name the boundary.

3. **Blast radius.** What breaks if this change is wrong? A misconfigured DNS record takes down email. A bad IAM binding breaks deploys. A duplicate CRM entity confuses the pipeline. Name the blast radius before making the change.

4. **Reversibility.** Can this be undone? Reversible: DNS records, Cloud Run revisions, config changes. Not reversible: sent emails, deleted database branches, revoked IAM bindings that break running services, created invoices. If irreversible, get extra verification before proceeding.

5. **Founder approval for production.** Any change to production infrastructure or production-facing external systems requires explicit founder confirmation. Staging and local are autonomous.

## Gate

Current state documented. Scope and blast radius named. Reversibility assessed. Founder approved (if production). Ready to execute.
