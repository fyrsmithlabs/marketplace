# Marketplace

![Version](https://img.shields.io/badge/version-1.3.0-green)
![Build](https://github.com/fyrsmithlabs/marketplace/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Gitleaks](https://img.shields.io/badge/gitleaks-enabled-blue)

A Claude Code plugin providing skills, commands, and agents for fyrsmithlabs project standards and workflows.

## Overview

This plugin provides:
- **Repository Standards** - Naming conventions, structure, documentation requirements
- **Git Workflows** - Multi-agent consensus review, PR requirements, branching strategy
- **Project Init** - Set up projects to follow fyrsmithlabs standards
- **YAGNI/KISS Enforcement** - Structured nudges against over-engineering
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
├── .claude-plugin/           # Plugin manifests (plugin.json, marketplace.json)
├── commands/                 # Slash commands (18 total)
│   ├── init.md               # /init - project setup
│   ├── yagni.md              # /yagni - YAGNI settings
│   ├── brainstorm.md         # /brainstorm - design interview
│   ├── plan.md               # /plan - planning workflow
│   ├── discover.md           # /discover - codebase discovery
│   ├── test-skill.md         # /test-skill - pressure tests
│   ├── contextd-*.md         # 9 contextd commands
│   └── ...
├── agents/                   # Subagents (7 total)
│   ├── security-reviewer.md
│   ├── vulnerability-reviewer.md
│   ├── code-quality-reviewer.md
│   ├── documentation-reviewer.md
│   ├── user-persona-reviewer.md
│   ├── contextd-task-agent.md
│   └── contextd-orchestrator.md
├── skills/                   # Skills (13 total)
│   ├── git-repo-standards/   # Repo naming, structure, docs
│   ├── git-workflows/        # Consensus review, PRs, branching
│   ├── init/                 # Project setup
│   ├── yagni/                # YAGNI/KISS enforcement
│   ├── complexity-assessment/
│   ├── github-planning/
│   ├── roadmap-discovery/
│   └── contextd-*/           # 6 contextd skills
├── includes/                 # Shared includes
│   └── yagni/                # Pattern detection
└── hooks/
    └── hooks.json            # Enforcement hooks
```

## Skills

### Core Skills

| Skill | Description |
|-------|-------------|
| `git-repo-standards` | Repository naming, structure, README, CHANGELOG, LICENSE, gitleaks |
| `git-workflows` | 5-agent consensus review, PR requirements, trunk-based branching |
| `init` | Set up projects to follow fyrsmithlabs standards |
| `yagni` | YAGNI/KISS enforcement with structured nudges |
| `complexity-assessment` | Assess task complexity (SIMPLE/STANDARD/COMPLEX) across 5 dimensions |
| `github-planning` | Create tier-appropriate GitHub Issues, epics, and project boards |
| `roadmap-discovery` | Autonomous codebase analysis with lens filtering (security, quality, perf, docs) |

### contextd Skills

| Skill | Description |
|-------|-------------|
| `using-contextd` | Core tools for cross-session memory, semantic search, and error remediation |
| `context-folding` | Create context-isolated branches with token budgets for sub-tasks |
| `contextd-setup` | Codebase analysis, CLAUDE.md generation, policy management |
| `contextd-workflow` | Session lifecycle - start/end protocols, checkpoints, error remediation |
| `contextd-consensus-review` | Multi-agent parallel review with Security, Correctness, Architecture, UX agents |
| `contextd-self-reflection` | Mine memories for poor behaviors, pressure-test CLAUDE.md improvements |

## Agents

| Agent | Description | Veto Power |
|-------|-------------|------------|
| `security-reviewer` | Injection, auth, secrets, OWASP Top 10 | Yes |
| `vulnerability-reviewer` | CVEs, dependencies, supply chain | Yes |
| `code-quality-reviewer` | Logic, complexity, patterns, tests | No |
| `documentation-reviewer` | README, comments, API docs, CHANGELOG | No |
| `user-persona-reviewer` | UX impact, breaking changes, API ergonomics | No |
| `contextd-task-agent` | Debugging, refactoring, architecture analysis | N/A |
| `contextd-orchestrator` | Multi-agent workflows with context folding | N/A |

## Commands

### Core Commands

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

### contextd Commands

| Command | Description |
|---------|-------------|
| `/contextd-search` | Semantic search across memories, remediations, and indexed code |
| `/contextd-remember` | Record a learning or insight from the current session |
| `/contextd-checkpoint` | Save session state (accomplishments, in-progress, next steps) |
| `/contextd-diagnose` | Diagnose errors using AI analysis and past fixes |
| `/contextd-status` | Show contextd status for current session and project |
| `/contextd-init` | Initialize contextd for a project (CLAUDE.md, indexing) |
| `/contextd-reflect` | Analyze memories for behavior patterns and policy compliance |
| `/contextd-consensus-review` | Run multi-agent consensus review on files/directories |
| `/contextd-help` | List all available contextd skills and commands |

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
