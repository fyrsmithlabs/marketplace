#!/bin/bash
set -e

echo "=== Marketplace Plugin Dev Container Setup ==="

# Install Claude CLI
echo "Installing Claude CLI..."
npm install -g @anthropic-ai/claude-code

# Install jq for JSON parsing
echo "Installing dependencies..."
sudo apt-get update -qq && sudo apt-get install -y -qq jq

# Create Claude config directory
mkdir -p ~/.config/claude-code

# Link the marketplace plugin for development
echo "Linking marketplace plugin..."
PLUGIN_PATH="/workspaces/marketplace"

# Create plugins directory and symlink
mkdir -p ~/.config/claude-code/plugins
ln -sf "$PLUGIN_PATH" ~/.config/claude-code/plugins/fyrsmithlabs-marketplace

# Create CLI settings to enable the plugin
cat > ~/.config/claude-code/settings.json << 'EOF'
{
  "plugins": {
    "fyrsmithlabs-marketplace": {
      "enabled": true,
      "path": "/workspaces/marketplace"
    }
  }
}
EOF

# Create symlinks for validation scripts
echo "Setting up validation commands..."
mkdir -p ~/.local/bin
ln -sf "$PLUGIN_PATH/.devcontainer/scripts/validate-plugin.sh" ~/.local/bin/validate-plugin
ln -sf "$PLUGIN_PATH/.devcontainer/scripts/test-skill.sh" ~/.local/bin/test-skill
ln -sf "$PLUGIN_PATH/.devcontainer/scripts/list-components.sh" ~/.local/bin/list-components

# Add to PATH if not already
if ! grep -q '~/.local/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$HOME/.local/bin:$PATH"

# Create a test project directory for validation
mkdir -p /workspaces/test-project
cd /workspaces/test-project
git init --initial-branch=main 2>/dev/null || git init
git config user.email "dev@test.local"
git config user.name "Dev Container"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Available commands:"
echo "  validate-plugin    - Validate plugin structure"
echo "  test-skill <name>  - Test a specific skill"
echo "  list-components    - List all plugin components"
echo "  claude             - Run Claude CLI with plugin loaded"
echo ""
echo "Plugin linked at: ~/.config/claude-code/plugins/fyrsmithlabs-marketplace"
echo "Test project at: /workspaces/test-project"
echo ""
echo "Quick start:"
echo "  cd /workspaces/test-project"
echo "  claude  # Start Claude with marketplace plugin"
