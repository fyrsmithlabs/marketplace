# Marketplace

![Version](https://img.shields.io/badge/version-1.7.0-green)
![Build](https://github.com/fyrsmithlabs/marketplace/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Gitleaks](https://img.shields.io/badge/gitleaks-enabled-blue)

A Claude Code plugin marketplace providing skills, commands, and agents for fyrsmithlabs project standards and workflows.

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
/init

# Run a brainstorm session for a new feature
/brainstorm "Add user authentication"

# Check your daily standup
/standup

# Run multi-agent code review
/consensus-review
```

---

## Plugins

This marketplace contains three plugins that can be installed independently:

| Plugin | Version | Components | Purpose |
|--------|---------|------------|---------|
| [fs-dev](docs/plugins/fs-dev.md) | 1.6.8 | 10 skills, 7 agents, 11 commands | Development standards, workflows, planning |
| [contextd](docs/plugins/contextd.md) | 1.1.0 | 6 skills, 2 agents, 10 commands | Cross-session memory via MCP |
| [fs-design](docs/plugins/fs-design.md) | 1.0.0 | 1 skill, 2 agents, 1 command | Design system compliance |

---

## Featured Commands

### /init - Project Setup

Set up a project to follow fyrsmithlabs standards with interactive wizard, auto-detection, and compliance checking.

```bash
# Full interactive wizard
/init

# Audit compliance without making changes
/init --check

# Quick setup (skip wizard)
/init --quick

# Check for drift from standards
/init --validate
```

### /brainstorm - Feature Design

Interactive design interview with complexity assessment, requirements gathering, and GitHub planning.

```bash
# Start a brainstorm session
/brainstorm "Add OAuth support"

# Brainstorm creates GitHub Issues automatically in Phase 6
```

### /consensus-review - Multi-Agent Code Review

Run parallel code review with 6 specialized agents. All agents have veto power by default. Features adaptive token budgets, context-folding isolation for large scopes, and progressive summarization.

```bash
# Review staged changes
/consensus-review

# Review specific path
/consensus-review src/auth/

# Ignore veto power (advisory only)
/consensus-review --ignore-vetos

# Run subset of agents
/consensus-review --agents security,code-quality,go
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
/brainstorm "Add user authentication"

# 2. Create GitHub issues (automatic from brainstorm Phase 6)
# or manually:
/plan "Add user authentication"

# 3. Code implementation...

# 4. Multi-agent code review
/consensus-review

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
/discover

# Security-focused analysis
/discover --lens security

# Performance-focused analysis
/discover --lens performance
```

### Daily Standup

```bash
# Today's status with GitHub PR/Issue synthesis
/standup

# Weekly summary
/standup --week
```

---

## Prerequisites

- **Claude Code CLI** - Required for all plugins
- **GitHub CLI (`gh`)** - Required for planning features
- **contextd MCP server** - Required for contextd plugin (see [contextd Setup](#contextd-setup))

---

## Structure

```
marketplace/
├── .claude-plugin/           # Plugin manifests (plugin.json, marketplace.json)
├── commands/                 # Slash commands (22 total)
├── agents/                   # Subagents (9 total)
├── skills/                   # Skills (17 total)
├── plugins/                  # Additional plugins
│   ├── contextd/             # Cross-session memory plugin
│   └── fs-design/            # Design system plugin
├── includes/                 # Shared includes
├── hooks/                    # Claude Code hooks
└── docs/                     # Documentation
    └── plugins/              # Plugin-specific docs
```

---

## contextd Setup

The contextd plugin requires the contextd MCP server for cross-session memory and learning.

### Installation

```bash
# Install contextd (check fyrsmithlabs/contextd for latest)
go install github.com/fyrsmithlabs/contextd@latest
```

### Configuration

Add contextd to your `.mcp.json`:

```json
{
  "mcpServers": {
    "contextd": {
      "type": "stdio",
      "command": "contextd",
      "args": ["--mcp", "--no-http"]
    }
  }
}
```

### contextd Features

| Feature | Tools | Purpose |
|---------|-------|---------|
| Cross-session learning | `memory_search`, `memory_record` | Remember strategies that worked |
| Error remediation | `remediation_search`, `remediation_record` | Track error fixes across sessions |
| Context folding | `branch_create`, `branch_return` | Isolate sub-tasks with token budgets |
| State preservation | `checkpoint_save`, `checkpoint_resume` | Resume interrupted work |
| Semantic search | `semantic_search`, `repository_index` | Smart codebase search |
| Self-reflection | `reflect_analyze`, `reflect_report` | Identify behavioral patterns |

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
| `/init` | Set up project to follow fyrsmithlabs standards |
| `/yagni` | Manage YAGNI/KISS enforcement settings |
| `/brainstorm` | Interactive design interview with complexity-aware questioning |
| `/plan` | Full planning workflow - assess, brainstorm, create GitHub Issues |
| `/discover` | Run codebase discovery with optional lens filtering |
| `/standup` | Daily standup with GitHub PR/Issue synthesis |
| `/consensus-review` | Multi-agent code review with veto power |
| `/test-skill` | Run pressure test scenarios against marketplace skills |
| `/comp-analysis` | Generate executive summary of competitor analysis |
| `/spec-refinement` | Deep-dive interview to refine specification documents |
| `/app-interview` | Comprehensive app ideation with competitor analysis |

### contextd Commands

| Command | Purpose |
|---------|---------|
| `/contextd:search` | Semantic search across memories, remediations, and code |
| `/contextd:remember` | Record a learning or insight from the current session |
| `/contextd:checkpoint` | Save session state (accomplishments, in-progress, next steps) |
| `/contextd:diagnose` | Diagnose errors using AI analysis and past fixes |
| `/contextd:status` | Show contextd status for current session and project |
| `/contextd:init` | Initialize contextd for a project (CLAUDE.md, indexing) |
| `/contextd:reflect` | Analyze memories for behavior patterns and policy compliance |
| `/contextd:consensus-review` | Run multi-agent consensus review on files/directories |
| `/contextd:orchestrate` | Execute multi-task orchestration from GitHub issues |
| `/contextd:help` | List all available contextd skills and commands |

### Design Commands (fs-design)

| Command | Purpose |
|---------|---------|
| `/fs-design:check` | Audit files for Terminal Elegance design system compliance |

---

## License

Apache-2.0
