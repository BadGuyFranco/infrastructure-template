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

# ── Check mode ──────────────────────────────────────────────

if [ "${1:-}" = "--check" ]; then
  echo ""
  echo "  Remaining placeholders:"
  echo ""
  grep -rn '{PROJECT_NAME}\|{PROJECT_ROOT}\|{MONOREPO_ROOT}\|{GITHUB_ACCOUNT}\|{GCP_PROJECT_ID}\|{GCP_REGION}\|{DATE}\|{project-name}\|{YOUR DEV SERVER START COMMAND}' \
    --include="*.md" --include="*.json" --include="*.sh" --include="*.command" \
    "$SCRIPT_DIR" 2>/dev/null | grep -v 'node_modules' | grep -v '.git/' || echo "  None found -- template is fully hydrated."
  echo ""
  exit 0
fi

echo ""
echo "  Infrastructure Template Setup"
echo "  ────────────────────────────────"
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

read -rp "  GitHub account (e.g. 'myorg' or 'myusername'): " GITHUB_ACCOUNT
GITHUB_ACCOUNT="${GITHUB_ACCOUNT:-your-github-account}"

read -rp "  Cloud provider project ID (e.g. 'my-project-123', or press Enter to skip): " GCP_PROJECT_ID
GCP_PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"

read -rp "  Cloud provider region (e.g. 'us-central1', or press Enter to skip): " GCP_REGION
GCP_REGION="${GCP_REGION:-us-central1}"

TODAY=$(date +%Y-%m-%d)

echo ""
echo "  Configuration:"
echo "    Project name:    $PROJECT_NAME"
echo "    Package slug:    $PROJECT_SLUG"
echo "    Project root:    $PROJECT_ROOT"
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

# ── Replace placeholders ────────────────────────────────────

# Find all text files in the repo (excluding .git, node_modules)
find "$SCRIPT_DIR" \
  -type f \
  \( -name "*.md" -o -name "*.json" -o -name "*.sh" -o -name "*.command" -o -name "*.ts" \) \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/setup.sh" \
  -print0 | while IFS= read -r -d '' file; do

  # Apply replacements (macOS sed requires '' after -i)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' \
      -e "s|{PROJECT_NAME}|${PROJECT_NAME}|g" \
      -e "s|{project-name}|${PROJECT_SLUG}|g" \
      -e "s|{PROJECT_ROOT}|${PROJECT_ROOT}|g" \
      -e "s|{MONOREPO_ROOT}|${PROJECT_ROOT}|g" \
      -e "s|{GITHUB_ACCOUNT}|${GITHUB_ACCOUNT}|g" \
      -e "s|{GCP_PROJECT_ID}|${GCP_PROJECT_ID}|g" \
      -e "s|{GCP_REGION}|${GCP_REGION}|g" \
      -e "s|{DATE}|${TODAY}|g" \
      "$file"
  else
    sed -i \
      -e "s|{PROJECT_NAME}|${PROJECT_NAME}|g" \
      -e "s|{project-name}|${PROJECT_SLUG}|g" \
      -e "s|{PROJECT_ROOT}|${PROJECT_ROOT}|g" \
      -e "s|{MONOREPO_ROOT}|${PROJECT_ROOT}|g" \
      -e "s|{GITHUB_ACCOUNT}|${GITHUB_ACCOUNT}|g" \
      -e "s|{GCP_PROJECT_ID}|${GCP_PROJECT_ID}|g" \
      -e "s|{GCP_REGION}|${GCP_REGION}|g" \
      -e "s|{DATE}|${TODAY}|g" \
      "$file"
  fi
done

echo "  Done."
echo ""

# ── Post-setup checklist ────────────────────────────────────

echo "  Next steps:"
echo ""
echo "  1. Review the changes:  git diff"
echo "  2. Add your dev commands to build/AGENTS.md"
echo "  3. Add workspace packages to AGENTS.md"
echo "  4. Create your first priority in build/PRIORITIES.md"
echo "  5. Set up Claude Code:  claude auth"
echo "  6. Test a session:      claude --agent bob"
echo ""
echo "  Run './setup.sh --check' to verify no placeholders remain."
echo ""
