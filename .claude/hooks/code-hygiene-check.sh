#!/bin/bash
# Async PostToolUse hook for Edit|Write.
# Checks TypeScript files for hard-limit violations after edits.
# Exit 0 = silent pass. Exit 2 = stderr fed to Claude as feedback.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# If we can't determine the file, pass silently
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only check TypeScript files
case "$FILE_PATH" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Skip test files, config files, declaration files
case "$FILE_PATH" in
  *.test.ts|*.spec.ts|*.d.ts|*.config.ts) exit 0 ;;
esac

# Check 1: File length > 300 lines (hard limit)
if [ -f "$FILE_PATH" ]; then
  LINES=$(wc -l < "$FILE_PATH" | tr -d ' ')
  if [ "$LINES" -gt 300 ]; then
    echo "CODE HYGIENE: $FILE_PATH is $LINES lines (limit: 300). Split this file before continuing." >&2
    exit 2
  fi
fi

# Check 2: 'any' type usage (prohibited)
if [ -f "$FILE_PATH" ]; then
  ANY_COUNT=$(grep -cE ':\s*any\b|<any>|as any' "$FILE_PATH" 2>/dev/null || echo 0)
  if [ "$ANY_COUNT" -gt 0 ]; then
    LOCATIONS=$(grep -nE ':\s*any\b|<any>|as any' "$FILE_PATH" 2>/dev/null | head -3)
    echo "CODE HYGIENE: $FILE_PATH contains $ANY_COUNT 'any' type usage(s). Use 'unknown' and narrow instead." >&2
    echo "$LOCATIONS" >&2
    exit 2
  fi
fi

exit 0
