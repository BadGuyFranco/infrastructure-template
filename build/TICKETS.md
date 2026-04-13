<!--
LLM INSTRUCTIONS:

PURPOSE:
- This is the ticketing convention for {PROJECT_NAME}.
- Defines WHEN to file, ticket types, severity guidelines, visibility model, and context format.

NOTE: Replace all placeholder values ({API_STAGING_URL}, {ORG_NAME}, {ORG_SLUG}, {ORG_UUID},
{SYSTEM_USER_UUID}) after setting up your ticketing API.
-->

# Ticketing Convention

## When to File a Ticket

- **Every bug discovered during a session** -- even if you fix it immediately. The fix gets logged on the ticket.
- **Every deferred fix** -- if you find a bug but it's out of scope for the current task, file a ticket so it isn't forgotten.
- **Feature requests** -- use `--type feature` for enhancements and new capabilities.
- **Support requests** -- use `--type support` for issues reported by users or external stakeholders.
- **Tracking tasks** -- use `--type task` for work items that aren't bugs or features.

## Ticket Types

| Type | When to use |
|------|-------------|
| `bug` | Something is broken or behaving incorrectly |
| `feature` | A new capability or enhancement request |
| `support` | An issue reported by a user or external stakeholder |
| `task` | A work item, tracking item, or follow-up that isn't a bug or feature |

## Severity Guidelines

| Severity | Meaning | Examples |
|----------|---------|---------|
| `critical` | System unusable or data loss risk | Auth bypass, data corruption, crash on launch |
| `high` | Major feature broken, no workaround | Core feature fails silently, data sync broken |
| `medium` | Feature degraded or type errors | Typecheck failures, field name mismatches, stale UI state |
| `low` | Cosmetic or minor inconvenience | Icon mismatch, unused import warnings |

## Visibility Model

Tickets have a visibility field that controls who can see them (enforced by database RLS):

| Visibility | Who can see | When to use |
|-----------|-------------|-------------|
| `private` | Only the filing user | Personal notes, draft investigations |
| `team` | Members of the ticket's team | Team-scoped work (requires `--team-id`) |
| `internal` | All members of the ticket's organization | **Default.** Most bugs and tasks |
| `customer` | Org members + the filing user | Customer-reported bugs visible to the reporter |

Default is `internal` -- visible to all {ORG_NAME} org members. Use this for all standard build work.

## Status Values

| Status | Meaning |
|--------|---------|
| `open` | New or reopened, not yet being worked |
| `in_progress` | Actively being worked on |
| `waiting` | Blocked on external input, dependency, or information |
| `resolved` | Fix applied and verified |
| `closed` | No action needed (not a bug, duplicate, or won't fix with explanation) |
| `wont_fix` | Acknowledged but intentionally not fixing |

## Tags

Use `--tags` to add comma-separated labels for cross-cutting concerns:

```bash
--tags "regression,security"
--tags "pre-existing,performance"
```

Tags are free-form strings. Conventions: `regression`, `security`, `pre-existing`, `performance`, `not-a-bug`.

## Component List

<!-- Replace with your project's actual components. Any string is accepted -- use the most specific component name. -->
`api`, `auth`, `billing`, `database`, `frontend`, `backend`, `shared`, `build`

## The Context Field

When filing a ticket, always include structured context so the fixer knows WHERE to look:

- **packages** -- which monorepo packages are involved (for rebuild/test scoping)
- **files** -- specific files to read before working on the fix (relative to project root)
- **dependencies** -- external packages involved
- **related_tickets** -- ticket IDs that are related

## Default Organization

All build personas operate within the **{ORG_NAME}** organization (slug: `{ORG_SLUG}`, UUID: `{ORG_UUID}`). This is the default org for all ticket operations -- no `--org` flag needed.

## Filing Tickets

Tickets are stored in the staging database via the services API. All personas file tickets by calling the staging API directly with curl.

**Auth header (required on every request):**
```
-H "X-User-Id: {SYSTEM_USER_UUID}"
```
This is the well-known system user. All build persona ticket operations use this user.

### Create a ticket

```bash
curl -s -X POST {API_STAGING_URL}/api/v1/tickets \
  -H "Content-Type: application/json" \
  -H "X-User-Id: {SYSTEM_USER_UUID}" \
  -d '{
    "title": "Short summary of the issue",
    "description": "Full context. Include root cause if known, affected code paths, reproduction steps.",
    "component": "backend",
    "type": "bug",
    "severity": "high",
    "reporterType": "developer",
    "tags": ["pre-existing"],
    "context": {
      "packages": ["{project-name}-services"],
      "files": ["services/server/src/example-path.ts"],
      "related_priorities": ["EXAMPLE-SLUG"]
    }
  }'
```

Required fields: `title`, `description`, `component`, `reporterType`. Optional: `type`, `severity`, `visibility`, `orgId`, `teamId`, `assignedTo`, `tags`, `environment`, `context`, `metadata`.

### List tickets (with filters)

```bash
curl -s "{API_STAGING_URL}/api/v1/tickets?status=open" \
  -H "X-User-Id: {SYSTEM_USER_UUID}"
```

Filter params: `status`, `severity`, `component`, `type`, `visibility`, `teamId`, `assignedTo`, `tags`, `limit`, `offset`.

### Search tickets by text

```bash
curl -s "{API_STAGING_URL}/api/v1/tickets/search?q=streaming&component=backend" \
  -H "X-User-Id: {SYSTEM_USER_UUID}"
```

Search params: `q` (text search), `component`, `status`, `severity`, `type`, `visibility`, `teamId`, `limit`, `offset`.

### Get a single ticket (with comments)

```bash
curl -s "{API_STAGING_URL}/api/v1/tickets/TICKET_UUID" \
  -H "X-User-Id: {SYSTEM_USER_UUID}"
```

### Update a ticket

```bash
curl -s -X PATCH "{API_STAGING_URL}/api/v1/tickets/TICKET_UUID" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: {SYSTEM_USER_UUID}" \
  -d '{"status": "resolved", "severity": "low"}'
```

Updatable fields: `status`, `severity`, `type`, `visibility`, `component`, `title`, `description`, `teamId`, `assignedTo`, `tags`, `environment`, `context`, `metadata`.

### Add a comment

```bash
curl -s -X POST "{API_STAGING_URL}/api/v1/tickets/TICKET_UUID/comments" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: {SYSTEM_USER_UUID}" \
  -d '{"body": "Comment text here.", "commenterType": "agent"}'
```

## Valid Enum Values

- **type:** `bug`, `feature`, `support`, `task`
- **visibility:** `private`, `team`, `internal`, `customer`
- **status:** `open`, `in_progress`, `waiting`, `resolved`, `closed`, `wont_fix`
- **severity:** `critical`, `high`, `medium`, `low`
- **reporterType / commenterType:** `developer`, `agent`, `user`
