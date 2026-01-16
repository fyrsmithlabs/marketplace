# Marketplace

![Build](https://github.com/fyrsmithlabs/marketplace/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Gitleaks](https://img.shields.io/badge/gitleaks-enabled-blue)

A Claude Code plugin providing skills, commands, and agents for fyrsmithlabs project standards and workflows.

## Overview

This plugin provides:
- **Repository Standards** - Naming conventions, structure, documentation requirements
- **Git Workflows** - Multi-agent consensus review, PR requirements, branching strategy
- **Project Init** - Set up projects to follow fyrsmithlabs standards
- **YAGNI/KISS Enforcement** - Humorous nudges against over-engineering
- **Complexity Assessment** - Right-size workflows based on task complexity
- **GitHub Planning** - Native GitHub Issues/Projects instead of local markdown
- **Roadmap Discovery** - Autonomous codebase analysis for improvements

## Prerequisites

- Claude Code CLI
- contextd MCP server (see [contextd Setup](#contextd-setup))
- GitHub CLI (`gh`) for planning features

## Structure

```
marketplace/
├── .claude-plugin/           # Plugin manifest
├── commands/                 # Slash commands
│   ├── init.md           # /init command
│   ├── yagni.md        # /yagni command
│   ├── brainstorm.md        # /brainstorm command
│   ├── plan.md              # /plan command
│   ├── discover.md          # /discover command
│   ├── test-skill.md        # /test-skill command
│   ├── comp-analysis.md     # /comp-analysis command
│   ├── spec-refinement.md   # /spec-refinement command
│   └── app-interview.md     # /app-interview command
├── agents/                   # Subagents
├── skills/
│   ├── git-repo-standards/  # Repo standards skill
│   ├── git-workflows/       # Workflow skill
│   ├── init/  # Onboarding skill
│   ├── yagni/          # YAGNI/KISS enforcement
│   ├── complexity-assessment/ # Task complexity evaluation
│   ├── github-planning/     # GitHub Issues/Projects
│   └── roadmap-discovery/   # Codebase analysis
├── includes/                 # Shared hook includes
│   └── yagni/          # Pattern detection templates
└── hooks/
    └── hooks.json           # Enforcement hooks
```

## Skills

| Skill | Description |
|-------|-------------|
| `git-repo-standards` | Repository naming, structure, README, CHANGELOG, LICENSE, gitleaks |
| `git-workflows` | 5-agent consensus review, PR requirements, trunk-based branching |
| `init` | Set up projects to follow fyrsmithlabs standards |
| `yagni` | YAGNI/KISS enforcement with humorous archetype nudges |
| `complexity-assessment` | Assess task complexity (SIMPLE/STANDARD/COMPLEX) across 5 dimensions |
| `github-planning` | Create tier-appropriate GitHub Issues, epics, and project boards |
| `roadmap-discovery` | Autonomous codebase analysis with lens filtering (security, quality, perf, docs) |

## Commands

| Command | Description |
|---------|-------------|
| `/init` | Set up project to follow fyrsmithlabs standards |
| `/init --check` | Audit compliance without changes |
| `/yagni` | Manage YAGNI/KISS enforcement settings |
| `/brainstorm` | Interactive design interview with complexity-aware questioning |
| `/plan` | Full planning workflow - assess, brainstorm, create GitHub Issues |
| `/discover` | Run codebase discovery with optional lens filtering |
| `/test-skill` | Run pressure test scenarios against marketplace skills |
| `/comp-analysis` | Generate executive summary of competitor analysis |
| `/spec-refinement` | Deep-dive interview to refine specification documents |
| `/app-interview` | Comprehensive app ideation with competitor analysis |

## Installation

Add to your Claude Code plugins or install via the marketplace.

## Usage

```bash
# Set up project to follow fyrsmithlabs standards
/init

# Check compliance only (no changes)
/init --check

# Plan a new feature (full workflow)
/plan "add user authentication"

# Interactive design session
/brainstorm "plugin search feature"

# Run codebase discovery
/discover --lens security

# Refine a spec document
/spec-refinement path/to/spec.md

# Start app ideation interview
/app-interview
```

## contextd Setup

This plugin requires the contextd MCP server for cross-session memory, learning, and context management.

### Installation

```bash
# Install contextd (check fyrsmithlabs/contextd for latest)
go install github.com/fyrsmithlabs/contextd@latest
```

### Configuration

Copy the example MCP configuration to your project or home directory:

```bash
cp .mcp.json.example ~/.mcp.json
```

Or add contextd to your existing `.mcp.json`:

```json
{
  "mcpServers": {
    "contextd": {
      "type": "stdio",
      "command": "contextd",
      "args": ["serve"],
      "env": {
        "CONTEXTD_DATA_DIR": "${HOME}/.contextd"
      }
    }
  }
}
```

### contextd Integration

This plugin integrates deeply with contextd:

| Feature | Tools | Purpose |
|---------|-------|---------|
| Cross-session learning | `memory_search`, `memory_record` | Remember strategies that worked |
| Error remediation | `remediation_search`, `remediation_record` | Track error fixes across sessions |
| Context folding | `branch_create`, `branch_return` | Isolate sub-tasks with token budgets |
| State preservation | `checkpoint_save`, `checkpoint_resume` | Resume interrupted work |
| Semantic search | `semantic_search`, `repository_index` | Smart codebase search |
| Self-reflection | `reflect_analyze`, `reflect_report` | Identify behavioral patterns |

## License

Apache-2.0
