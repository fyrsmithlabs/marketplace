# Marketplace

![Version](https://img.shields.io/badge/version-1.9.1-green)
![Build](https://github.com/fyrsmithlabs/marketplace/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Gitleaks](https://img.shields.io/badge/gitleaks-enabled-blue)

A Claude Code plugin marketplace providing skills, commands, and agents for fyrsmithlabs project standards and workflows.

---

## Prerequisites

Before installing, ensure you have:

- **Claude Code CLI** - Required for all plugins
- **GitHub CLI (`gh`) 2.0+** - Required for planning features ([install](https://cli.github.com/))
- **contextd MCP server** - Required for contextd plugin (see [contextd Setup](#contextd-setup))

---

## Quick Start

### Installation

Add the marketplace to your Claude Code settings:

```bash
# Install via Claude Code plugin marketplace
claude plugin install fyrsmithlabs/marketplace
```

### First Commands to Try

```bash
# Initialize a project with standards
/fs-dev:init

# Run a brainstorm session for a new feature
/fs-dev:brainstorm "Add user authentication"

# Check your daily standup
/fs-dev:standup

# Run multi-agent code review
/fs-dev:consensus-review
```

---

## Plugins

This marketplace contains three plugins that can be installed independently:

| Plugin | Version | Components | Purpose |
|--------|---------|------------|---------|
| [fs-dev](docs/plugins/fs-dev.md) | 1.9.1 | 13 skills, 15 agents, 12 commands | Development standards, workflows, planning |
| [contextd](docs/plugins/contextd.md) | 1.2.0 | 5 skills, 2 agents, 8 commands | Cross-session memory via MCP |
| [fs-design](docs/plugins/fs-design.md) | 1.0.0 | 1 skill, 2 agents, 1 command | Design system compliance |

---

## Featured Commands

### /fs-dev:init - Project Setup

Set up a project to follow fyrsmithlabs standards with interactive wizard, auto-detection, and compliance checking.

```bash
# Full interactive wizard
/fs-dev:init

# Audit compliance without making changes
/fs-dev:init --check

# Quick setup (skip wizard)
/fs-dev:init --quick

# Check for drift from standards
/fs-dev:init --validate
```

### /fs-dev:brainstorm - Feature Design

Interactive design interview with complexity assessment, requirements gathering, and GitHub planning.

```bash
# Start a brainstorm session
/fs-dev:brainstorm "Add OAuth support"

# Brainstorm creates GitHub Issues automatically in Phase 6
```

### /fs-dev:consensus-review - Multi-Agent Code Review

Run parallel code review with 6 specialized agents. All agents have veto power by default. Features adaptive token budgets, context-folding isolation for large scopes, and progressive summarization.

```bash
# Review staged changes
/fs-dev:consensus-review

# Review specific path
/fs-dev:consensus-review src/auth/

# Ignore veto power (advisory only)
/fs-dev:consensus-review --ignore-vetos

# Run subset of agents
/fs-dev:consensus-review --agents security,code-quality,go
```

### /contextd:checkpoint - Session State Management

Save your session state for later resumption. Essential before clearing context or ending a session.

```bash
# Save current session state
/contextd:checkpoint

# Checkpoints capture:
# - Accomplishments
# - In-progress work
# - Next steps
```

### /fs-design:check - Design Compliance Audit

Audit CSS, templates, and documentation for Terminal Elegance design system compliance.

```bash
# Scan default locations
/fs-design:check

# Check specific file
/fs-design:check static/css/main.css

# Check directory
/fs-design:check internal/templates/
```

---

## Common Workflows

### New Feature Development

```bash
# 1. Design the feature
/fs-dev:brainstorm "Add user authentication"

# 2. Create GitHub issues (automatic from brainstorm Phase 6)
# or manually:
/fs-dev:plan "Add user authentication"

# 3. Code implementation...

# 4. Multi-agent code review
/fs-dev:consensus-review

# 5. Commit with standards
git commit -m "feat: add user authentication"
```

### Session Management (with contextd)

```bash
# 1. Check current state
/contextd:status

# 2. Search for relevant past learnings
/contextd:search authentication patterns

# 3. Work on tasks...

# 4. Save progress before clearing context
/contextd:checkpoint

# 5. Record what you learned
/contextd:remember
```

### Codebase Discovery

```bash
# Full codebase analysis
/fs-dev:discover

# Security-focused analysis
/fs-dev:discover --lens security

# Performance-focused analysis
/fs-dev:discover --lens performance
```

### Daily Standup

```bash
# Today's status with GitHub PR/Issue synthesis
/fs-dev:standup

# Weekly summary
/fs-dev:standup --week
```

---

## Structure

```
marketplace/
├── .claude-plugin/           # Root marketplace manifest
├── plugins/                  # All plugins
│   ├── fs-dev/               # Core development plugin (13 skills, 15 agents, 12 commands)
│   ├── contextd/             # Cross-session memory plugin (5 skills, 2 agents, 8 commands)
│   └── fs-design/            # Design system plugin (1 skill, 2 agents, 1 command)
├── hooks/                    # Claude Code hooks (PreCompact only)
└── docs/                     # Documentation
    └── plugins/              # Plugin-specific docs
```

---

## contextd Setup

> **⚠️ REQUIRED:** The contextd plugin requires the contextd MCP server.
> Without it, all `/contextd:*` commands will fail. Setup takes ~2 minutes.

### Option A: Homebrew (macOS/Linux)

```bash
brew tap fyrsmithlabs/contextd https://github.com/fyrsmithlabs/contextd
brew install contextd
ctxd mcp install
# Restart Claude Code, then: /contextd:status
```

### Option B: Direct Download

Download from [GitHub Releases](https://github.com/fyrsmithlabs/contextd/releases), then:

```bash
tar xzf contextd_*.tar.gz
sudo mv contextd /usr/local/bin/
ctxd mcp install
# Restart Claude Code, then: /contextd:status
```

> **Note:** On first run, contextd auto-downloads ONNX runtime (~100MB). This is one-time only.

### Troubleshooting

| Error | Fix |
|-------|-----|
| `Unknown tool: mcp__contextd__*` | Run `ctxd mcp install` and restart Claude Code |
| `contextd: command not found` | Install via Homebrew or `go install` |
| Connection errors | Run `ctxd mcp status` to diagnose |

**Full documentation:** [contextd Plugin Guide](docs/plugins/contextd.md)

---

## Documentation

- **Plugin Documentation**
  - [fs-dev Plugin](docs/plugins/fs-dev.md) - Development standards and workflows
  - [contextd Plugin](docs/plugins/contextd.md) - Cross-session memory
  - [fs-design Plugin](docs/plugins/fs-design.md) - Design system compliance

- **Project Documentation**
  - [CHANGELOG](CHANGELOG.md) - Version history and release notes
  - [LICENSE](LICENSE) - Apache-2.0 license

---

## All Commands Reference

### Core Commands (fs-dev)

| Command | Purpose |
|---------|---------|
| `/fs-dev:init` | Set up project to follow fyrsmithlabs standards |
| `/fs-dev:yagni` | Manage YAGNI/KISS enforcement settings |
| `/fs-dev:brainstorm` | Interactive design interview with complexity-aware questioning |
| `/fs-dev:plan` | Full planning workflow - assess, brainstorm, create GitHub Issues |
| `/fs-dev:discover` | Run codebase discovery with optional lens filtering |
| `/fs-dev:standup` | Daily standup with GitHub PR/Issue synthesis |
| `/fs-dev:consensus-review` | Multi-agent code review with veto power |
| `/fs-dev:test-skill` | Run pressure test scenarios against marketplace skills |
| `/fs-dev:comp-analysis` | Generate executive summary of competitor analysis |
| `/fs-dev:spec-refinement` | Deep-dive interview to refine specification documents |
| `/fs-dev:app-interview` | Comprehensive app ideation with competitor analysis |

### contextd Commands

| Command | Purpose |
|---------|---------|
| `/contextd:search` | Semantic search across memories, remediations, and code |
| `/contextd:remember` | Record a learning or insight from the current session |
| `/contextd:checkpoint` | Save session state (accomplishments, in-progress, next steps) |
| `/contextd:diagnose` | Diagnose errors using AI analysis and past fixes |
| `/contextd:status` | Show contextd status for current session and project |
| `/contextd:reflect` | Analyze memories for behavior patterns and policy compliance |
| `/contextd:orchestrate` | Execute multi-task orchestration from GitHub issues |
| `/contextd:help` | List all available contextd skills and commands |

### Design Commands (fs-design)

| Command | Purpose |
|---------|---------|
| `/fs-design:check` | Audit files for Terminal Elegance design system compliance |

---

## License

Apache-2.0
