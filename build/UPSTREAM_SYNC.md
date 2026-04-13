# Upstream Sync Procedure

## Purpose

This Infrastructure Template was originally derived from the CoBuilder project's build infrastructure. Over time, that source project continues to evolve -- personas get refined, checklists improve, scripts gain new capabilities, and standards mature. This document defines the procedure for auditing those upstream changes and pulling generic improvements back into the template.

This is the **only file in the entire template** where "CoBuilder" is referenced by name. Every other file uses abstract placeholders and contains no project-specific references.

---

## Sync Cadence

Trigger an upstream sync:

- **After any major persona or checklist improvement** in the CoBuilder project (new persona added, checklist restructured, orchestrator logic changed).
- **Monthly**, as a routine audit even if no specific change is known.

---

## Audit Scope

The following areas should be compared during each sync:

| Area | What to look for |
|------|-----------------|
| Persona playbooks | New personas, restructured responsibilities, improved prompt patterns |
| Checklists | New checklist items, reordered steps, removed obsolete checks |
| Scripts | New utility scripts, improved validation logic, better error handling |
| Standards | Updated coding standards, new conventions, revised policies |
| Orchestrator templates | Changed routing logic, new workflow patterns, improved session management |
| Plans methodology | Revised plan structures, new phase patterns, improved status tracking |

---

## Abstraction Rules

When pulling improvements from upstream, apply the same abstraction rules used during the initial template creation:

1. **No CoBuilder references** in any file except this one (`UPSTREAM_SYNC.md`).
2. **No project-specific personas** -- CoBuilder uses "Phil" (primitive builder), "Ian" (backoffice orchestrator), and "Quinn" (IDE QA automation); these must be replaced with generic role-based names or left as configurable slots.
3. **IDE-agnostic** -- No Cursor-specific, VS Code-specific, or any other editor-specific references. Use generic terms like "IDE" or "editor."
4. **Use standard placeholders** for all project-specific values:
   - `{PROJECT_NAME}` -- Display name of the project (e.g., "My App")
   - `{project-name}` -- Slug/kebab-case name (e.g., "my-app")
   - `{PROJECT_ROOT}` -- Absolute path to the project root
   - `{MONOREPO_ROOT}` -- Absolute path to the monorepo root (if applicable)
   - `{STAGING_DOMAIN}` -- Staging environment domain
   - `{PRODUCTION_DOMAIN}` -- Production environment domain
   - `{API_STAGING_URL}` -- Staging API base URL
   - `{NEON_CONNECTION_STRING}` -- Database connection string
   - `{GCP_PROJECT_ID}` -- Google Cloud project identifier
   - `{GCP_REGION}` -- Google Cloud region
5. **No hardcoded paths** -- All paths must be relative or use placeholders.

---

## Diff Workflow

Follow these steps for each file in scope:

### Step 1: Read the CoBuilder source file

Open the upstream source file from the CoBuilder project (see Source Locations below).

### Step 2: Read the corresponding template file

Open the matching file in this Infrastructure Template.

### Step 3: Identify generic improvements

Compare the two versions. Look for changes that are **generic** -- improvements to process, structure, wording, or logic that are not specific to CoBuilder's domain. Ignore changes that are:

- CoBuilder feature-specific
- References to CoBuilder's specific tech stack choices (unless the template already covers that stack area generically)
- Persona names "Phil" or "Ian" used in CoBuilder-specific context

### Step 4: Apply improvements with abstraction

Port the identified improvements into the template file, applying all abstraction rules above. Replace any project-specific names, paths, domains, or identifiers with the appropriate placeholders.

### Step 5: Verify no references leaked

After applying changes, confirm:

- [ ] No occurrence of "CoBuilder" in any modified file (except this one)
- [ ] No occurrence of "Phil", "Ian", or "Quinn" as persona names
- [ ] No hardcoded paths, domains, or project IDs
- [ ] All placeholders use the standard set defined above
- [ ] File remains IDE-agnostic

---

## Source Locations

CoBuilder upstream files are found at these paths (relative to the workspace root):

| Template Area | CoBuilder Source Path |
|--------------|---------------------|
| Persona playbooks | `CoBuilder/infrastructure/cobuilder-build/build-personas/` |
| Checklists | `CoBuilder/infrastructure/cobuilder-build/build-personas/checklists/` |
| Scripts | `CoBuilder/infrastructure/cobuilder-build/build-personas/scripts/` |
| Standards | `CoBuilder/infrastructure/cobuilder-build/standards/` |
| Orchestrator | `CoBuilder/infrastructure/cobuilder-build/orchestrator/` |
| Plans | `CoBuilder/infrastructure/cobuilder-build/plans/` |

---

## Note

This is a **manual process**. The founder triggers it by opening a session and requesting an upstream sync. An AI session then executes the diff workflow above, file by file. There is no automated sync mechanism -- the human decides when to sync and reviews the results.
