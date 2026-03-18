#!/bin/bash
# PostToolUse hook: Validate plugin manifest consistency after edits
# Checks version alignment across plugin.json, marketplace.json, and CLAUDE.md
# Exit 0 = allow (always - this is advisory), outputs warnings to stderr

set -euo pipefail

# --- Resolve repo root ---
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -z "$REPO_ROOT" ]; then
  exit 0
fi

# --- File paths ---
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
FSDEV_PLUGIN_JSON="$REPO_ROOT/plugins/fs-dev/.claude-plugin/plugin.json"
CONTEXTD_PLUGIN_JSON="$REPO_ROOT/plugins/contextd/.claude-plugin/plugin.json"
FSDESIGN_PLUGIN_JSON="$REPO_ROOT/plugins/fs-design/.claude-plugin/plugin.json"
CLAUDE_MD="$REPO_ROOT/CLAUDE.md"

# --- Version extraction helpers ---
# Try jq first, fall back to grep-based extraction
extract_json_field() {
  local file="$1"
  local field="$2"

  if [ ! -f "$file" ]; then
    echo ""
    return
  fi

  if command -v jq &>/dev/null; then
    jq -r "$field // empty" "$file" 2>/dev/null || echo ""
  else
    # Grep fallback: find "version": "X.Y.Z" near the field context
    # This is a simplified extraction for flat version fields
    grep -oP '"version"\s*:\s*"\K[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null | head -1 || echo ""
  fi
}

extract_marketplace_plugin_version() {
  local file="$1"
  local plugin_name="$2"

  if [ ! -f "$file" ]; then
    echo ""
    return
  fi

  if command -v jq &>/dev/null; then
    jq -r --arg name "$plugin_name" '.plugins[] | select(.name == $name) | .version // empty' "$file" 2>/dev/null || echo ""
  else
    # Grep fallback: extract version after the plugin name block
    # This is approximate but sufficient for advisory warnings
    awk -v name="$plugin_name" '
      /"name"/ && $0 ~ "\"" name "\"" { found=1 }
      found && /"version"/ { gsub(/.*"version"[[:space:]]*:[[:space:]]*"/, ""); gsub(/".*/, ""); print; exit }
    ' "$file" 2>/dev/null || echo ""
  fi
}

extract_claudemd_version() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo ""
    return
  fi

  grep -oP '\*\*Version\*\*:\s*\K[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null | head -1 || echo ""
}

extract_claudemd_plugin_version() {
  local file="$1"
  local plugin_name="$2"

  if [ ! -f "$file" ]; then
    echo ""
    return
  fi

  # Extract version from the plugin table row: | `plugin-name` | vX.Y.Z |
  grep -P "^\|.*\`${plugin_name}\`" "$file" 2>/dev/null \
    | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' 2>/dev/null \
    | head -1 || echo ""
}

# --- Collect versions for each plugin ---
check_plugin() {
  local plugin_name="$1"
  local plugin_json="$2"
  local sources=()
  local versions=()

  # 1. Plugin's own plugin.json
  local v_plugin
  v_plugin=$(extract_json_field "$plugin_json" '.version')
  if [ -n "$v_plugin" ]; then
    sources+=("$plugin_json")
    versions+=("$v_plugin")
  fi

  # 2. Marketplace registry entry
  local v_marketplace
  v_marketplace=$(extract_marketplace_plugin_version "$MARKETPLACE_JSON" "$plugin_name")
  if [ -n "$v_marketplace" ]; then
    sources+=("marketplace.json plugins[$plugin_name]")
    versions+=("$v_marketplace")
  fi

  # 3. CLAUDE.md plugin table
  local v_claudemd
  v_claudemd=$(extract_claudemd_plugin_version "$CLAUDE_MD" "$plugin_name")
  if [ -n "$v_claudemd" ]; then
    sources+=("CLAUDE.md table[$plugin_name]")
    versions+=("$v_claudemd")
  fi

  # Compare all collected versions
  if [ ${#versions[@]} -lt 2 ]; then
    return
  fi

  local first="${versions[0]}"
  local has_mismatch=false
  for v in "${versions[@]}"; do
    if [ "$v" != "$first" ]; then
      has_mismatch=true
      break
    fi
  done

  if [ "$has_mismatch" = true ]; then
    echo "  Plugin: $plugin_name" >&2
    for i in "${!sources[@]}"; do
      echo "    ${sources[$i]}: ${versions[$i]}" >&2
    done
  fi
}

check_marketplace_metadata() {
  # Check marketplace metadata.version against CLAUDE.md header version
  local v_meta
  v_meta=$(extract_json_field "$MARKETPLACE_JSON" '.metadata.version')
  local v_claudemd
  v_claudemd=$(extract_claudemd_version "$CLAUDE_MD")

  if [ -n "$v_meta" ] && [ -n "$v_claudemd" ] && [ "$v_meta" != "$v_claudemd" ]; then
    echo "  Marketplace metadata:" >&2
    echo "    marketplace.json metadata.version: $v_meta" >&2
    echo "    CLAUDE.md **Version**: $v_claudemd" >&2
  fi
}

# --- Run checks ---
WARN_OUTPUT=$(mktemp)
trap 'rm -f "$WARN_OUTPUT"' EXIT

{
  check_marketplace_metadata
  check_plugin "fs-dev" "$FSDEV_PLUGIN_JSON"
  check_plugin "contextd" "$CONTEXTD_PLUGIN_JSON"
  check_plugin "fs-design" "$FSDESIGN_PLUGIN_JSON"
} 2>"$WARN_OUTPUT"

if [ -s "$WARN_OUTPUT" ]; then
  echo "## Manifest Version Drift Detected" >&2
  echo "" >&2
  echo "The following version mismatches were found across manifest files:" >&2
  echo "" >&2
  cat "$WARN_OUTPUT" >&2
  echo "" >&2
  echo "### What to do" >&2
  echo "" >&2
  echo "Ensure versions are consistent across:" >&2
  echo "- \`.claude-plugin/marketplace.json\` (metadata.version + plugins[].version)" >&2
  echo "- \`plugins/<name>/.claude-plugin/plugin.json\` (.version)" >&2
  echo "- \`CLAUDE.md\` (header **Version** + plugin table)" >&2
  echo "" >&2
  echo "**Advisory only** -- edit was not blocked." >&2
fi

# Always allow -- this hook is advisory
exit 0
