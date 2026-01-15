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
│   ├── onboard.md       # /onboard command
│   └── yagni.md    # /yagni command
├── agents/              # Claude Code subagents
├── skills/              # Claude Code skills
│   ├── git-repo-standards/    # Repo naming, structure, docs
│   ├── git-workflows/         # Consensus review, PRs, branching
│   ├── project-onboarding/    # Init/onboard/validate
│   └── yagni/            # YAGNI/KISS enforcement
├── includes/            # Shared includes for hooks
│   └── yagni/      # Pattern detection, character templates
└── hooks/               # Claude Code hooks
    └── hooks.json       # Enforcement hooks
```

## Plugin Components

| Component | Purpose |
|-----------|---------|
| `git-repo-standards` | Repository naming, structure, README, CHANGELOG, LICENSE, gitleaks |
| `git-workflows` | 5-agent consensus review with contextd, PR requirements, branching |
| `project-onboarding` | Initialize new projects or onboard existing repos |
| `yagni` | YAGNI/KISS enforcement with Silicon Valley humor |
| `/onboard` | Command to run onboarding workflow |
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

### project-onboarding
Initialize or onboard projects to fyrsmithlabs standards:
- `/onboard init` - New project from scratch
- `/onboard` - Onboard existing project
- `/onboard validate` - Audit compliance only

### yagni
YAGNI/KISS enforcement with archetype-themed nudges:
- Non-blocking, humorous feedback when over-engineering detected
- Characters: The Cynic, The Executive, The Supporter, The Bro, The Minimalist, The Realist, The Insecure Dev, The Perfectionist, The Confused
- Patterns: abstraction creep, config addiction, scope creep, dead code, Swiss Army Knife syndrome
- Configurable sensitivity (conservative/moderate/aggressive)
- `/yagni config` to adjust settings

## Known Pitfalls

<!-- Document gotchas as you discover them -->

## ADRs (Architectural Decisions)

<!-- Format: ADR-NNN: Title, Status, Context, Decision, Consequences -->
