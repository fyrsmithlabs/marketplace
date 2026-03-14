#!/bin/bash
# PreToolUse hook: Scan staged files for secrets before git commit
# Runs gitleaks on staged files to prevent accidental secret commits.
# Exit 0 = allow, Exit 2 = block with message

set -euo pipefail

# Gracefully degrade if gitleaks is not installed
if ! command -v gitleaks &>/dev/null; then
  echo "**Warning:** gitleaks is not installed. Skipping secret scan." >&2
  echo "Install with: brew install gitleaks" >&2
  exit 0
fi

# Supply chain: verify gitleaks is from a trusted installation path
GITLEAKS_PATH=$(command -v gitleaks)
case "$GITLEAKS_PATH" in
  /opt/homebrew/bin/*|/usr/local/bin/*|/home/*/go/bin/*|/Users/*/go/bin/*|/usr/bin/*)
    ;; # Known package manager / go install paths
  *)
    echo "**Warning:** gitleaks found at unexpected path: $GITLEAKS_PATH" >&2
    echo "Expected: brew (/opt/homebrew/bin/) or go install (~/go/bin/)" >&2
    echo "Verify this binary is legitimate before trusting scan results." >&2
    ;;
esac

# Build gitleaks command with optional project config
GITLEAKS_ARGS=(protect --staged --no-banner --exit-code 1)
if [ -f ".gitleaks.toml" ]; then
  GITLEAKS_ARGS+=(--config ".gitleaks.toml")
fi

# Run scan, capturing output to a temp file to avoid injection via heredoc
SCAN_TMPFILE=$(mktemp)
trap 'rm -f "$SCAN_TMPFILE"' EXIT

gitleaks "${GITLEAKS_ARGS[@]}" >"$SCAN_TMPFILE" 2>&1 && SCAN_EXIT=0 || SCAN_EXIT=$?

if [ "$SCAN_EXIT" -eq 0 ]; then
  exit 0
fi

# Secrets detected -- block the commit with a clear message
printf '## Secrets Detected in Staged Files\n\n'
printf '`gitleaks` found potential secrets in your staged changes:\n\n'
printf '```\n'
# Safe output: printf %s avoids interpreting escape sequences or shell metacharacters
printf '%s\n' "$(cat "$SCAN_TMPFILE")"
printf '```\n\n'
printf '### What to do\n\n'
printf '1. Remove the secret from the file\n'
printf '2. If it'\''s a false positive, add a `#gitleaks:allow` inline comment or update `.gitleaks.toml`\n'
printf '3. Re-stage and retry the commit\n\n'
printf '**Commit blocked.** Resolve the findings above before committing.\n'

exit 2
