#!/bin/bash
# ============================================================
# Infrastructure Template -- Setup Script
# ============================================================
# Run this after cloning to hydrate all {PLACEHOLDER} values
# with your project-specific configuration.
#
# Usage:
#   ./setup.sh              # Interactive mode
#   ./setup.sh --check      # Show remaining placeholders
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Escape sed special characters ───────────────────────────
# Prevents user input containing &, |, \, /, etc. from
# corrupting sed replacement strings.
escape_sed() {
  printf '%s' "$1" | sed -e 's/[&/\|]/\\&/g'
}

# ── Check mode ──────────────────────────────────────────────

if [ "${1:-}" = "--check" ]; then
  echo ""
  echo "  Remaining placeholders:"
  echo ""

  # Phase 1: placeholders that setup.sh replaces
  echo "  -- Replaced by setup.sh (should be zero after running) --"
  grep -rn '{PROJECT_NAME}\|{project-name}\|{PROJECT_ROOT}\|{MONOREPO_ROOT}\|{GITHUB_ACCOUNT}\|{GCP_PROJECT_ID}\|{GCP_REGION}\|{FOUNDER_NAME}\|{your-name}' \
    --include="*.md" --include="*.json" --include="*.sh" --include="*.command" --include="*.ts" \
    "$SCRIPT_DIR" 2>/dev/null | grep -v 'node_modules' | grep -v '.git/' | grep -v 'setup.sh' || echo "  None -- setup.sh replacements are clean."
  echo ""

  # Phase 2: deferred placeholders (need project-specific config)
  echo "  -- Deferred (fill in when you set up these systems) --"
  grep -rn '{API_STAGING_URL}\|{SYSTEM_USER_UUID}\|{ORG_NAME}\|{ORG_SLUG}\|{ORG_UUID}\|{STAGING_DOMAIN}\|{PRODUCTION_DOMAIN}\|{NEON_CONNECTION_STRING}' \
    --include="*.md" --include="*.json" --include="*.sh" --include="*.command" --include="*.ts" \
    "$SCRIPT_DIR" 2>/dev/null | grep -v 'node_modules' | grep -v '.git/' || echo "  None."
  echo ""

  # Phase 3: manual-fill placeholders (require human input)
  echo "  -- Manual fill (replace with your project's commands/values) --"
  grep -rn '{YOUR[^}]*}\|{DATE}\|{ONE_SENTENCE_DESCRIPTION}\|{BRIEF_SUMMARY' \
    --include="*.md" --include="*.json" --include="*.sh" --include="*.command" --include="*.ts" \
    "$SCRIPT_DIR" 2>/dev/null | grep -v 'node_modules' | grep -v '.git/' | grep -v 'setup.sh' || echo "  None."
  echo ""
  exit 0
fi

echo ""
echo "  Infrastructure Template Setup"
echo ""
echo "  This will replace all {PLACEHOLDER} values in the template"
echo "  with your project-specific configuration."
echo ""

# ── Gather inputs ───────────────────────────────────────────

read -rp "  Project name (display name, e.g. 'MyProject'): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
  echo "  ERROR: Project name is required."
  exit 1
fi

# Derive lowercase-hyphenated version for package names
PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
echo "  Package slug: $PROJECT_SLUG"
echo ""

read -rp "  Project root (absolute path, e.g. '/Users/you/projects/myproject'): " PROJECT_ROOT
if [ -z "$PROJECT_ROOT" ]; then
  echo "  ERROR: Project root is required."
  exit 1
fi

read -rp "  Your name (e.g. 'Jane'): " FOUNDER_NAME
FOUNDER_NAME="${FOUNDER_NAME:-Founder}"

read -rp "  GitHub account (e.g. 'myorg' or 'myusername'): " GITHUB_ACCOUNT
GITHUB_ACCOUNT="${GITHUB_ACCOUNT:-your-github-account}"

read -rp "  Cloud provider project ID (e.g. 'my-project-123', or Enter to skip): " GCP_PROJECT_ID
GCP_PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"

read -rp "  Cloud provider region (e.g. 'us-central1', or Enter to skip): " GCP_REGION
GCP_REGION="${GCP_REGION:-us-central1}"

TODAY=$(date +%Y-%m-%d)

echo ""
echo "  Configuration:"
echo "    Project name:    $PROJECT_NAME"
echo "    Package slug:    $PROJECT_SLUG"
echo "    Project root:    $PROJECT_ROOT"
echo "    Founder name:    $FOUNDER_NAME"
echo "    GitHub account:  $GITHUB_ACCOUNT"
echo "    Cloud project:   $GCP_PROJECT_ID"
echo "    Cloud region:    $GCP_REGION"
echo "    Date:            $TODAY"
echo ""
read -rp "  Proceed? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[yY]$ ]]; then
  echo "  Aborted."
  exit 0
fi

echo ""
echo "  Applying replacements..."

# ── Escape inputs for safe sed usage ────────────────────────

E_PROJECT_NAME=$(escape_sed "$PROJECT_NAME")
E_PROJECT_SLUG=$(escape_sed "$PROJECT_SLUG")
E_PROJECT_ROOT=$(escape_sed "$PROJECT_ROOT")
E_FOUNDER_NAME=$(escape_sed "$FOUNDER_NAME")
E_GITHUB_ACCOUNT=$(escape_sed "$GITHUB_ACCOUNT")
E_GCP_PROJECT_ID=$(escape_sed "$GCP_PROJECT_ID")
E_GCP_REGION=$(escape_sed "$GCP_REGION")

# ── Replace placeholders ────────────────────────────────────

find "$SCRIPT_DIR" \
  -type f \
  \( -name "*.md" -o -name "*.json" -o -name "*.sh" -o -name "*.command" -o -name "*.ts" \) \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -not -name "setup.sh" \
  -print0 | while IFS= read -r -d '' file; do

  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' \
      -e "s|{PROJECT_NAME}|${E_PROJECT_NAME}|g" \
      -e "s|{project-name}|${E_PROJECT_SLUG}|g" \
      -e "s|{PROJECT_ROOT}|${E_PROJECT_ROOT}|g" \
      -e "s|{MONOREPO_ROOT}|${E_PROJECT_ROOT}|g" \
      -e "s|{FOUNDER_NAME}|${E_FOUNDER_NAME}|g" \
      -e "s|{your-name}|${E_FOUNDER_NAME}|g" \
      -e "s|{GITHUB_ACCOUNT}|${E_GITHUB_ACCOUNT}|g" \
      -e "s|{GCP_PROJECT_ID}|${E_GCP_PROJECT_ID}|g" \
      -e "s|{GCP_REGION}|${E_GCP_REGION}|g" \
      -e "s|{DATE}|${TODAY}|g" \
      "$file"
  else
    sed -i \
      -e "s|{PROJECT_NAME}|${E_PROJECT_NAME}|g" \
      -e "s|{project-name}|${E_PROJECT_SLUG}|g" \
      -e "s|{PROJECT_ROOT}|${E_PROJECT_ROOT}|g" \
      -e "s|{MONOREPO_ROOT}|${E_PROJECT_ROOT}|g" \
      -e "s|{FOUNDER_NAME}|${E_FOUNDER_NAME}|g" \
      -e "s|{your-name}|${E_FOUNDER_NAME}|g" \
      -e "s|{GITHUB_ACCOUNT}|${E_GITHUB_ACCOUNT}|g" \
      -e "s|{GCP_PROJECT_ID}|${E_GCP_PROJECT_ID}|g" \
      -e "s|{GCP_REGION}|${E_GCP_REGION}|g" \
      -e "s|{DATE}|${TODAY}|g" \
      "$file"
  fi
done

echo "  Done."
echo ""

# ── Post-setup report ───────────────────────────────────────

echo "  Replaced: {PROJECT_NAME}, {project-name}, {PROJECT_ROOT},"
echo "            {MONOREPO_ROOT}, {FOUNDER_NAME}, {your-name},"
echo "            {GITHUB_ACCOUNT}, {GCP_PROJECT_ID}, {GCP_REGION}, {DATE}"
echo ""
echo "  Deferred placeholders (fill in when you set up these systems):"
echo "    {API_STAGING_URL}       -- Your staging API URL (ticketing, deploys)"
echo "    {SYSTEM_USER_UUID}      -- Your system user UUID (ticketing)"
echo "    {ORG_NAME/SLUG/UUID}    -- Your organization (ticketing)"
echo "    {STAGING_DOMAIN}        -- Your staging domain (deploys)"
echo "    {PRODUCTION_DOMAIN}     -- Your production domain (deploys)"
echo "    {NEON_CONNECTION_STRING} -- Your database connection (if using Neon)"
echo ""
echo "  Manual-fill placeholders (replace with your project's values):"
echo "    {YOUR COMMANDS}         -- Dev commands in standards docs"
echo "    {YOUR DEV SERVER START COMMAND}"
echo "    {YOUR_TYPECHECK_COMMAND}"
echo "    {YOUR_TEST_COMMAND}"
echo ""
echo "  Run './setup.sh --check' to see what remains."
echo ""
echo "  Next steps:"
echo "    1. git diff                           -- review changes"
echo "    2. Add dev commands to build/AGENTS.md"
echo "    3. Add workspace packages to AGENTS.md"
echo "    4. Create first priority in build/PRIORITIES.md"
echo "    5. claude --agent bob                 -- start building"
echo ""
