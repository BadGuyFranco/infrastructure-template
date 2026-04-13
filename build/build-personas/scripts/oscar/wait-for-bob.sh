#!/bin/bash
# ============================================================
# Wait for Bob to finish responding, then capture his output
# Usage: wait-for-bob.sh [session-name] [max_seconds] [capture_lines]
#   session-name:  tmux session name (default: bob)
#   max_seconds:   timeout (default: 3600 -- 1 hour)
#   capture_lines: lines to capture (default: 50)
# Exit 0: Bob responded, output on stdout
# Exit 1: timeout or session dead
#
# Uses per-session tmux socket (-L SESSION_NAME) to isolate
# from other Oscar+Bob pairs.
#
# How it works:
# Claude Code shows "esc to interrupt" in the status bar while
# actively responding. When Bob finishes, that text disappears.
# To avoid false positives (brief gaps between tool calls),
# Bob must appear idle on 3 consecutive checks (3 seconds).
# ============================================================

set -euo pipefail

# --- tmux binary auto-detection ---
if [ -n "${TMUX_BIN:-}" ] && [ -x "$TMUX_BIN" ]; then
  : # use provided TMUX_BIN
elif [ -x /opt/homebrew/bin/tmux ]; then
  TMUX_BIN="/opt/homebrew/bin/tmux"
elif [ -x /usr/local/bin/tmux ]; then
  TMUX_BIN="/usr/local/bin/tmux"
elif command -v tmux &>/dev/null; then
  TMUX_BIN="$(command -v tmux)"
else
  echo "ERROR: tmux not found. Install with: brew install tmux" >&2
  exit 1
fi

SESSION_NAME="${1:-bob}"
MAX_WAIT="${2:-3600}"
CAPTURE_LINES="${3:-50}"
SOCKET_NAME="$SESSION_NAME"
IDLE_COUNT=0
IDLE_THRESHOLD=3

for i in $(seq 1 "$MAX_WAIT"); do
  # Check session is alive
  if ! $TMUX_BIN -L "$SOCKET_NAME" has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "ERROR: tmux session '$SESSION_NAME' is dead" >&2
    exit 1
  fi

  # Capture the pane
  OUTPUT=$($TMUX_BIN -L "$SOCKET_NAME" capture-pane -t "$SESSION_NAME" -p -S -"$CAPTURE_LINES" 2>/dev/null || true)

  # Check if TUI is rendered and Bob is NOT actively responding
  if echo "$OUTPUT" | grep -q 'bypass permissions' && ! echo "$OUTPUT" | grep -q 'esc to interrupt'; then
    IDLE_COUNT=$((IDLE_COUNT + 1))
    if [ "$IDLE_COUNT" -ge "$IDLE_THRESHOLD" ]; then
      echo "$OUTPUT"
      exit 0
    fi
  else
    IDLE_COUNT=0
  fi

  sleep 1
done

echo "ERROR: Bob did not finish responding within ${MAX_WAIT}s" >&2
exit 1
