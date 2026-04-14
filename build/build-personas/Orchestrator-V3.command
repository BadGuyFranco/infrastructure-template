#!/bin/bash
# ============================================================
# {PROJECT_NAME} Orchestrator V3 -- Hardened Launcher
# ============================================================
# Double-click to launch. Features:
#
#   1. Drops tmux -CC mode. Sessions survive iTerm disconnection.
#      Closing a tab detaches; tmux session keeps running.
#   2. One iTerm window with split panes (teammate + persona).
#      No extra control windows. No leftover launcher window.
#   3. Auto-restart wrapper. If Claude Code exits non-zero
#      (context exhaustion, API error, crash), it resumes the
#      session after 5 seconds. Clean exit (code 0) stops.
#      Kill the tmux session to truly stop.
#   4. Multi-account support via ~/.claude-accounts.
#   5. Multi-persona support (Oscar or custom orchestrators).
#
# SETUP: Update INFRA_DIR and the --add-dir paths below
# to match your project layout before first use.
# ============================================================

set -euo pipefail

# ── Configuration ──────────────────────────────────────────
# Update these paths for your project:
INFRA_DIR="{PROJECT_ROOT}"
PRIORITIES_FILE="$INFRA_DIR/build/PRIORITIES.md"
SESSION_LOG="$INFRA_DIR/build/SESSION_LOG.md"
PERSONAS_DIR="$INFRA_DIR/build/build-personas"
ACCOUNTS_FILE="$HOME/.claude-accounts"
TMUX_BIN="/opt/homebrew/bin/tmux"

echo ""
echo "  {PROJECT_NAME} Orchestrator V3"
echo ""

# ── Verify dependencies ─────────────────────────────────────

if ! command -v claude &>/dev/null; then
  echo "  ERROR: claude not found on PATH"
  exit 1
fi

if [ ! -x "$TMUX_BIN" ]; then
  echo "  ERROR: tmux not found at $TMUX_BIN"
  echo "  Install with: brew install tmux"
  exit 1
fi

if [ ! -f "$PRIORITIES_FILE" ]; then
  echo "  ERROR: PRIORITIES.md not found: $PRIORITIES_FILE"
  exit 1
fi

if [ ! -f "$ACCOUNTS_FILE" ]; then
  echo "  ERROR: Account config not found: $ACCOUNTS_FILE"
  exit 1
fi

if [ ! -d "/Applications/iTerm.app" ]; then
  echo "  ERROR: iTerm2 required (V3 uses iTerm panes)"
  exit 1
fi

# ── Choose Claude Code account ─────────────────────────────

declare -a ACCT_NAMES=()
declare -a ACCT_DIRS=()
while IFS='=' read -r name dir; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  expanded_dir="${dir/#\~/$HOME}"
  ACCT_NAMES+=("$name")
  ACCT_DIRS+=("$expanded_dir")
done < "$ACCOUNTS_FILE"

if [ ${#ACCT_NAMES[@]} -eq 0 ]; then
  echo "  ERROR: No accounts found in $ACCOUNTS_FILE"
  exit 1
fi

echo "  Claude Code Account:"
echo ""
for i in "${!ACCT_NAMES[@]}"; do
  printf "  %d    %s (%s)\n" "$((i + 1))" "${ACCT_NAMES[$i]}" "${ACCT_DIRS[$i]}"
done
echo ""
printf "  > "
read -r ACCT_CHOICE

ACCT_IDX=$((ACCT_CHOICE - 1))
if [ "$ACCT_IDX" -lt 0 ] || [ "$ACCT_IDX" -ge "${#ACCT_NAMES[@]}" ]; then
  echo "  Invalid account choice: $ACCT_CHOICE"
  exit 1
fi

SELECTED_ACCT="${ACCT_NAMES[$ACCT_IDX]}"
SELECTED_CONFIG_DIR="${ACCT_DIRS[$ACCT_IDX]}"

echo ""
echo "  Account: $SELECTED_ACCT ($SELECTED_CONFIG_DIR)"
echo ""

# ── Parse priorities from PRIORITIES.md ──────────────────────

ENTRIES=()
while IFS=$'\t' read -r slug owner status summary; do
  ENTRIES+=("$slug"$'\t'"$owner"$'\t'"$status"$'\t'"$summary")
done < <(awk '
  /^### .+ \[.+\]/ {
    slug = $0
    gsub(/.*\[/, "", slug)
    gsub(/\].*/, "", slug)
    owner = ""
    summary = ""
    status = ""
  }
  /^\*\*Owner:\*\*/ && slug != "" {
    owner = $0
    sub(/^\*\*Owner:\*\* */, "", owner)
  }
  /^\*\*Summary:\*\*/ && slug != "" {
    summary = $0
    sub(/^\*\*Summary:\*\* */, "", summary)
  }
  /^\*\*Status:\*\*/ && slug != "" {
    status = $0
    sub(/^\*\*Status:\*\* */, "", status)
    sub(/[.(].*/, "", status)
    sub(/ +$/, "", status)
    if (length(status) > 24) status = substr(status, 1, 21) "..."
    printf "%s\t%s\t%s\t%s\n", slug, owner, status, summary
    slug = ""
  }
' "$PRIORITIES_FILE")

if [ ${#ENTRIES[@]} -eq 0 ]; then
  echo "  ERROR: No priorities found with Owner/Summary fields in PRIORITIES.md"
  exit 1
fi

# ── Display menu ─────────────────────────────────────────────

printf "  %-4s %-18s %-7s %-24s %s\n" "#" "[SLUG]" "Owner" "Status" "Summary"
printf "  %-4s %-18s %-7s %-24s %s\n" "---" "----------------" "-----" "----------------------" "-------"

i=1
for entry in "${ENTRIES[@]}"; do
  IFS=$'\t' read -r slug owner status summary <<< "$entry"
  printf "  %-4s %-18s %-7s %-24s %s\n" "$i" "[$slug]" "$owner" "$status" "$summary"
  i=$((i + 1))
done

echo ""
echo "  O    Launch Oscar (build orchestrator) without a priority"
# Uncomment the line below if you have additional orchestrator personas:
# echo "  I    Launch {PERSONA} ({role}) without a priority"
echo ""
printf "  > "
read -r CHOICE

# ── Determine what to launch ─────────────────────────────────

PERSONA=""
SELECTED_SLUG=""
SELECTED_SUMMARY=""

case "$CHOICE" in
  [oO])
    PERSONA="oscar"
    ;;
  # Uncomment for additional orchestrator personas:
  # [iI])
  #   PERSONA="{persona}"
  #   ;;
  ''|*[!0-9]*)
    echo "  Invalid choice: $CHOICE"
    exit 1
    ;;
  *)
    IDX=$((CHOICE - 1))
    if [ "$IDX" -lt 0 ] || [ "$IDX" -ge "${#ENTRIES[@]}" ]; then
      echo "  Invalid number: $CHOICE (valid: 1-${#ENTRIES[@]})"
      exit 1
    fi
    IFS=$'\t' read -r SELECTED_SLUG owner _status SELECTED_SUMMARY <<< "${ENTRIES[$IDX]}"
    PERSONA="oscar"
    ;;
esac

echo ""

# ── Determine teammate ─────────────────────────────────────

TEAMMATE="bob"
TEAMMATE_DISPLAY="Bob"
# Uncomment to route specific priorities to different teammates:
# if [ -n "$SELECTED_SLUG" ] && [ "$SELECTED_SLUG" = "{SLUG}" ]; then
#   TEAMMATE="{other-persona}"
#   TEAMMATE_DISPLAY="{Other Persona}"
# fi

if [ -n "$SELECTED_SLUG" ]; then
  echo "  Priority: [$SELECTED_SLUG] ($PERSONA + $TEAMMATE)"
else
  echo "  Launching $PERSONA without a priority (teammate: $TEAMMATE)"
fi

# ── Session numbering ───────────────────────────────────────

LOCK_DIR="/tmp/orchestrator-session-lock"
while ! mkdir "$LOCK_DIR" 2>/dev/null; do
  LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR" 2>/dev/null || echo 0) ))
  if [ "$LOCK_AGE" -gt 30 ]; then
    rmdir "$LOCK_DIR" 2>/dev/null || true
    continue
  fi
  echo "  Waiting for another session launch to finish..." >&2
  sleep 2
done
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

LAST_SESSION=$(grep -oE 'session [0-9]+' "$SESSION_LOG" | grep -oE '[0-9]+' | sort -n | tail -1)

SESSION_NUM=$((LAST_SESSION + 1))
# Check ALL socket types to avoid collisions across teammate types.
session_num_in_use() {
  local num=$1
  for prefix in bob oscar; do
    if ls /private/tmp/tmux-*/${prefix}-${num} 2>/dev/null | grep -q .; then
      return 0
    fi
  done
  return 1
}
while session_num_in_use "$SESSION_NUM"; do
  SESSION_NUM=$((SESSION_NUM + 1))
done

TEAMMATE_SESSION="${TEAMMATE}-${SESSION_NUM}"

echo "  Session: $SESSION_NUM"
echo "  Teammate: $TEAMMATE (tmux: $TEAMMATE_SESSION)"
echo ""

# ── Resolve persona paths ────────────────────────────────────

SCRIPT_DIR="$PERSONAS_DIR/scripts/oscar"
PERSONA_LABEL="Oscar"
PERSONA_TITLE="build orchestrator"

# Uncomment for additional orchestrator personas:
# if [ "$PERSONA" = "{persona}" ]; then
#   SCRIPT_DIR="$PERSONAS_DIR/scripts/{persona}"
#   PERSONA_LABEL="{Persona}"
#   PERSONA_TITLE="{role title}"
# fi

PERSONA_SESSION="${PERSONA}-${SESSION_NUM}"

# ── Generate session IDs ────────────────────────────────────

TEAMMATE_SESSION_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
PERSONA_SESSION_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')

# ── Build teammate --add-dir flags ──────────────────────────
# Update these paths for your project layout.

TEAMMATE_ADD_DIRS=""
# Example: --add-dir '/path/to/shared/memory' --add-dir '/path/to/shared/tools'

# ── Launch teammate in tmux with restart wrapper ─────────────

echo "  Starting $TEAMMATE_DISPLAY (Claude Code) in tmux... [account: $SELECTED_ACCT]"

TEAMMATE_SCRIPT="/tmp/${PROJECT_NAME:-project}-v3-${SESSION_NUM}-teammate.sh"
cat > "$TEAMMATE_SCRIPT" << TEAMMATE_EOF
#!/bin/bash
# CWD stays local (inherited from tmux) for USB-disconnect resilience.
# Claude runs in a subshell that cd's to the project dir. If an external
# drive disconnects (sleep/USB), the subshell dies but this outer shell
# survives to retry.
export CLAUDE_CONFIG_DIR="${SELECTED_CONFIG_DIR}"
export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1

WORK_DIR="${INFRA_DIR}"

# First launch creates the session
(cd "\$WORK_DIR" && exec claude --session-id "${TEAMMATE_SESSION_ID}" \\
  --agent "${TEAMMATE}" \\
  --name "session-${SESSION_NUM}" \\
  ${TEAMMATE_ADD_DIRS})
LAST_EXIT=\$?

# Restart loop: non-zero exit resumes after 5s, clean exit stops
while [ \$LAST_EXIT -ne 0 ]; do
  echo ""
  echo "  ${TEAMMATE_DISPLAY} exited (code \$LAST_EXIT). Restarting in 5s... (Ctrl+C to stop)"
  sleep 5
  # Wait for working directory to be accessible (drive may be remounting)
  while [ ! -d "\$WORK_DIR" ]; do
    echo "  Waiting for \$WORK_DIR to become available..."
    sleep 5
  done
  (cd "\$WORK_DIR" && exec claude --resume "${TEAMMATE_SESSION_ID}" \\
    --agent "${TEAMMATE}" \\
    ${TEAMMATE_ADD_DIRS})
  LAST_EXIT=\$?
done

echo ""
echo "  Session ended. Auto-closing in 30s (press any key to close now)."
read -t 30 || true
TEAMMATE_EOF
chmod +x "$TEAMMATE_SCRIPT"

$TMUX_BIN -L "$TEAMMATE_SESSION" new-session -d -s "$TEAMMATE_SESSION" -x 200 -y 50 \
  "bash '${TEAMMATE_SCRIPT}'"
$TMUX_BIN -L "$TEAMMATE_SESSION" set-option -t "$TEAMMATE_SESSION" allow-rename off
$TMUX_BIN -L "$TEAMMATE_SESSION" set-option -t "$TEAMMATE_SESSION" set-titles on
$TMUX_BIN -L "$TEAMMATE_SESSION" set-option -t "$TEAMMATE_SESSION" set-titles-string "${TEAMMATE_DISPLAY} (session ${SESSION_NUM})"

# Wait for Claude Code TUI to render the input prompt
echo "  Waiting for ${TEAMMATE_DISPLAY}'s TUI to initialize..."
READY=false
for i in $(seq 1 60); do
  sleep 1
  if $TMUX_BIN -L "$TEAMMATE_SESSION" capture-pane -t "$TEAMMATE_SESSION" -p 2>/dev/null | grep -q '❯'; then
    READY=true
    break
  fi
done

if [ "$READY" = false ]; then
  echo "  ERROR: ${TEAMMATE_DISPLAY}'s TUI did not show input prompt within 60 seconds"
  exit 1
fi

# Verify teammate is fully idle (not mid-initialization)
echo "  Verifying ${TEAMMATE_DISPLAY} is idle..."
TEAMMATE_READY=false
for i in $(seq 1 30); do
  sleep 1
  PANE=$($TMUX_BIN -L "$TEAMMATE_SESSION" capture-pane -t "$TEAMMATE_SESSION" -p -S -30 2>/dev/null || true)
  if [ -n "$PANE" ] && ! echo "$PANE" | grep -q 'esc to interrupt'; then
    TEAMMATE_READY=true
    echo "  ${TEAMMATE_DISPLAY} is idle (confirmed after ${i}s)."
    break
  fi
done

if [ "$TEAMMATE_READY" = false ]; then
  echo "  WARNING: Could not confirm ${TEAMMATE_DISPLAY} is idle (30s). Proceeding."
fi

echo ""

# ── Build initial prompt ─────────────────────────────────────

if [ -n "$SELECTED_SLUG" ]; then
  INITIAL_PROMPT="You are ${PERSONA_LABEL}, the ${PERSONA_TITLE}. Session ${SESSION_NUM}.

Read build/build-personas/${PERSONA}.md now. That is your playbook. The Rules section is non-negotiable -- follow it exactly.

${TEAMMATE_DISPLAY} is running in tmux session '${TEAMMATE_SESSION}'. Use send-to-bob.sh to talk to him:
  build/build-personas/scripts/${PERSONA}/send-to-bob.sh ${TEAMMATE_SESSION} \"message\"

The founder has selected priority [${SELECTED_SLUG}]: ${SELECTED_SUMMARY}

BEFORE ANYTHING ELSE: Show the founder every directory path you have loaded in this session. Then send ${TEAMMATE_DISPLAY} \"list your loaded directories\" via send-to-bob.sh and show the founder his response. Do not proceed until both directory lists are visible.

After directories are confirmed:
1. Read PRIORITIES.md and SESSION_LOG.md (last 2-3 entries) yourself. Focus on [$SELECTED_SLUG].
2. Send ${TEAMMATE_DISPLAY} the priority [$SELECTED_SLUG] and drive. From this point, you evaluate, you question, you decide. Do not ask for permission to continue."
else
  INITIAL_PROMPT="You are ${PERSONA_LABEL}, the ${PERSONA_TITLE}. Session ${SESSION_NUM}.

Read build/build-personas/${PERSONA}.md now. That is your playbook. The Rules section is non-negotiable -- follow it exactly.

${TEAMMATE_DISPLAY} is running in tmux session '${TEAMMATE_SESSION}'. Use send-to-bob.sh to talk to him:
  build/build-personas/scripts/${PERSONA}/send-to-bob.sh ${TEAMMATE_SESSION} \"message\"

BEFORE ANYTHING ELSE: Show the founder every directory path you have loaded in this session. Then send ${TEAMMATE_DISPLAY} \"list your loaded directories\" via send-to-bob.sh and show the founder his response. Do not proceed until both directory lists are visible.

After directories are confirmed:
1. Read PRIORITIES.md and SESSION_LOG.md (last 2-3 entries) yourself.
2. Read the active plan if any.
3. Present the founder with a numbered list of ALL priorities from PRIORITIES.md, each with: [SLUG] and a one-line summary. The founder needs the complete picture. No recommendation -- the list speaks for itself.
4. After the founder confirms: send ${TEAMMATE_DISPLAY} the priority and drive. From that point, you evaluate, you question, you decide. Do not ask for permission to continue."
fi

# ── Launch persona in tmux with restart wrapper ──────────────

echo "  Starting $PERSONA_LABEL ($PERSONA_TITLE)... [account: $SELECTED_ACCT]"

PERSONA_SCRIPT="/tmp/${PROJECT_NAME:-project}-v3-${SESSION_NUM}-persona.sh"
cat > "$PERSONA_SCRIPT" << PERSONA_EOF
#!/bin/bash
# CWD stays local for USB-disconnect resilience (see teammate wrapper comments).
export CLAUDE_CONFIG_DIR="${SELECTED_CONFIG_DIR}"

WORK_DIR="${INFRA_DIR}"

# First launch creates the session
(cd "\$WORK_DIR" && exec claude --session-id "${PERSONA_SESSION_ID}" \\
  --dangerously-skip-permissions \\
  --agent "${PERSONA}" \\
  --name "session-${SESSION_NUM}" \\
  --add-dir "${INFRA_DIR}")
LAST_EXIT=\$?

# Restart loop: non-zero exit resumes after 5s, clean exit stops
while [ \$LAST_EXIT -ne 0 ]; do
  echo ""
  echo "  ${PERSONA_LABEL} exited (code \$LAST_EXIT). Restarting in 5s... (Ctrl+C to stop)"
  sleep 5
  while [ ! -d "\$WORK_DIR" ]; do
    echo "  Waiting for \$WORK_DIR to become available..."
    sleep 5
  done
  (cd "\$WORK_DIR" && exec claude --resume "${PERSONA_SESSION_ID}" \\
    --dangerously-skip-permissions \\
    --agent "${PERSONA}" \\
    --add-dir "${INFRA_DIR}")
  LAST_EXIT=\$?
done

echo ""
echo "  Session ended. Auto-closing in 30s (press any key to close now)."
read -t 30 || true
PERSONA_EOF
chmod +x "$PERSONA_SCRIPT"

$TMUX_BIN -L "$PERSONA_SESSION" new-session -d -s "$PERSONA_SESSION" -x 200 -y 50 \
  "bash '${PERSONA_SCRIPT}'"
$TMUX_BIN -L "$PERSONA_SESSION" set-option -t "$PERSONA_SESSION" allow-rename off
$TMUX_BIN -L "$PERSONA_SESSION" set-option -t "$PERSONA_SESSION" set-titles on
$TMUX_BIN -L "$PERSONA_SESSION" set-option -t "$PERSONA_SESSION" set-titles-string "${PERSONA_LABEL} (session ${SESSION_NUM})"

# Wait for TUI to initialize
echo "  Waiting for ${PERSONA_LABEL}'s TUI to initialize..."
READY=false
for i in $(seq 1 60); do
  sleep 1
  if $TMUX_BIN -L "$PERSONA_SESSION" capture-pane -t "$PERSONA_SESSION" -p 2>/dev/null | grep -q '❯'; then
    READY=true
    break
  fi
done

if [ "$READY" = false ]; then
  echo "  ERROR: ${PERSONA_LABEL}'s TUI did not show input prompt within 60 seconds"
  exit 1
fi

# ── Send initial prompt to persona ───────────────────────────

echo "  Sending initial prompt to ${PERSONA_LABEL}..."
$TMUX_BIN -L "$PERSONA_SESSION" send-keys -t "$PERSONA_SESSION" -l "$INITIAL_PROMPT"
sleep 1
$TMUX_BIN -L "$PERSONA_SESSION" send-keys -t "$PERSONA_SESSION" Enter

# ── Set tmux window titles ───────────────────────────────────

$TMUX_BIN -L "$TEAMMATE_SESSION" rename-window -t "$TEAMMATE_SESSION" "${TEAMMATE_DISPLAY} (session ${SESSION_NUM})"
$TMUX_BIN -L "$PERSONA_SESSION" rename-window -t "$PERSONA_SESSION" "${PERSONA_LABEL} (session ${SESSION_NUM})"

# ── Open ONE iTerm window with side-by-side panes ────────────

echo "  Opening iTerm window..."

osascript << ITERM_EOF
tell application "iTerm"
  activate

  -- Create window with persona (left pane)
  set newWindow to (create window with default profile command "$TMUX_BIN -L $PERSONA_SESSION attach -t $PERSONA_SESSION")
  set personaSession to current session of current tab of newWindow

  -- Split right: teammate (right pane)
  tell personaSession
    set teammateSession to (split vertically with default profile command "$TMUX_BIN -L $TEAMMATE_SESSION attach -t $TEAMMATE_SESSION")
  end tell

  -- Name the panes
  tell personaSession
    set name to "${PERSONA_LABEL} (session ${SESSION_NUM})"
  end tell
  tell teammateSession
    set name to "${TEAMMATE_DISPLAY} (session ${SESSION_NUM})"
  end tell

  -- Focus persona (left pane) so founder sees Oscar first
  tell personaSession
    select
  end tell
end tell
ITERM_EOF

echo ""
echo "  ${PERSONA_LABEL} + ${TEAMMATE_DISPLAY} running in iTerm split panes."
echo "  Tmux sessions: $TEAMMATE_SESSION, $PERSONA_SESSION"
echo "  Close tabs to detach. Sessions survive."
echo ""

# ── Prevent system sleep while sessions are running ────────────
# Sentinel loop checks every 60s if either tmux session is alive.
# When both are gone, sentinel exits, caffeinate follows, sleep resumes.

SENTINEL_SCRIPT="/tmp/${PROJECT_NAME:-project}-v3-${SESSION_NUM}-sentinel.sh"
cat > "$SENTINEL_SCRIPT" << SENTINEL_EOF
#!/bin/bash
while ${TMUX_BIN} -L ${TEAMMATE_SESSION} has-session -t ${TEAMMATE_SESSION} 2>/dev/null || \\
      ${TMUX_BIN} -L ${PERSONA_SESSION} has-session -t ${PERSONA_SESSION} 2>/dev/null; do
  sleep 60
done
SENTINEL_EOF
chmod +x "$SENTINEL_SCRIPT"
nohup bash "$SENTINEL_SCRIPT" &>/dev/null &
SENTINEL_PID=$!
nohup caffeinate -s -w $SENTINEL_PID &>/dev/null &

# Self-close this Terminal.app launcher window
osascript -e 'tell application "Terminal" to close front window' &
exit 0
