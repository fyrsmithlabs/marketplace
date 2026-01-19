#!/bin/bash
# List all plugin components

PLUGIN_DIR="/workspaces/marketplace"

echo "=== Marketplace Plugin Components ==="
echo ""

# Plugin info
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    name=$(jq -r '.name // "unknown"' "$PLUGIN_DIR/.claude-plugin/plugin.json")
    version=$(jq -r '.version // "unknown"' "$PLUGIN_DIR/.claude-plugin/plugin.json")
    echo "Plugin: $name v$version"
    echo ""
fi

# Commands
echo "Commands:"
for cmd in "$PLUGIN_DIR"/commands/*.md; do
    if [ -f "$cmd" ]; then
        name=$(basename "$cmd" .md)
        desc=$(sed -n '/^---$/,/^---$/p' "$cmd" | grep "^description:" | sed 's/description: //' | head -c 60)
        printf "  %-20s %s...\n" "/$name" "$desc"
    fi
done

echo ""

# Skills
echo "Skills:"
for skill_dir in "$PLUGIN_DIR"/skills/*/; do
    if [ -d "$skill_dir" ]; then
        name=$(basename "$skill_dir")
        if [ -f "$skill_dir/SKILL.md" ]; then
            desc=$(sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" | grep "^description:" | sed 's/description: //' | head -c 60)
            printf "  %-25s %s...\n" "$name" "$desc"
        else
            printf "  %-25s (no SKILL.md)\n" "$name"
        fi
    fi
done

echo ""

# Agents
echo "Agents:"
for agent in "$PLUGIN_DIR"/agents/*.md; do
    if [ -f "$agent" ]; then
        name=$(basename "$agent" .md)
        desc=$(sed -n '/^---$/,/^---$/p' "$agent" | grep "^description:" | sed 's/description: //' | head -c 60)
        printf "  %-25s %s...\n" "$name" "$desc"
    fi
done

echo ""

# Hooks
echo "Hooks:"
if [ -f "$PLUGIN_DIR/hooks/hooks.json" ]; then
    # Try nested format first, then flat format
    pre_count=$(jq -r '.hooks.PreToolUse // .PreToolUse | length' "$PLUGIN_DIR/hooks/hooks.json" 2>/dev/null || echo "0")
    post_count=$(jq -r '.hooks.PostToolUse // .PostToolUse | length' "$PLUGIN_DIR/hooks/hooks.json" 2>/dev/null || echo "0")
    echo "  PreToolUse:  $pre_count hooks"
    echo "  PostToolUse: $post_count hooks"
else
    echo "  (no hooks.json)"
fi

echo ""
echo "=== Summary ==="
cmd_count=$(ls -1 "$PLUGIN_DIR"/commands/*.md 2>/dev/null | wc -l | tr -d ' ')
skill_count=$(ls -1d "$PLUGIN_DIR"/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
agent_count=$(ls -1 "$PLUGIN_DIR"/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Total: $cmd_count commands, $skill_count skills, $agent_count agents"
