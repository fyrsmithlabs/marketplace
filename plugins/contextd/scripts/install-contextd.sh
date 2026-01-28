#!/bin/bash
# install-contextd.sh - Setup hook for installing contextd
# Triggered by: claude --init or claude --init-only

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[contextd]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[contextd]${NC} $1"; }
log_error() { echo -e "${RED}[contextd]${NC} $1" >&2; }

# Check if contextd is already installed
if command -v contextd &> /dev/null; then
    VERSION=$(contextd --version 2>/dev/null || echo "unknown")
    log_info "contextd already installed: $VERSION"

    # Run MCP install to ensure configuration is up to date
    if command -v ctxd &> /dev/null; then
        log_info "Verifying MCP configuration..."
        ctxd mcp install --quiet 2>/dev/null || true
    fi
    exit 0
fi

log_info "contextd not found, attempting installation..."

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Normalize architecture
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) log_error "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Try Homebrew first (macOS/Linux)
if command -v brew &> /dev/null; then
    log_info "Installing via Homebrew..."
    if brew tap fyrsmithlabs/contextd https://github.com/fyrsmithlabs/contextd 2>/dev/null; then
        if brew install contextd 2>/dev/null; then
            log_info "Successfully installed contextd via Homebrew"

            # Configure MCP
            if command -v ctxd &> /dev/null; then
                log_info "Configuring MCP server..."
                ctxd mcp install 2>/dev/null || true
            fi
            exit 0
        fi
    fi
    log_warn "Homebrew installation failed, trying binary download..."
fi

# Fallback: Download binary from GitHub releases
log_info "Downloading latest release from GitHub..."

# Get latest release version
LATEST=$(curl -sL "https://api.github.com/repos/fyrsmithlabs/contextd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$LATEST" ]; then
    log_error "Failed to get latest release version"
    exit 1
fi

log_info "Latest version: $LATEST"

# Construct download URL
FILENAME="contextd_${LATEST#v}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/fyrsmithlabs/contextd/releases/download/${LATEST}/${FILENAME}"

# Create temp directory
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Download
log_info "Downloading $URL..."
if ! curl -sL "$URL" -o "$TMPDIR/contextd.tar.gz"; then
    log_error "Failed to download contextd"
    exit 1
fi

# Extract
log_info "Extracting..."
tar xzf "$TMPDIR/contextd.tar.gz" -C "$TMPDIR"

# Install to ~/.local/bin
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

if [ -f "$TMPDIR/contextd" ]; then
    mv "$TMPDIR/contextd" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/contextd"
fi

if [ -f "$TMPDIR/ctxd" ]; then
    mv "$TMPDIR/ctxd" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/ctxd"
fi

log_info "Installed to $INSTALL_DIR"

# Add to PATH if needed (for current session)
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    export PATH="$INSTALL_DIR:$PATH"
    log_warn "Added $INSTALL_DIR to PATH for this session"
    log_warn "Add 'export PATH=\"\$HOME/.local/bin:\$PATH\"' to your shell profile for persistence"
fi

# Verify installation
if command -v contextd &> /dev/null; then
    VERSION=$(contextd --version 2>/dev/null || echo "installed")
    log_info "Successfully installed contextd: $VERSION"

    # Configure MCP
    if command -v ctxd &> /dev/null; then
        log_info "Configuring MCP server..."
        ctxd mcp install 2>/dev/null || true
    fi
else
    log_error "Installation completed but contextd not found in PATH"
    log_error "Try restarting your terminal or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
fi

exit 0
