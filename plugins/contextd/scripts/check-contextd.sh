#!/bin/bash
# check-contextd.sh - SessionStart hook for contextd status
# Provides context to Claude about contextd availability

# Check if contextd is available
if ! command -v contextd &> /dev/null; then
    cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "⚠️ contextd is not installed. Run `claude --init` to install it, or manually install via `brew install fyrsmithlabs/contextd/contextd`. Some contextd plugin features will be unavailable."
  }
}
EOF
    exit 0
fi

# Check if MCP is configured
if command -v ctxd &> /dev/null; then
    STATUS=$(ctxd mcp status 2>/dev/null)
    if echo "$STATUS" | grep -q "configured"; then
        cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "✓ contextd MCP server is configured and available. Use contextd tools (memory_search, checkpoint_save, etc.) for cross-session memory."
  }
}
EOF
    else
        cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "⚠️ contextd is installed but MCP not configured. Run `ctxd mcp install` or `/contextd:init` to configure."
  }
}
EOF
    fi
else
    # ctxd not available, just report contextd is installed
    VERSION=$(contextd --version 2>/dev/null || echo "unknown")
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "✓ contextd $VERSION is installed. Use contextd tools for cross-session memory."
  }
}
EOF
fi

exit 0
