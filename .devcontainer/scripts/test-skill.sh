#!/bin/bash
# Test a specific skill by name

SKILL_NAME="$1"
PLUGIN_DIR="/workspaces/marketplace"
TEST_DIR="/workspaces/test-project"

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: test-skill <skill-name>"
    echo ""
    echo "Available skills:"
    for skill_dir in "$PLUGIN_DIR"/skills/*/; do
        if [ -d "$skill_dir" ]; then
            echo "  - $(basename "$skill_dir")"
        fi
    done
    exit 1
fi

SKILL_DIR="$PLUGIN_DIR/skills/$SKILL_NAME"

if [ ! -d "$SKILL_DIR" ]; then
    echo "Error: Skill '$SKILL_NAME' not found"
    echo ""
    echo "Available skills:"
    for skill_dir in "$PLUGIN_DIR"/skills/*/; do
        if [ -d "$skill_dir" ]; then
            echo "  - $(basename "$skill_dir")"
        fi
    done
    exit 1
fi

echo "=== Testing Skill: $SKILL_NAME ==="
echo ""

# Check SKILL.md exists
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    echo "[OK] SKILL.md exists"

    # Check for frontmatter
    if head -1 "$SKILL_DIR/SKILL.md" | grep -q "^---"; then
        echo "[OK] Has valid frontmatter"

        # Extract and display description
        desc=$(sed -n '/^---$/,/^---$/p' "$SKILL_DIR/SKILL.md" | grep "^description:" | sed 's/description: //')
        if [ -n "$desc" ]; then
            echo "[OK] Description: ${desc:0:80}..."
        fi
    else
        echo "[WARN] Missing frontmatter"
    fi
else
    echo "[ERROR] SKILL.md missing"
    exit 1
fi

# Check for templates
if [ -d "$SKILL_DIR/templates" ]; then
    template_count=$(find "$SKILL_DIR/templates" -type f | wc -l | tr -d ' ')
    echo "[OK] Templates directory exists ($template_count files)"
else
    echo "[INFO] No templates directory"
fi

# Check for tests
if [ -d "$SKILL_DIR/tests" ]; then
    echo "[OK] Tests directory exists"
    if [ -f "$SKILL_DIR/tests/scenarios.md" ]; then
        echo "[OK] scenarios.md exists"
    else
        echo "[WARN] scenarios.md missing (needed for /test-skill)"
    fi
else
    echo "[INFO] No tests directory"
fi

echo ""
echo "=== Skill Content Preview ==="
head -50 "$SKILL_DIR/SKILL.md"
echo ""
echo "..."
echo ""
echo "=== Test Complete ==="
