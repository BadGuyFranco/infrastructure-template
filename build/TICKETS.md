# Ticketing Convention

## When to File a Ticket

- **Every bug discovered during a session** -- even if you fix it immediately. The fix gets logged on the ticket.
- **Every deferred fix** -- if you find a bug but it's out of scope for the current task, file a ticket so it isn't forgotten.
- **Feature requests** -- new capabilities or enhancements.
- **Tracking tasks** -- work items that aren't bugs or features.

## Ticket Types

| Type | When to use |
|------|-------------|
| `bug` | Something is broken or behaving incorrectly |
| `feature` | A new capability or enhancement request |
| `task` | A work item, tracking item, or follow-up that isn't a bug or feature |

## Severity Guidelines

| Severity | Meaning | Examples |
|----------|---------|---------|
| `critical` | System unusable or data loss risk | Auth bypass, data corruption, crash on launch |
| `high` | Major feature broken, no workaround | Core feature fails silently, data sync broken |
| `medium` | Feature degraded or type errors | Typecheck failures, field name mismatches, stale UI state |
| `low` | Cosmetic or minor inconvenience | Icon mismatch, unused import warnings |

## Status Values

| Status | Meaning |
|--------|---------|
| `open` | New or reopened, not yet being worked |
| `in_progress` | Actively being worked on |
| `resolved` | Fix applied and verified |
| `closed` | No action needed (not a bug, duplicate, or won't fix) |

## Labels

Use labels for cross-cutting concerns: `regression`, `security`, `pre-existing`, `performance`, `blocked`.

## Component List

<!-- Replace with your project's actual components. -->
`api`, `auth`, `database`, `frontend`, `backend`, `shared`, `build`

## Filing Tickets with GitHub Issues (Default)

The default ticketing system uses GitHub Issues via the `gh` CLI. All personas file tickets using these commands.

### Create a ticket

```bash
gh issue create \
  --title "Short summary of the issue" \
  --body "Full context. Include root cause if known, affected code paths, reproduction steps.

**Component:** backend
**Severity:** high
**Type:** bug

**Context:**
- Packages: {project-name}-services
- Files: services/server/src/example-path.ts
- Related priorities: [EXAMPLE-SLUG]" \
  --label "bug,high"
```

### List open tickets

```bash
gh issue list --state open
gh issue list --state open --label "bug"
gh issue list --state open --label "critical"
```

### Search tickets

```bash
gh issue list --search "streaming component:backend"
```

### View a ticket

```bash
gh issue view 42
```

### Update a ticket

```bash
gh issue edit 42 --add-label "resolved"
gh issue close 42
gh issue comment 42 --body "Fixed in commit abc123. Verified on staging."
```

### Check for duplicates before filing

```bash
gh issue list --search "keyword from the bug description"
```

Always check for existing issues before creating a new one to avoid duplicates.

<!-- ADVANCED: Custom Ticketing API

If your project has a custom ticketing API (REST, Linear, Jira), replace the
gh commands above with your API's equivalents. Structure:

1. Auth header (how to authenticate)
2. Create (POST with title, description, component, type, severity)
3. List (GET with filter params: status, severity, component, type)
4. Search (GET with text query)
5. Update (PATCH with status, severity changes)
6. Comment (POST with comment body)

Keep the same "When to File" rules and severity guidelines regardless
of which backend you use.
-->
