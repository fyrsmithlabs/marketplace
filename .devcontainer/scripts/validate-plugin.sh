#!/bin/bash
# Validate marketplace plugin structure and components

PLUGIN_DIR="/workspaces/marketplace"
ERRORS=0
WARNINGS=0

echo "=== Validating Marketplace Plugin ==="
echo ""

# Check plugin.json exists and is valid JSON
echo "Checking plugin.json..."
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    if jq empty "$PLUGIN_DIR/.claude-plugin/plugin.json" 2>/dev/null; then
        echo "  [OK] plugin.json is valid JSON"
    else
        echo "  [ERROR] plugin.json is invalid JSON"
        ((ERRORS++))
    fi
else
    echo "  [ERROR] plugin.json not found"
    ((ERRORS++))
fi

# Check commands
echo ""
echo "Checking commands..."
for cmd in "$PLUGIN_DIR"/commands/*.md; do
    if [ -f "$cmd" ]; then
        name=$(basename "$cmd" .md)
        # Check for frontmatter
        if head -1 "$cmd" | grep -q "^---"; then
            echo "  [OK] $name - has frontmatter"
        else
            echo "  [WARN] $name - missing frontmatter"
            ((WARNINGS++))
        fi
    fi
done

# Check skills
echo ""
echo "Checking skills..."
for skill_dir in "$PLUGIN_DIR"/skills/*/; do
    if [ -d "$skill_dir" ]; then
        name=$(basename "$skill_dir")
        if [ -f "$skill_dir/SKILL.md" ]; then
            echo "  [OK] $name - SKILL.md exists"
        else
            echo "  [ERROR] $name - missing SKILL.md"
            ((ERRORS++))
        fi
    fi
done

# Check agents
echo ""
echo "Checking agents..."
for agent in "$PLUGIN_DIR"/agents/*.md; do
    if [ -f "$agent" ]; then
        name=$(basename "$agent" .md)
        # Check for frontmatter
        if head -1 "$agent" | grep -q "^---"; then
            echo "  [OK] $name - has frontmatter"
        else
            echo "  [WARN] $name - missing frontmatter"
            ((WARNINGS++))
        fi
    fi
done

# Check hooks
echo ""
echo "Checking hooks..."
if [ -f "$PLUGIN_DIR/hooks/hooks.json" ]; then
    if jq empty "$PLUGIN_DIR/hooks/hooks.json" 2>/dev/null; then
        echo "  [OK] hooks.json is valid JSON"

        # Check for required keys
        if jq -e '.hooks.PreToolUse' "$PLUGIN_DIR/hooks/hooks.json" >/dev/null 2>&1; then
            echo "  [OK] PreToolUse hooks defined"
        elif jq -e '.PreToolUse' "$PLUGIN_DIR/hooks/hooks.json" >/dev/null 2>&1; then
            echo "  [WARN] hooks.json uses flat format (expected nested 'hooks' key)"
            ((WARNINGS++))
        fi
    else
        echo "  [ERROR] hooks.json is invalid JSON"
        ((ERRORS++))
    fi
else
    echo "  [WARN] hooks.json not found"
    ((WARNINGS++))
fi

# Summary
echo ""
echo "=== Validation Summary ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "FAILED - Plugin has errors that must be fixed"
    exit 1
else
    echo ""
    echo "PASSED - Plugin structure is valid"
    exit 0
fi
