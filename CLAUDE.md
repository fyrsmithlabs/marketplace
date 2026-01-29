# CLAUDE.md - Marketplace

**Status**: Active Development
**Version**: 1.7.0
**Last Updated**: 2026-01-29

---

## Critical Rules

**ALWAYS** follow Claude Code plugin conventions
**ALWAYS** apply git-repo-standards and git-workflows skills to projects
**NEVER** commit credentials or API keys to the repository
**OPTIONAL** use contextd for cross-session memory (if MCP server available)

---

## Project Overview

A Claude Code plugin marketplace providing skills, commands, and agents for fyrsmithlabs project standards and workflows. Contains multiple plugins that can be installed independently.

## Architecture

```
marketplace/
├── .claude-plugin/      # Root marketplace manifest
│   └── marketplace.json # Multi-plugin registry (strict: false)
├── commands/            # 11 slash commands (core workflow)
├── agents/              # 7 subagents (6 reviewers + 1 product-owner)
├── skills/              # 10 skills (standards, workflows, planning)
│   ├── git-repo-standards/    # Repo naming, structure, docs
│   ├── git-workflows/         # Consensus review, PRs, branching
│   ├── init/                  # Project setup
│   ├── yagni/                 # YAGNI/KISS enforcement
│   ├── complexity-assessment/ # Task complexity
│   ├── github-planning/       # GitHub Issues/Projects
│   ├── roadmap-discovery/     # Codebase analysis
│   ├── product-owner/         # Standups, priorities
│   └── context-folding/       # Context isolation
├── plugins/             # Additional plugins
│   ├── contextd/              # Cross-session memory plugin
│   │   ├── .claude-plugin/    # Plugin manifest
│   │   ├── agents/            # 2 contextd agents
│   │   ├── skills/            # 6 contextd skills
│   │   └── commands/          # 10 contextd commands
│   └── fs-design/     # Design system plugin
│       ├── .claude-plugin/    # Plugin manifest
│       ├── agents/            # 2 design agents
│       ├── skills/            # 1 skill (design-check)
│       └── commands/          # 1 command (/design-check)
├── includes/            # Shared includes for hooks
│   └── yagni/           # Pattern detection
└── hooks/               # Claude Code hooks
    └── hooks.json       # Enforcement hooks
```

## Plugins

This marketplace contains three plugins:

| Plugin | Version | Category | Description |
|--------|---------|----------|-------------|
| `fs-dev` | v1.6.8 | development | Core standards, workflows, planning |
| `contextd` | v1.1.0 | memory | Cross-session memory and learning |
| `fs-design` | v1.0.0 | design | Design system compliance |

---

## fs-dev Plugin

Core development standards, workflows, and GitHub integration.

### Core Skills

| Skill | Purpose |
|-------|---------|
| `git-repo-standards` | Repository naming, structure, README, CHANGELOG, LICENSE, gitleaks |
| `git-workflows` | Multi-agent consensus review, PR requirements, branching |
| `init` | Set up projects to follow fyrsmithlabs standards |
| `yagni` | YAGNI/KISS enforcement with structured nudges |
| `complexity-assessment` | Task complexity evaluation (SIMPLE/STANDARD/COMPLEX) |
| `github-planning` | GitHub Issues/Projects integration |
| `roadmap-discovery` | Codebase analysis with lens filtering |
| `product-owner` | Daily standups, priority synthesis, cross-project dependencies |
| `context-folding` | Context isolation for complex sub-tasks |
| `effective-go` | Idiomatic Go development based on Effective Go |

### Review Agents

| Agent | Focus | Veto |
|-------|-------|------|
| `security-reviewer` | Injection, auth, secrets, OWASP | Yes |
| `vulnerability-reviewer` | CVEs, deps, supply chain | Yes |
| `code-quality-reviewer` | Logic, complexity, patterns | Yes |
| `documentation-reviewer` | README, API docs, CHANGELOG | Yes |
| `user-persona-reviewer` | UX, breaking changes, ergonomics | Yes |
| `go-reviewer` | Effective Go, concurrency, error handling | Yes |

### Other Agents

| Agent | Purpose |
|-------|---------|
| `product-owner` | Priority analysis, cross-project dependencies, strategic recommendations |

### Key Commands

| Command | Purpose |
|---------|---------|
| `/init` | Set up project standards |
| `/yagni` | Manage YAGNI settings |
| `/plan` | Full planning workflow |
| `/standup` | Daily standup with GitHub synthesis |
| `/test-skill` | Run pressure tests |
| `/discover` | Codebase analysis |
| `/brainstorm` | Feature design workflow |
| `/consensus-review` | Multi-agent code review with veto power |

---

## contextd Plugin

Cross-session memory and learning via the contextd MCP server.

### Skills

| Skill | Purpose |
|-------|---------|
| `contextd:using-contextd` | Core tools introduction |
| `contextd:setup` | Project onboarding and CLAUDE.md management |
| `contextd:workflow` | Session lifecycle management |
| `contextd:consensus-review` | Multi-agent parallel review |
| `contextd:orchestration` | Multi-task execution with parallel agents |
| `contextd:self-reflection` | Behavior pattern analysis |

### Agents

| Agent | Purpose |
|-------|---------|
| `contextd:task-agent` | Unified debugging, refactoring, architecture analysis |
| `contextd:orchestrator` | Multi-agent workflow with context-folding |

### Commands

| Command | Purpose |
|---------|---------|
| `/contextd:search` | Semantic search across memories |
| `/contextd:remember` | Record learnings from session |
| `/contextd:checkpoint` | Save session state |
| `/contextd:diagnose` | Error analysis with AI |
| `/contextd:status` | Show contextd status |
| `/contextd:init` | Initialize contextd for project |
| `/contextd:reflect` | Analyze patterns, improve policies |
| `/contextd:consensus-review` | Multi-agent code review |
| `/contextd:orchestrate` | Execute multi-task orchestration plans |
| `/contextd:help` | List available commands |

---

## fs-design Plugin

Terminal Elegance design system compliance checking.

### Skills

| Skill | Purpose |
|-------|---------|
| `fs-design:check` | Design system compliance checking and reporting |

### Agents

| Agent | Purpose |
|-------|---------|
| `fs-design:consistency-reviewer` | Audit files for design system compliance |
| `fs-design:task-executor` | Execute design system refactoring |

### Commands

| Command | Purpose |
|---------|---------|
| `/fs-design:check [path]` | Audit files for design system violations |

### Capabilities

- Reports hardcoded colors, spacing, fonts, z-index values
- Checks accessibility (alt text, ARIA labels, focus states)
- Validates brand name consistency in documentation
- Report-only tool, does not auto-fix issues

---

## Code Standards

- Plugin artifacts follow Claude Code conventions
- Use kebab-case for all component names
- Skills can optionally integrate with contextd (memory, remediation, checkpoints)
- Templates go in `skills/<skill-name>/templates/`
- Agents output structured JSON for consensus review integration

## Known Pitfalls

- **Hook prompts are LLM instructions, not executable code** - Variables in hooks/templates (e.g., `{{filename}}`) are documentation for the LLM, not shell interpolation
- **Template variables** use Go's `text/template` which handles escaping; they're not directly user-controlled
- **Security reviewers may flag "injection"** in prompts - this is expected; the prompts instruct the LLM what to analyze

## ADRs (Architectural Decisions)

<!-- Format: ADR-NNN: Title, Status, Context, Decision, Consequences -->
