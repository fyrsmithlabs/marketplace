#!/bin/bash
set -e

echo "=== Plugin Validation ==="

echo -e "\n--- fs-dev plugin ---"
claude plugin validate /home/testuser/marketplace/.claude-plugin/marketplace.json

echo -e "\n--- contextd plugin ---"
claude plugin validate /home/testuser/marketplace/plugins/contextd/.claude-plugin/plugin.json

echo -e "\n--- fs-design plugin ---"
claude plugin validate /home/testuser/marketplace/plugins/fs-design/.claude-plugin/plugin.json

echo -e "\n=== MCP Configuration Check ==="
if [ -f /home/testuser/marketplace/plugins/contextd/.mcp.json ]; then
    echo "✓ contextd .mcp.json present"
    jq . /home/testuser/marketplace/plugins/contextd/.mcp.json
else
    echo "✗ contextd .mcp.json missing"
    exit 1
fi

echo -e "\n=== Hook Configuration Check ==="
for hook_file in /home/testuser/marketplace/hooks/hooks.json /home/testuser/marketplace/plugins/contextd/hooks/hooks.json; do
    if [ -f "$hook_file" ]; then
        echo "✓ Found: $hook_file"
        jq '.hooks | keys' "$hook_file" 2>/dev/null || jq 'keys' "$hook_file"
    fi
done

echo -e "\n=== Script Permissions Check ==="
for script in /home/testuser/marketplace/plugins/contextd/scripts/*.sh; do
    if [ -x "$script" ]; then
        echo "✓ Executable: $(basename $script)"
    else
        echo "✗ Not executable: $(basename $script)"
        exit 1
    fi
done

echo -e "\n=== Loading Plugins (dry run) ==="
echo "Testing plugin loading with --plugin-dir..."
claude --plugin-dir /home/testuser/marketplace --version

echo -e "\n=== All Validation Tests Passed ==="
