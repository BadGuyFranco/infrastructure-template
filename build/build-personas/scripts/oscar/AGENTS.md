# Oscar Scripts

Helper scripts for Oscar's tmux-based interaction with Bob.

## Scripts

| Script | Purpose |
|--------|---------|
| `launch-bob.sh` | Creates Bob (Claude Code) in a named tmux session, waits for TUI readiness, opens a Terminal window for the founder. Usage: `launch-bob.sh [session-name]`. Returns Bob's session ID on stdout. |
| `send-to-bob.sh` | **Primary interface.** Sends a message to Bob and blocks until he responds. Usage: `send-to-bob.sh SESSION_NAME "message"`. Outputs captured pane on stdout. Must run in foreground. |
| `wait-for-bob.sh` | Polls a named tmux session until Bob's response is complete (status bar present, "esc to interrupt" absent for 3 consecutive seconds). Usage: `wait-for-bob.sh [session-name] [max_seconds] [capture_lines]`. Called by send-to-bob.sh. |

## Usage

These scripts are called by `Orchestrator.command` and by Oscar (Claude Code) during a session. They are not meant to be run manually, but can be for debugging.

Note: `send-to-bob.sh` appends an evaluation prompt after every Bob response. This is a behavioral re-anchoring mechanism -- research shows persona consistency degrades 30%+ after 8-12 turns. The prompt reminds Oscar to evaluate (not relay) and to run conversation flow steps.

## Constraints

- Must use Homebrew tmux. The scripts auto-detect the tmux binary (Homebrew Apple Silicon at `/opt/homebrew/bin/tmux`, Homebrew Intel at `/usr/local/bin/tmux`, or system paths). Override with `$TMUX_BIN` environment variable.
- Must not send control sequences (Ctrl+O, etc.) to Bob's tmux session. They corrupt Claude Code's TUI.
- Must not set `$TMUX` as a variable name. It is reserved by tmux.
- tmux.conf must not use `set -g mouse on`. It breaks `send-keys` delivery to Claude Code.
