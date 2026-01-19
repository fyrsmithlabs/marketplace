# CLAUDE.md - Marketplace

**Status**: Active Development
**Last Updated**: 2026-01-08

---

## Critical Rules

**ALWAYS** follow Claude Code plugin conventions
**ALWAYS** use contextd for cross-session memory and learning
**ALWAYS** apply git-repo-standards and git-workflows skills to projects
**NEVER** commit credentials or API keys to the repository

---

## Project Overview

A Claude Code plugin marketplace providing skills, commands, and agents for fyrsmithlabs project standards and workflows.

## Architecture

```
marketplace/
├── .claude-plugin/      # Plugin manifest
├── commands/            # Claude Code slash commands
│   ├── init.md       # /init command
│   └── yagni.md    # /yagni command
├── agents/              # Claude Code subagents
├── skills/              # Claude Code skills
│   ├── git-repo-standards/    # Repo naming, structure, docs
│   ├── git-workflows/         # Consensus review, PRs, branching
│   ├── init/    # Project setup
│   └── yagni/            # YAGNI/KISS enforcement
├── includes/            # Shared includes for hooks
│   └── yagni/      # Pattern detection
└── hooks/               # Claude Code hooks
    └── hooks.json       # Enforcement hooks
```

## Plugin Components

| Component | Purpose |
|-----------|---------|
| `git-repo-standards` | Repository naming, structure, README, CHANGELOG, LICENSE, gitleaks |
| `git-workflows` | 5-agent consensus review with contextd, PR requirements, branching |
| `init` | Set up projects to follow fyrsmithlabs standards |
| `yagni` | YAGNI/KISS enforcement with humorous nudges |
| `/init` | Command to set up project standards |
| `/yagni` | Command to manage YAGNI/KISS enforcement |

## Code Standards

- Plugin artifacts follow Claude Code conventions
- Use kebab-case for all component names
- Skills must integrate with contextd (memory, remediation, checkpoints)
- Templates go in `skills/<skill-name>/templates/`

## Skills Overview

### git-repo-standards
Enforces repository naming, structure, and documentation standards:
- Naming: `[domain]-[type]` kebab-case
- Required files: README, CHANGELOG, LICENSE, .gitignore, .gitleaks.toml
- Agent artifacts must go in `docs/.claude/` (gitignored)
- Licensing: Apache-2.0 for libs, AGPL-3.0 for services

### git-workflows
Modern agentic git workflows with multi-agent consensus review:
- 5 agents: Security, Vulnerability, Code Quality, Documentation, User Persona
- Security/Vuln have veto power
- contextd integration for learning and remediation
- Trunk-based development, squash merge only

### init
Set up projects to follow fyrsmithlabs standards:
- `/init` - Set up project (detects new vs existing)
- `/init --check` - Audit only, no modifications

### yagni
YAGNI/KISS enforcement with structured nudges:
- Non-blocking feedback when over-engineering detected
- Patterns: abstraction, config-addiction, scope-creep, dead-code
- Structured output format (tree-style, concise)
- Configurable sensitivity (conservative/moderate/aggressive)
- `/yagni config` to adjust settings

## Known Pitfalls

- **Hook prompts are LLM instructions, not executable code** - Variables in hooks/templates (e.g., `{{filename}}`) are documentation for the LLM, not shell interpolation
- **Template variables** use Go's `text/template` which handles escaping; they're not directly user-controlled
- **Security reviewers may flag "injection"** in prompts - this is expected; the prompts instruct the LLM what to analyze

## ADRs (Architectural Decisions)

<!-- Format: ADR-NNN: Title, Status, Context, Decision, Consequences -->
