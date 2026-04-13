# {PROJECT_NAME} -- Local Development Environment

**Purpose:** Everything needed to go from a fresh machine to a working dev session.
Read this when setting up a new machine or when a tool/CLI is not working as expected.
This is NOT part of session startup -- Bob reaches for it on demand.

**Last verified:** {DATE}

## 1. Prerequisites

These must be installed before anything else works.

| Tool | Version (verified) | Min required | Install Method | Notes |
|------|--------------------|--------------|----------------|-------|
| Node.js | v22.x | >=20.0.0 | nvm or Miniforge | LTS recommended |
| pnpm | 10.x | >=10.0.0 | `npm install -g pnpm` | Monorepo package manager |
| Git | 2.40+ | -- | Platform default | |
| Python 3 | 3.11+ | -- | Platform default | Used by some build scripts |

**Package manager policy:** Choose one system package manager and stick with it. Document the choice here.

<!-- Example (Miniforge-based):
Install Miniforge:
```bash
curl -L -o Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh
bash Miniforge3.sh -b
~/miniforge3/bin/conda init zsh
# Restart shell, then:
conda install nodejs
```
-->

## 2. CLIs and Tools

| Tool | Version (verified) | Install | Auth/Config |
|------|--------------------|---------|-------------|
| Claude Code CLI | latest | Standalone installer (see below) | API key via `claude auth` |
| GitHub CLI (`gh`) | latest | Platform package manager | `gh auth login` (SSH protocol, keyring storage) |
| Google Cloud CLI | latest | `curl https://sdk.cloud.google.com \| bash` | `gcloud auth login` |
| tmux | 3.x | `brew install tmux` | None (see Oscar/tmux section) |
| iTerm2 | latest | Download from iterm2.com | None (see Oscar/tmux section) |

<!-- Add project-specific CLIs here (e.g., Docker, Terraform, AWS CLI, Vercel CLI, Codex CLI). -->

**Claude Code CLI install** (standalone installer, not npm):
```bash
curl -fsSL https://claude.ai/install.sh | sh
# Restart shell, then:
claude auth
```
This installs to `~/.local/bin/claude`. Ensure `~/.local/bin` is in your PATH -- the workspace launcher and Oscar scripts depend on this.

**Claude Code multi-account setup** -- both the workspace launcher and the Orchestrator (`Orchestrator-V3.command`) support multiple Claude Code accounts. Each account is an isolated config directory with its own auth token and settings.

Create `~/.claude-accounts`:
```
# account=config-dir
claude-slow=~/.claude
claude-fast=~/.claude-claude-fast
{your-name}-slow=~/.claude-{your-name}-slow
{your-name}-fast=~/.claude-fast
```

Each line maps a display name to a `CLAUDE_CONFIG_DIR` path. The default account uses `~/.claude`; additional accounts use separate directories. The "slow" / "fast" naming reflects rate-limit tiers -- name them however you like.

To authenticate each account on a new machine:
```bash
# Default account (uses ~/.claude automatically)
claude auth

# Additional accounts -- set CLAUDE_CONFIG_DIR first
CLAUDE_CONFIG_DIR=~/.claude-claude-fast claude auth
CLAUDE_CONFIG_DIR=~/.claude-{your-name}-slow claude auth
CLAUDE_CONFIG_DIR=~/.claude-fast claude auth
```

Each `claude auth` command opens a browser for login. The token is stored in that account's config directory. After authenticating all accounts, copy your global settings into each:
```bash
for dir in ~/.claude-claude-fast ~/.claude-{your-name}-slow ~/.claude-fast; do
  mkdir -p "$dir"
  cp ~/.claude/settings.json "$dir/settings.json"
done
```

> **Note:** The global `settings.json` should NOT contain a `model` field. Model selection is controlled by agent frontmatter (`.claude/agents/*.md`) at the project level. Setting `model` in global settings creates conflicts with project-level env vars.

**tmux and iTerm2 (Oscar sessions):**

tmux is required for Oscar's orchestration layer. Oscar's scripts hardcode `/opt/homebrew/bin/tmux` on macOS.

iTerm2 is recommended but not required. The V3 launcher uses plain tmux -- sessions survive iTerm disconnection. If iTerm2 is not installed, launchers fall back to Terminal.app.

**Docker:** Document whether Docker is needed for local development. If builds run in CI only, note that Docker is NOT needed locally.

## 3. Claude Code Settings

Reproduce the global settings on a new machine. Local settings accumulate machine-specific permissions over time -- the baseline shown below is a starting point.

**Global settings** (`~/.claude/settings.json`):
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

> **No `model` field.** Model selection is handled by agent frontmatter (`.claude/agents/*.md`), not global settings. Setting `model` here creates conflicts with project-level env vars.

**Project-level env vars** -- the project `.claude/settings.json` sets these in the `env` block, enforcing constraints for every session in this repo regardless of which account is used:

| Env var | Value | Why |
|---------|-------|-----|
| `CLAUDE_CODE_DISABLE_1M_CONTEXT` | `1` | Standard 200k context, not 1M. Keeps prompt cache efficient and cost predictable. |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | `1` | Fixed thinking budget. Prevents variable-length thinking from blowing context on long sessions. |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | `1` | Project manages its own memory via playbooks, AGENTS.md, SESSION_LOG, and PRIORITIES -- not Claude Code's auto-memory. |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `sonnet` | Sub-agents use Sonnet. Main personas (Bob, Oscar) use Opus via agent frontmatter. |

**Local settings** (`~/.claude/settings.local.json`):
```json
{
  "permissions": {
    "allow": [
      "Bash(bash:*)"
    ]
  }
}
```

**MCP servers:** Document where your `.mcp.json` lives and what MCP servers are configured.

**Environment variable** -- `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` tells Claude Code to load `CLAUDE.md` files from all `--add-dir` directories, not just the primary working directory. This is required for the multi-root workspace to function correctly. It is set in two places (belt-and-suspenders): the project-level `.claude/settings.json` `env` block (travels with git, works for any session opened in this repo) and the workspace launcher / Oscar scripts (works even if project settings are not loaded yet).

**Version-controlled project config** -- the following `.claude/` paths should be tracked in git (negation patterns in `.gitignore`):
- `.claude/agents/` -- custom agent definitions (bob, oscar, and any additional personas) with tool restrictions, preloaded skills, and agent-scoped hooks
- `.claude/skills/` -- persona-specific checklist skills with dynamic context injection
- `.claude/rules/` -- path-scoped coding standards that auto-load when matching files are read
- `.claude/settings.json` -- project-wide permissions and hooks

Everything else in `.claude/` (worktrees, memory, cache) stays gitignored.

### Project settings.json -- fields and hooks

The project-level `.claude/settings.json` is version-controlled and applies to all sessions opened in this repo. Current configuration:

**Fields:**

| Field | Value | Why |
|-------|-------|-----|
| `permissions.allow` | `Bash(*)`, `Read(*)`, `Write(*)`, `Edit(*)`, `Glob(*)`, `Grep(*)`, `Agent(*)`, `WebFetch(*)`, `WebSearch(*)` | All tools pre-approved. Sessions run with `--dangerously-skip-permissions` so this is belt-and-suspenders. |
| `env.CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | `"1"` | Load CLAUDE.md from all `--add-dir` directories. Required for multi-root workspace. Also set in launcher scripts. |
| `env.CLAUDE_CODE_DISABLE_1M_CONTEXT` | `"1"` | Standard 200k context, not 1M. Keeps prompt cache efficient and cost predictable. |
| `env.CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | `"1"` | Fixed thinking budget. Prevents variable-length thinking from blowing context. |
| `env.CLAUDE_CODE_DISABLE_AUTO_MEMORY` | `"1"` | Project manages its own memory -- not Claude Code's auto-memory. |
| `env.CLAUDE_CODE_SUBAGENT_MODEL` | `"sonnet"` | Sub-agents use Sonnet. Main personas use Opus via agent frontmatter. |

**Hook events in use:**

| Event | Matcher | What it does |
|-------|---------|-------------|
| `SessionStart` | `startup` | Injects skill availability list (echo) + plays Glass.aiff chime. |
| `SessionStart` | `resume` | Plays Bottle.aiff (distinct from startup -- "resuming, not starting"). |
| `SubagentStop` | `""` (all) | Plays Submarine.aiff when any sub-agent completes. Ambient awareness so the founder doesn't have to watch for sub-agent completion. |
| `PostToolUse` | `Edit\|Write` | Runs `.claude/hooks/code-hygiene-check.sh` async after every Edit/Write on TypeScript files. Checks file length (>300 lines) and `any` type usage. Exit 0 = silent. Exit 2 = stderr fed to model as feedback. |

**Hook scripts (`.claude/hooks/`):**

| Script | Hook event | What it checks |
|--------|-----------|---------------|
| `code-hygiene-check.sh` | PostToolUse (Edit\|Write) | TypeScript files only (skips tests, configs, .d.ts). Check 1: file >300 lines (hard limit). Check 2: `any` type usage with line numbers. Requires `jq` to parse hook stdin. |

**Hook events deliberately not used:**

| Event | Why skipped |
|-------|-------------|
| `Stop` | Fires on every model response, not just session close. Injecting a session-end reminder on every turn creates noise the model learns to ignore. |
| `FileChanged` | No `additionalContext` support, no glob matchers, no `prompt` handlers. Side-effect-only event -- cannot inject verification prompts into the model's context. |
| `PostToolUse` (Bash/git commit) | Matcher scopes to tool name only (`Bash`), not command content. Would fire a filter script on every Bash call -- hundreds per session -- with unverified stdin schema. Overhead not justified for git commit detection. |
| `UserPromptSubmit` | Adds latency to every user input. High risk, negative value. |

**Audio notifications (macOS only):**

Sound hooks use `afplay` with `2>/dev/null &` -- silent failure on non-macOS, non-blocking. No setup required beyond macOS itself; all sounds are system-bundled at `/System/Library/Sounds/`. If sounds are not playing, verify `afplay` is available: `which afplay` (should be `/usr/bin/afplay`).

## 4. File Sync and Storage

<!-- Document your source file storage and sync strategy here.
Example: Source files live on a NAS and sync to dev machines via Syncthing.

**What to verify on a new machine:**
- Sync tool is running
- Local path resolves correctly
- Required directories exist and are populated
- `node_modules` is excluded from sync -- run `pnpm install` on each new machine
-->

## 5. Workspace Launcher

<!-- Document how sessions are started. Example:
Sessions are started via the launcher script, not by running `claude` directly:

```bash
cd ~/path/to/claude/config/
./launch.sh              # Interactive workspace picker
./launch.sh "{PROJECT_NAME}"  # Direct selection
```
-->

## 6. GitHub Configuration

| Setting | Value |
|---------|-------|
| Account | {GITHUB_ACCOUNT} |
| Auth method | Keyring |
| Git protocol | SSH |

Ensure SSH keys are set up: `gh auth login` handles this if you select SSH protocol.

## 7. Cloud Provider Configuration

<!-- Replace with your cloud provider (GCP, AWS, Azure). -->

| Setting | Value |
|---------|-------|
| Provider | GCP |
| Project | {GCP_PROJECT_ID} |
| Region | {GCP_REGION} |
| Auth | `gcloud auth login` |

For deploy-related operations:
```bash
gcloud auth configure-docker {GCP_REGION}-docker.pkg.dev
```

## 8. Claude Code Memories

Claude Code's memory system (`~/.claude/projects/`) is **machine-local and per-project-directory**. It does not sync across machines. On a new machine, memories must be created manually.

**Policy:** Claude Code memory should be used rarely if ever. The repository has its own systems for rules (playbooks, AGENTS.md), state (plans, SESSION_LOG, PRIORITIES), and lessons (self-improvement sections in playbooks). Memory is only for meta-rules about Claude Code itself that cannot live in the repo.

**Canonical memories:**

### 1. No built-in plan mode

```
File: ~/.claude/projects/<DIR>/memory/feedback_no_plan_mode.md
```
```markdown
---
name: No built-in plan mode
description: Never use Claude Code's /plan or plan mode -- use the project's plan system instead
type: feedback
---

Never use Claude Code's built-in planning tool (/plan, plan mode, ~/.claude/plans/). It is insufficient for our process. The repository has its own planning system -- look for it before doing anything else.

**Why:** Claude Code's plan mode produces shallow, unversioned plans that bypass the project's Research -> Plan -> Execute -> Final Check lifecycle. Plans must live in the repo where they are versioned, reviewed, and tracked.

**How to apply:** When planning work, check the project's own system first: `build/plans/` or the project's AGENTS.md routing table.
```

### 2. Memory does not span environments

```
File: ~/.claude/projects/<DIR>/memory/feedback_no_cross_machine_memory.md
```
```markdown
---
name: Memory does not span environments
description: Claude Code memory is machine-local -- use the repository for all durable knowledge
type: feedback
---

Your memory does not span development environments and should be used rarely if ever. Your repository likely has its own way of remembering rules -- use that first.

**Why:** We develop on multiple machines. Claude Code memory is machine-local and per-directory. Anything stored here is invisible on other machines and may contradict what's in the repo.

**How to apply:** If something is worth remembering, it belongs in the repository: playbooks (bob.md, oscar.md), AGENTS.md files, self-improvement sections, plans, SESSION_LOG, or PRIORITIES. The only memories that should exist are the ones listed in ENVIRONMENT.md section 8.
```

**MEMORY.md index** (same in each project directory):
```markdown
# Memory Index

## Feedback
- [feedback_no_plan_mode.md](feedback_no_plan_mode.md) -- Never use Claude Code's built-in plan mode; use the project's plan system
- [feedback_no_cross_machine_memory.md](feedback_no_cross_machine_memory.md) -- Memory is machine-local; use the repository for durable knowledge
```

**Cleanup:** Any memories not listed above are either stale or redundant with repo content. On an existing machine, remove extra memory files after confirming their content lives in the repo.

## 9. Oscar Platform Requirements

Oscar's orchestration layer communicates with Bob via tmux session multiplexing. This requires platform-specific tooling.

| Requirement | Why | Minimum Version |
|-------------|-----|-----------------|
| macOS | Homebrew tmux path, iTerm2 integration | macOS 13+ |
| Homebrew | Package manager for tmux | Latest |
| tmux | Session multiplexing for Oscar-Bob communication | 3.3+ |
| iTerm2 | Native tmux integration with scrollback | 3.4+ |

**Install:**
```bash
brew install tmux
# Download iTerm2 from iterm2.com
```

**Known issues:**
- Conda-installed tmux crashes on attach. Use Homebrew tmux only.
- Without iTerm2, Terminal.app works but lacks native scrolling in tmux panes.

### Running Oscar on Windows or Linux

Oscar's communication mechanism (tmux + shell scripts) is Unix-native. The core mechanism works on any Unix-like OS -- only the paths and terminal emulator are Mac-specific.

**Windows (WSL2):** Install tmux via apt (`sudo apt install tmux`). Update all tmux paths in `scripts/oscar/` from `/opt/homebrew/bin/tmux` to the WSL tmux path (typically `/usr/bin/tmux`). iTerm2 is not available -- use Windows Terminal with WSL, which supports tmux natively.

**Linux:** Install tmux via your package manager. Update tmux paths in `scripts/oscar/` from `/opt/homebrew/bin/tmux` to your system path (`/usr/bin/tmux`). Any terminal emulator with tmux support works (kitty, alacritty, gnome-terminal).

**Files requiring path updates for non-Mac platforms:**
- `build/build-personas/scripts/oscar/launch-bob.sh`
- `build/build-personas/scripts/oscar/send-to-bob.sh`
- `build/build-personas/scripts/oscar/wait-for-bob.sh`
- `build/build-personas/oscar.md` (Communication with Bob section -- `/opt/homebrew/bin/tmux` references)

## Verification Checklist

Run these after setting up a new machine to confirm everything works:

```bash
# Tools exist and are correct versions
node --version          # v22.x (minimum: 20.x)
pnpm --version          # 10.x
git --version           # 2.40+
gh --version            # latest
claude --version        # latest
which claude            # ~/.local/bin/claude (standalone installer)
tmux -V                 # tmux 3.x
which tmux              # /opt/homebrew/bin/tmux (hardcoded in Oscar scripts)

# Auth is working
gh auth status          # Logged in
# gcloud auth list      # (if using GCP)

# Monorepo is ready
cd {MONOREPO_ROOT}
pnpm install            # Run on each new machine

# Dev server starts
# {YOUR DEV SERVER START COMMAND}
```
