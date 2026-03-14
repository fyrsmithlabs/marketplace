#!/bin/bash
# PreToolUse hook: Validate branch before writes/pushes
# Prevents accidental modifications to protected branches.
# Usage: ./hooks/branch-guard.sh [write|push]
# Exit 0 = allow, Exit 2 = block with message

set -euo pipefail

ACTION="${1:-}"
if [ -z "$ACTION" ]; then
  echo "Usage: $0 [write|push]" >&2
  exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ -z "$BRANCH" ]; then
  # Detached HEAD or not a git repo -- nothing to guard
  exit 0
fi

# Validate branch name contains only safe characters
if [[ ! "$BRANCH" =~ ^[a-zA-Z0-9/_.-]+$ ]]; then
  echo "Error: unexpected branch name format" >&2
  exit 2
fi

# Check if current branch is protected
is_protected() {
  case "$1" in
    main|master) return 0 ;;
    release/*) return 0 ;;
    *) return 1 ;;
  esac
}

if ! is_protected "$BRANCH"; then
  exit 0
fi

# --- Protected branch handling ---

if [ "$ACTION" = "push" ]; then
  # Allow override via env var for exceptional cases
  if [ "${ALLOW_MAIN_PUSH:-0}" = "1" ]; then
    exit 0
  fi

  cat << EOF
## Push to Protected Branch Blocked

You are attempting to push directly to **${BRANCH}**, which is a protected branch.

### What to do

1. Create a feature branch: \`git checkout -b feat/your-feature\`
2. Push the feature branch instead
3. Open a pull request to merge into **${BRANCH}**

Set \`ALLOW_MAIN_PUSH=1\` to override this check (not recommended).

**Push blocked.**
EOF
  exit 2
fi

if [ "$ACTION" = "write" ]; then
  # Warn but allow -- the first nudge is enough to redirect behavior
  echo "**Warning:** You are modifying files on protected branch **${BRANCH}**. Consider switching to a feature branch." >&2
  exit 0
fi

# Unknown action -- allow by default
exit 0
