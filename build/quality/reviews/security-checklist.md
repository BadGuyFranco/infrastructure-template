# Security Checklist

A standalone security audit for {PROJECT_NAME}. Run as part of the architecture review or independently for compliance, due diligence, or pre-launch verification.

**SOC 2 alignment:** Items marked with `[SOC 2]` map directly to SOC 2 Trust Service Criteria. Following these practices now means less remediation later if you pursue certification.

**Philosophy:** Don't over-engineer -- just stay on the path. Every item here is practical for a small team building a real product. Nothing is included just to check a box.

**Risk Factor ratings:**

| Rating | Meaning | Action |
|--------|---------|--------|
| Urgent | Blocks shipping or creates immediate exposure. Fix now. | Address before next milestone |
| Soon | Not blocking but grows worse over time. Plan it. | Address within 1-2 sprints |
| Defer | Good practice but safe to defer until later phase. | Track in ToDos.md, revisit at next review |

---

## 1. Authentication & Authorization

| | Check | Risk Factor | Recommendation |
|---|-------|-------------|----------------|
| [ ] | Auth provider is configured with secure defaults -- no implicit trust, no permissive CORS | Urgent | Misconfigured auth = open door. Verify auth configuration matches architecture docs. |
| [ ] | JWT tokens are validated on every API request (not just presence-checked) | Urgent | Presence-only checks let expired or forged tokens through. Validate signature, expiry, issuer, audience. |
| [ ] | Token expiry is set to a reasonable duration (not indefinite) | Soon | Long-lived tokens widen the attack window if leaked. 15-60 min access tokens + refresh tokens is standard. |
| [ ] | Refresh token rotation is enabled | Soon | Prevents stolen refresh tokens from being usable indefinitely. |
| [ ] | Permission model is enforced server-side (not just UI-hidden) | Urgent | Client-side permission checks are trivially bypassed. Every protected endpoint must check permissions server-side. |
| [ ] | No API endpoints are accessible without authentication (unless explicitly public) | Urgent | Audit every route. Unauthenticated endpoints should be documented and intentional. |
| [ ] | Role-based access control (RBAC) boundaries are tested -- users can't access other users' data | Urgent | Horizontal privilege escalation is one of the most common security bugs. `[SOC 2]` |
| [ ] | Auth webhook signatures are verified | Soon | Unverified webhooks accept spoofed events. Verify signatures. |

## 2. Data Protection

| | Check | Risk Factor | Recommendation |
|---|-------|-------------|----------------|
| [ ] | All client-server communication uses TLS (HTTPS/WSS) -- no plain HTTP in production | Urgent | Unencrypted traffic exposes tokens, content, and PII. `[SOC 2]` |
| [ ] | Database connections use TLS | Urgent | Verify it hasn't been overridden. `[SOC 2]` |
| [ ] | User content is encrypted at rest in cloud storage | Soon | Most cloud providers encrypt by default. Verify it's enabled, not just assumed. `[SOC 2]` |
| [ ] | PII inventory exists -- we know what personal data we store and where | Soon | Can't protect what you haven't inventoried. List: email, name, billing info, usage data. `[SOC 2]` |
| [ ] | No secrets (API keys, tokens, passwords) are hardcoded in source code | Urgent | Secrets in code end up in git history forever. Use environment variables or a secrets manager. |
| [ ] | `.env` files are in `.gitignore` for every repo | Urgent | One missed .gitignore = credentials in the repo. Check all repos. |
| [ ] | Secrets are not logged -- API keys, tokens, and passwords are redacted in logs | Soon | Leaked secrets in logs are a common breach vector. `[SOC 2]` |
| [ ] | Data retention policy is documented -- what do we keep, for how long, and how is it deleted | Defer | Important for SOC 2 but not blocking pre-alpha. Define before beta. `[SOC 2]` |
| [ ] | Backup and recovery process is documented and tested | Defer | Critical for production but acceptable to defer during alpha. `[SOC 2]` |

## 3. Desktop App Hardening (if applicable)

| | Check | Risk Factor | Recommendation |
|---|-------|-------------|----------------|
| [ ] | `nodeIntegration` is `false` in all renderer processes | Urgent | nodeIntegration:true gives web content full Node.js access -- game over if any XSS exists. |
| [ ] | `contextIsolation` is `true` in all renderer processes | Urgent | Context isolation prevents renderer code from accessing framework internals. Must be on. |
| [ ] | `sandbox` is enabled for renderer processes | Soon | Sandboxing adds OS-level process isolation. Defense in depth. |
| [ ] | `webSecurity` is NOT disabled (default is enabled -- verify no one turned it off) | Urgent | Disabling web security removes same-origin policy. Never disable in production. |
| [ ] | Content Security Policy (CSP) is set and restricts inline scripts, external resources | Soon | CSP prevents XSS attacks from loading malicious scripts. Start restrictive, loosen only with justification. |
| [ ] | IPC messages are validated -- main process doesn't blindly trust renderer messages | Urgent | The renderer is untrusted territory. Validate every IPC message in the main process. |
| [ ] | Only specific IPC channels are exposed via `contextBridge` -- no blanket exposure | Urgent | Exposing all IPC lets compromised renderer code call any main process handler. |
| [ ] | Auto-update uses code signing and signature verification | Soon | Unsigned updates can be MitM'd to deliver malware. |
| [ ] | `shell.openExternal()` calls validate URLs before opening | Soon | Unvalidated URLs could open `file://` or custom protocol handlers. Allowlist `https://` only. |
| [ ] | Dev tools are disabled in production builds | Defer | Dev tools in production let users inspect internals. Low risk but unprofessional. |

## 4. API Security

| | Check | Risk Factor | Recommendation |
|---|-------|-------------|----------------|
| [ ] | Input validation on all API endpoints -- reject unexpected types, sizes, and shapes | Urgent | Unvalidated input is the root cause of injection, overflow, and logic bugs. Use Zod or similar. |
| [ ] | Rate limiting is implemented on auth endpoints (login, signup, password reset) | Urgent | No rate limiting = brute force and credential stuffing are trivial. |
| [ ] | Rate limiting is implemented on LLM-triggering endpoints | Soon | LLM calls are expensive. Unthrottled endpoints can rack up costs or enable abuse. |
| [ ] | CORS is configured to allow only known origins (not `*`) | Urgent | Wildcard CORS lets any website make authenticated requests to your API. |
| [ ] | Error responses don't leak internal details (stack traces, SQL errors, file paths) | Soon | Detailed errors help attackers understand your internals. Return generic messages; log details server-side. |
| [ ] | File upload (if any) validates file type, size, and scans for malicious content | Soon | Malicious file uploads are a classic attack vector. Validate server-side, not just client-side. |
| [ ] | WebSocket connections are authenticated -- not just the initial HTTP upgrade | Urgent | WebSocket auth must be re-verified. A token valid at connection time may expire during the session. |
| [ ] | SQL queries use parameterized statements (no string concatenation) | Urgent | SQL injection is preventable with parameterized queries. Verify ORM usage doesn't bypass this. |

## 5. Dependency Security

| | Check | Risk Factor | Recommendation |
|---|-------|-------------|----------------|
| [ ] | `npm audit` (or equivalent) runs with no critical or high vulnerabilities | Soon | Known vulnerabilities in dependencies are low-hanging fruit for attackers. |
| [ ] | Lock files (`package-lock.json` or `pnpm-lock.yaml`) are committed and used in CI | Urgent | Without lockfiles, builds pull latest versions which may include compromised packages. |
| [ ] | Dependencies are reviewed before adding -- no unnecessary packages | Soon | Every dependency is attack surface. Prefer well-maintained packages with small dependency trees. |
| [ ] | No dependencies with known supply chain compromises (check advisories) | Urgent | Supply chain attacks happen. Check advisories. |
| [ ] | Automated dependency update scanning is configured (Dependabot, Renovate, or similar) | Defer | Manual updates are fine for alpha. Automate before beta to catch vulns quickly. `[SOC 2]` |
| [ ] | Transitive dependencies are reviewed for major packages | Defer | Deep dependency trees hide risks. Spot-check critical packages. |

## 6. Infrastructure & Operations

| | Check | Risk Factor | Recommendation |
|---|-------|-------------|----------------|
| [ ] | Production environment variables are managed through a secrets manager (not `.env` files on disk) | Soon | .env files on servers are readable by anyone with access. Use platform secrets. |
| [ ] | Cloud provider accounts use MFA | Urgent | No MFA = one leaked password away from total compromise. `[SOC 2]` |
| [ ] | Repos use branch protection -- no direct pushes to main | Soon | Branch protection prevents accidental or malicious direct pushes. |
| [ ] | CI/CD pipeline doesn't expose secrets in logs | Soon | CI logs are often more accessible than production logs. Mask secrets. |
| [ ] | Application logging captures auth failures, permission denials, and error rates | Defer | Audit logging is required for SOC 2. Start with auth events, expand later. `[SOC 2]` |
| [ ] | Error reporting is configured for production | Soon | You can't fix what you can't see. Monitoring catches issues before users report them. |
| [ ] | Incident response plan exists (even if informal) -- who to contact, what to do if breached | Defer | Critical for SOC 2 but acceptable as informal notes for alpha. Formalize before launch. `[SOC 2]` |

---

## How to Use This Checklist

**During an architecture review:** Run through every item. Record findings in the review report under "Security Audit Summary." Urgent items become blockers; Soon items go to ToDos.md.

**Standalone (pre-launch, compliance, due diligence):** Run independently of the architecture review. Produce a dated report: `YYYY-MM-DD-security-audit.md` in this directory.

**For each finding:**
1. Note the current state (passing, failing, not applicable, not yet implemented)
2. If failing: capture the risk factor and write a specific remediation recommendation
3. If not yet implemented: is it needed now, or can it wait? Use the risk factor as a guide.

**What this checklist is NOT:**
- A penetration test (hire a specialist for that before launch)
- A compliance certification (SOC 2 requires an auditor)
- Exhaustive (it covers the high-value items for your stack -- not every possible security control)
