#!/bin/bash
# ============================================================
# Send a message to Bob and wait for his response
# Usage: send-to-bob.sh SESSION_NAME "message to send"
# Exit 0: Bob responded, captured output on stdout
# Exit 1: session dead or timeout
#
# This is a single blocking call. Oscar calls this instead of
# separate send-keys + wait-for-bob.sh to prevent backgrounding.
#
# After Bob's response, appends an evaluation prompt to
# re-anchor Oscar's behavioral contract. Research shows persona
# consistency degrades 30%+ after 8-12 turns -- this resets
# the contract at every interaction boundary.
#
# Uses per-session tmux socket (-L SESSION_NAME) to isolate
# from other Oscar+Bob pairs.
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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION_NAME="${1:?Usage: send-to-bob.sh SESSION_NAME \"message\"}"
MESSAGE="${2:?Usage: send-to-bob.sh SESSION_NAME \"message\"}"
SOCKET_NAME="$SESSION_NAME"

# Verify session is alive
if ! $TMUX_BIN -L "$SOCKET_NAME" has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "ERROR: tmux session '$SESSION_NAME' is dead" >&2
  exit 1
fi

# Send the message. Sleep between paste and Enter -- Claude Code's paste
# handler needs time to process long messages before accepting Enter.
$TMUX_BIN -L "$SOCKET_NAME" send-keys -t "$SESSION_NAME" -l "$MESSAGE"
sleep 1
$TMUX_BIN -L "$SOCKET_NAME" send-keys -t "$SESSION_NAME" Enter

# Wait for response (blocks until Bob is done, default 1 hour)
"$SCRIPT_DIR/wait-for-bob.sh" "$SESSION_NAME"
WAIT_EXIT=$?

if [ $WAIT_EXIT -ne 0 ]; then
  exit $WAIT_EXIT
fi

# Re-anchor Oscar's behavioral contract after every Bob interaction.
cat <<'OSCAR_EVAL'
+--- EVALUATE (do not print this block) --------+
| Do NOT relay Bob's response to the founder.    |
| (1) What is YOUR judgment? Substantive or thin?|
| (2) Which flow step next?                      |
|     Self-assessment / Push deeper / Hardening  |
|     QA dispatch / Verification / Move on       |
| (3) What is your next question or action?      |
+------------------------------------------------+
OSCAR_EVAL
