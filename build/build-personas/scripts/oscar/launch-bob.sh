#!/bin/bash
# ============================================================
# Launch Bob (Claude Code) in a tmux session
# Called by Orchestrator.command -- not meant to be run directly
# Usage: launch-bob.sh [session-name]
#   session-name: tmux session name (default: bob)
#
# Each session gets its own tmux socket (-L) so that iTerm's
# tmux -CC mode doesn't take over other sessions.
# ============================================================

set -euo pipefail

# --- Path resolution ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# PROJECT_ROOT is the monorepo root (4 levels up from scripts/oscar/)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

# --- tmux binary auto-detection ---
# Override with TMUX_BIN env var, or auto-detect Homebrew paths
if [ -n "${TMUX_BIN:-}" ] && [ -x "$TMUX_BIN" ]; then
  : # use provided TMUX_BIN
elif [ -x /opt/homebrew/bin/tmux ]; then
  TMUX_BIN="/opt/homebrew/bin/tmux"
elif [ -x /usr/local/bin/tmux ]; then
  TMUX_BIN="/usr/local/bin/tmux"
elif command -v tmux &>/dev/null; then
  TMUX_BIN="$(command -v tmux)"
else
  echo "  ERROR: tmux not found. Install with: brew install tmux" >&2
  exit 1
fi

SESSION_NAME="${1:-bob}"
SOCKET_NAME="$SESSION_NAME"

# Kill any stale session on this socket
$TMUX_BIN -L "$SOCKET_NAME" kill-session -t "$SESSION_NAME" 2>/dev/null || true

# Generate Bob's Claude Code session ID
BOB_SESSION_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')

# Create tmux session running Claude Code with full workspace
# Customize --add-dir flags to include your project's workspace directories
$TMUX_BIN -L "$SOCKET_NAME" new-session -d -s "$SESSION_NAME" -x 200 -y 50 \
  "cd '$PROJECT_ROOT' && claude --session-id '$BOB_SESSION_ID' --dangerously-skip-permissions --effort high; echo 'Bob exited. Press any key.'; read"

# Wait for Claude Code TUI to render the input prompt
echo "  Waiting for Bob's TUI to initialize..." >&2
READY=false
for i in $(seq 1 20); do
  sleep 1
  if $TMUX_BIN -L "$SOCKET_NAME" capture-pane -t "$SESSION_NAME" -p 2>/dev/null | grep -q '❯'; then
    READY=true
    break
  fi
done

if [ "$READY" = false ]; then
  echo "  ERROR: Bob's TUI did not show input prompt within 20 seconds" >&2
  exit 1
fi

# Open a viewer window attached to Bob's session
# iTerm + tmux -CC gives native scrolling. Falls back to Terminal.app.
# Each session uses its own socket (-L) so -CC doesn't hijack other sessions.
if [ -d "/Applications/iTerm.app" ]; then
  osascript -e '
    tell application "iTerm"
      set newWindow to (create window with default profile command "'"$TMUX_BIN"' -CC -L '"$SOCKET_NAME"' attach -t '"$SESSION_NAME"'")
    end tell'
else
  osascript -e "tell application \"Terminal\" to do script \"$TMUX_BIN -L '$SOCKET_NAME' attach -t '$SESSION_NAME'\""
fi

# Return the session ID and socket name for Oscar's scripts
# Format: SESSION_ID:SOCKET_NAME
echo "$BOB_SESSION_ID:$SOCKET_NAME"
