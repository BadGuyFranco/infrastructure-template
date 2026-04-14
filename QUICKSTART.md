# Getting Started

From clone to first build session in under 10 minutes.

## Step 1: Clone and Run Setup

```bash
git clone https://github.com/BadGuyFranco/infrastructure-template.git my-project
cd my-project
./setup.sh
```

The setup script asks for your project name, paths, and accounts, then replaces all `{PLACEHOLDER}` values across the codebase. Verify nothing was missed:

```bash
./setup.sh --check
```

## Step 2: Install Dependencies

```bash
# Claude Code CLI (standalone installer)
curl -fsSL https://claude.ai/install.sh | sh
claude auth

# GitHub CLI
gh auth login

# tmux (required for Oscar orchestration)
brew install tmux
```

Full tool versions and verification checklist: `build/ENVIRONMENT.md`

## Step 3: Configure Claude Code

The template ships with project-level settings (`.claude/settings.json`) that configure:
- Permissions for all tools
- Env vars that disable 1M context, adaptive thinking, and auto-memory
- Hooks for audio notifications and code hygiene checks

**Global settings** -- copy this to `~/.claude/settings.json`:
```json
{
  "permissions": {
    "allow": [
      "Bash(*)", "Edit(*)", "Write(*)", "Read(*)",
      "Glob(*)", "Grep(*)", "NotebookEdit(*)",
      "WebFetch(*)", "WebSearch(*)", "Agent(*)", "mcp__*"
    ]
  },
  "effortLevel": "high",
  "skipDangerousModePermissionPrompt": true
}
```

> Do NOT add a `model` field to global settings. Model selection is handled by agent frontmatter (`.claude/agents/*.md`).

## Step 4: Fill In Your Project Context

1. **`ARCHITECTURE.md`** -- fill in what your project is, platform principles, and the component map
2. **`build/AGENTS.md`** -- add your actual dev commands (dev server, typecheck, test, lint) to the Local Development Commands section
3. **`build/PRIORITIES.md`** -- replace the example priority with your first real priority
4. **`AGENTS.md`** (root) -- fill in the Code Repository table with your workspace packages

## Step 5: First Session (Bob)

```bash
cd my-project
claude --agent bob
```

Bob reads the AGENTS.md chain automatically. He'll:
1. Run `check-session-ready.ts` to verify git state
2. Read `PRIORITIES.md` to see what to work on
3. Build. Following CODE_STANDARDS, using the done-gate checklist when finishing work.
4. At session end, execute the session-end checklist.

**Expected output on first launch:**
```
Loading Bob session context...
```
Bob will read AGENTS.md and ask about priorities or wait for direction.

## Step 6: First Orchestrated Session (Oscar + Bob)

This is the full multi-session setup where Oscar drives Bob via tmux.

**Prerequisites:**
- tmux installed (`brew install tmux`)
- iTerm2 installed (recommended)
- `~/.claude-accounts` file configured (see `build/ENVIRONMENT.md`)

```bash
# Double-click in Finder, or:
bash build/build-personas/Orchestrator-V3.command
```

The launcher will:
1. Ask you to pick a Claude Code account
2. Show your priorities from PRIORITIES.md
3. Launch Bob in a tmux session with auto-restart
4. Launch Oscar in a separate tmux session
5. Open iTerm with side-by-side panes
6. Oscar reads his playbook, then drives Bob on the selected priority

**What you see:** Two terminal panes. Oscar (left) evaluates and questions. Bob (right) builds. You watch both and intervene when needed.

## Step 7: Set Up Later (When Needed)

| Capability | When to Add | Setup |
|------------|------------|-------|
| **Talia (QA)** | When quality verification matters | Bob dispatches her as a sub-agent -- no extra setup needed |
| **Path-scoped rules** | When you have coding standards | Add `.md` files to `.claude/rules/` with glob frontmatter |
| **Additional personas** | When you need specialized roles | Use `build/build-personas/_PERSONA_TEMPLATE.md` + create `.claude/agents/{name}.md` |
| **Testing layers 2-5** | As your test suite matures | `build/quality/testing/ARCHITECTURE.md` has the design spec |
| **Ticketing API** | When you have a running API | Replace ticket-related placeholders in `build/TICKETS.md` |

## What to Adopt When

| Phase | What to Use | Why Now |
|-------|------------|---------|
| **Day 1** | AGENTS.md routing, PRIORITIES.md, bob.md, CODE_STANDARDS, done-gate, session-end | Minimum structure for consistent builds |
| **Week 2** | Plans system, SESSION_LOG, DOCUMENTATION_STANDARDS, dispatch templates | Multi-session work needs persistent tracking |
| **Month 1** | Talia (QA), QA dispatch, testing architecture, ADRs | Quality verification becomes a real concern |
| **Mature** | Oscar (orchestration), full checklist system, architecture reviews | Process oversight adds value at scale |

## Troubleshooting

**"Claude Code doesn't read AGENTS.md"** -- make sure you're launching with `--agent bob` or from within the project directory where `.claude/agents/bob.md` exists.

**"Oscar can't talk to Bob"** -- verify tmux is installed at `/opt/homebrew/bin/tmux`. Run `which tmux` to check. See `build/ENVIRONMENT.md` for non-Mac paths.

**"Hooks aren't firing"** -- check that `.claude/settings.json` exists in the project root and that `jq` is installed (needed by the code-hygiene hook).

**"setup.sh missed some placeholders"** -- run `./setup.sh --check` to find them. Some placeholders in HTML comments or code examples may need manual replacement.
